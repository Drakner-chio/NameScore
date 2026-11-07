-- NameScore: rate player, guild and pet names, community score in the tooltip
-- Core: keys, data storage, score calculation, in-game sync, slash commands
local ADDON_NAME, ns = ...
local L = ns.L

local PREFIX = "NAMESCORE"
local OLD_SYNC_CHANNEL = "NameScoreSync"
local MAX_SYNC_VOTES = 300      -- max. own votes sent per sync reply
local SEND_INTERVAL = 0.25      -- seconds between addon messages (throttling)
local MAX_AGE = 180 * 86400     -- votes older than ~6 months are removed

ns.DEFAULTS = {
    showBadge = true,   -- tooltip badge on/off
    showOwn   = true,   -- show your own vote in the tooltip
    minVotes  = 2,      -- votes needed before a score is shown
    elvSkin   = true,   -- use ElvUI style if ElvUI is installed
}

-- Internal tag ids. They are part of the sync protocol and saved data,
-- so they stay as they are; display names come from the locale.
ns.TAGS = { "lustig", "episch", "kreativ", "cringe" }
local VALID_TAG = {}
for _, t in ipairs(ns.TAGS) do VALID_TAG[t] = true end

-- Words accepted for tags in slash commands (English and German)
local TAG_ALIAS = {
    funny = "lustig", lustig = "lustig",
    epic = "episch", episch = "episch",
    creative = "kreativ", kreativ = "kreativ",
    cringe = "cringe",
}

function ns.TagLabel(tag)
    return L["TAG_" .. tag] or tag
end

-- Rank scale styled after item quality colors
ns.RANKS = {
    { min = 9.5, label = L.RANK_LEGENDARY, hex = "ff8000" },
    { min = 8.5, label = L.RANK_EPIC,      hex = "a335ee" },
    { min = 7.0, label = L.RANK_RARE,      hex = "0070dd" },
    { min = 5.0, label = L.RANK_UNCOMMON,  hex = "1eff00" },
    { min = 3.0, label = L.RANK_COMMON,    hex = "ffffff" },
    { min = 0,   label = L.RANK_POOR,      hex = "9d9d9d" },
}

local lastReq = {}

-- ---------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------
function ns.Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffff8000NameScore|r: " .. msg)
end

-- In instances the game can hide unit data behind "secret values". They must
-- not be used in string operations or comparisons, so everything checks first.
function ns.IsSecret(v)
    return issecretvalue ~= nil and issecretvalue(v) == true
end
local IsSecret = ns.IsSecret

function ns.Setting(name)
    local s = ns.db and ns.db.settings
    if s and s[name] ~= nil then return s[name] end
    return ns.DEFAULTS[name]
end

local function Trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- ---------------------------------------------------------------
-- Keys
--   Player: "First-Last"
--   Guild:  "G:<guild name>"
--   Pet:    "P:<owner key>:<pet name>"  (pet names are not unique, the owner is)
-- ---------------------------------------------------------------

-- Canonical key for player names. WoW: Forever has surnames and reports them
-- in different shapes: UnitName("player") gives "First Last", targets give
-- ("First", "Last") and addon message senders arrive as "First-Last".
-- All of them become "First-Last", so the same player always has one key.
function ns.FullName(name, realm)
    if not name or name == "" then return nil end
    local full = name
    if realm and realm ~= "" then full = name .. "-" .. realm end
    full = Trim(full):gsub("%s+", "-")
    if full == "" then return nil end
    return full
end

function ns.GuildKey(guildName)
    if type(guildName) ~= "string" then return nil end
    guildName = Trim(guildName)
    if guildName == "" then return nil end
    return "G:" .. guildName
end

function ns.PetKey(ownerKey, petName)
    if not ownerKey or type(petName) ~= "string" then return nil end
    petName = Trim(petName)
    if petName == "" or petName:find("[:|]") then return nil end
    return "P:" .. ownerKey .. ":" .. petName
end

-- Returns "player", "guild" or "pet" plus the parts of the key
function ns.ParseKey(key)
    local guild = key:match("^G:(.+)$")
    if guild then return "guild", guild end
    local owner, pet = key:match("^P:([^:]+):(.+)$")
    if owner then return "pet", pet, owner end
    return "player", key
end

-- Readable name for chat and windows
local function PlayerDisplay(key)
    return (key:gsub("-", " "))
end

function ns.ShortName(key)
    local kind, a, b = ns.ParseKey(key)
    if kind == "guild" then return "<" .. a .. ">" end
    if kind == "pet" then return string.format(L.PET_DISPLAY, a, PlayerDisplay(b)) end
    return PlayerDisplay(a)
end

function ns.MyGuildKey()
    if not IsInGuild() then return nil end
    local g = GetGuildInfo("player")
    if IsSecret(g) then return nil end
    return ns.GuildKey(g)
end

-- Returns the reason why this key may not be rated by us, or nil
function ns.OwnReason(key)
    if not ns.me or not key then return L.NO_TARGET end
    if key:lower() == ns.me:lower() then return L.NO_SELF end
    local kind, _, owner = ns.ParseKey(key)
    if kind == "guild" and key == ns.MyGuildKey() then return L.NO_SELF_GUILD end
    if kind == "pet" and owner:lower() == ns.me:lower() then return L.NO_SELF_PET end
    return nil
end

-- Finds the stored key for a typed name: exact match first,
-- otherwise a unique player whose key starts with "Name-"
function ns.FindKey(typed)
    local key = ns.FullName(typed)
    if not key or ns.db.votes[key] then return key end
    local prefix, found = key:lower() .. "-", nil
    for k in pairs(ns.db.votes) do
        if k:lower():sub(1, #prefix) == prefix then
            if found then return key end   -- ambiguous, keep the typed name
            found = k
        end
    end
    return found or key
end

-- ---------------------------------------------------------------
-- Reading units: players, their guild, and pets
-- ---------------------------------------------------------------

-- "%s's Pet" -> "^(.+)'s Pet$"; built from the game's own localized strings
local OWNER_PATTERNS = {}
for _, fmt in ipairs({ UNITNAME_TITLE_PET, UNITNAME_TITLE_MINION }) do
    if type(fmt) == "string" and fmt:find("%%s") then
        local p = fmt:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"):gsub("%%%%s", "(.+)")
        OWNER_PATTERNS[#OWNER_PATTERNS + 1] = "^" .. p .. "$"
    end
end

-- Finds the owner in tooltip lines like "Pet of Drakner Beansen"
function ns.OwnerFromLines(lines)
    for i = 2, math.min(#lines, 4) do
        local text = lines[i]
        if type(text) == "string" and not IsSecret(text) then
            for _, p in ipairs(OWNER_PATTERNS) do
                local owner = text:match(p)
                if owner then return ns.FullName(owner) end
            end
        end
    end
    return nil
end

-- Left texts of a unit's tooltip, without showing anything on screen
local scanTip
function ns.UnitLines(unit)
    local lines = {}
    if C_TooltipInfo and C_TooltipInfo.GetUnit then
        local ok, data = pcall(C_TooltipInfo.GetUnit, unit)
        if ok and type(data) == "table" and data.lines then
            for i, line in ipairs(data.lines) do lines[i] = line.leftText end
            return lines
        end
    end
    if not scanTip then
        scanTip = CreateFrame("GameTooltip", "NameScoreScanTooltip", nil, "GameTooltipTemplate")
    end
    scanTip:SetOwner(WorldFrame, "ANCHOR_NONE")
    scanTip:SetUnit(unit)
    for i = 1, scanTip:NumLines() do
        local fs = _G["NameScoreScanTooltipTextLeft" .. i]
        lines[i] = fs and fs:GetText()
    end
    scanTip:Hide()
    return lines
end

-- Key for a unit (player or pet). `lines` are the unit's tooltip texts if
-- the caller already has them. Returns nil for NPCs and hidden data.
function ns.UnitKey(unit, lines)
    if not unit or IsSecret(unit) or not UnitExists(unit) then return nil end
    local name, realm = UnitName(unit)
    if IsSecret(name) or IsSecret(realm) or type(name) ~= "string" then return nil end
    if UnitIsPlayer(unit) then return ns.FullName(name, realm) end
    if not UnitPlayerControlled(unit) then return nil end   -- NPC
    -- A pet: find its owner
    local owner
    if UnitIsUnit(unit, "pet") then
        owner = ns.me
    else
        local ok, found = pcall(ns.OwnerFromLines, lines or ns.UnitLines(unit))
        owner = ok and found or nil
    end
    return ns.PetKey(owner, name)
end

function ns.UnitGuildKey(unit)
    if not unit or IsSecret(unit) or not UnitIsPlayer(unit) then return nil end
    local g = GetGuildInfo(unit)
    if IsSecret(g) then return nil end
    return ns.GuildKey(g)
end

function ns.TargetKey()
    local ok, key = pcall(ns.UnitKey, "target")
    return ok and key or nil
end

-- ---------------------------------------------------------------
-- Scores
-- ---------------------------------------------------------------
function ns.Rank(avg)
    for _, r in ipairs(ns.RANKS) do
        if avg >= r.min then return r end
    end
    return ns.RANKS[#ns.RANKS]
end

function ns.HexToRGB(hex)
    return tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255
end

function ns.Plural(n, one, many)
    return n == 1 and one or many
end

function ns.SerializeTags(set)
    local list = {}
    for _, t in ipairs(ns.TAGS) do
        if set and set[t] then list[#list + 1] = t end
    end
    return table.concat(list, ",")
end

function ns.ParseTags(str)
    local set = {}
    for t in (str or ""):gmatch("[^,]+") do
        if VALID_TAG[t] then set[t] = true end
    end
    return set
end

-- Returns average (1-10), number of votes and tags sorted by frequency.
-- Deleted votes (s = 0) are kept so the deletion can be synced, but don't count.
function ns.GetScore(key)
    local votes = ns.db and ns.db.votes[key]
    if not votes then return nil end
    local sum, n, counts = 0, 0, {}
    for _, v in pairs(votes) do
        if v.s > 0 then
            sum = sum + v.s
            n = n + 1
            for t in pairs(v.tags or {}) do counts[t] = (counts[t] or 0) + 1 end
        end
    end
    if n == 0 then return nil end
    local tags = {}
    for _, t in ipairs(ns.TAGS) do
        if counts[t] then tags[#tags + 1] = { tag = t, count = counts[t] } end
    end
    table.sort(tags, function(a, b) return a.count > b.count end)
    return sum / n, n, tags
end

function ns.MinVotes()
    return ns.Setting("minVotes")
end

-- One-line summary, e.g. "7.0 Rare (3 votes)" or "too few votes (1/2)"
function ns.ScoreLine(key)
    local avg, n = ns.GetScore(key)
    if not avg then return L.NOT_RATED end
    if n < ns.MinVotes() then
        return "|cffaaaaaa" .. string.format(L.TOO_FEW, n, ns.MinVotes()) .. "|r"
    end
    local r = ns.Rank(avg)
    return string.format("|cff%s%.1f %s|r |cffaaaaaa(%d %s)|r",
        r.hex, avg, r.label, n, ns.Plural(n, L.VOTE, L.VOTES))
end

-- Own vote, or nil if none (or deleted)
function ns.MyVote(key)
    local votes = ns.db.votes[key]
    local v = votes and votes[ns.me]
    if v and v.s > 0 then return v end
    return nil
end

-- Number of known votes in total (not counting deleted ones)
function ns.CountVotes()
    local total = 0
    for _, votes in pairs(ns.db.votes) do
        for _, v in pairs(votes) do
            if v.s > 0 then total = total + 1 end
        end
    end
    return total
end

-- ---------------------------------------------------------------
-- Sending with throttling (Blizzard rate-limits addon messages)
-- ---------------------------------------------------------------
local queue = {}

local function Enqueue(msg, chatType, target)
    queue[#queue + 1] = { msg, chatType, target }
end

C_Timer.NewTicker(SEND_INTERVAL, function()
    local m = table.remove(queue, 1)
    if m then C_ChatInfo.SendAddonMessage(PREFIX, m[1], m[2], m[3]) end
end)

-- Note: WoW Forever does not allow addon messages in custom chat channels,
-- so sync only uses guild and party/raid.
local function Broadcast(msg)
    if IsInGuild() then Enqueue(msg, "GUILD") end
    if IsInRaid() then Enqueue(msg, "RAID")
    elseif IsInGroup() then Enqueue(msg, "PARTY") end
end
ns.Broadcast = Broadcast

-- "V|key|score|tags|time"; score 0 means "vote deleted"
local function VoteMessage(key, v)
    return string.format("V|%s|%d|%s|%d", key, v.s, ns.SerializeTags(v.tags), v.ts)
end

-- ---------------------------------------------------------------
-- Rating: 0.5-5 stars in half steps, stored internally as 1-10
-- ---------------------------------------------------------------

-- "3.5" / "3,5" -> 3.5; nil if not a number
function ns.ParseStars(text)
    return tonumber((tostring(text or ""):gsub(",", ".")))
end

-- 3 -> "3", 3.5 -> "3.5" (or "3,5" in German)
function ns.FormatStars(stars)
    if stars == math.floor(stars) then return tostring(math.floor(stars)) end
    return (string.format("%.1f", stars):gsub("%.", L.DECIMAL))
end

function ns.Rate(key, stars, tags)
    if not key then ns.Print(L.NO_TARGET) return end
    local reason = ns.OwnReason(key)
    if reason then ns.Print(reason) return end
    stars = ns.ParseStars(stars)
    local half = stars and stars * 2
    if not half or half < 1 or half > 10 or half ~= math.floor(half) then
        ns.Print(L.STARS_RANGE) return
    end
    local clean = {}
    for t in pairs(tags or {}) do
        if VALID_TAG[t] then clean[t] = true end
    end

    ns.db.votes[key] = ns.db.votes[key] or {}
    local v = { s = half, tags = clean, ts = time() }
    ns.db.votes[key][ns.me] = v
    Broadcast(VoteMessage(key, v))
    ns.Print(string.format(L.RATED, ns.ShortName(key), ns.FormatStars(stars),
        ns.Plural(stars, L.STAR, L.STARS), ns.ScoreLine(key)))
end

-- Deleting keeps an empty marker (s = 0) so the deletion reaches the others
function ns.DeleteVote(key)
    if not key then ns.Print(L.NO_TARGET) return end
    if not ns.MyVote(key) then
        ns.Print(string.format(L.NO_VOTE, ns.ShortName(key))) return
    end
    local v = { s = 0, tags = {}, ts = time() }
    ns.db.votes[key][ns.me] = v
    Broadcast(VoteMessage(key, v))
    ns.Print(string.format(L.VOTE_DELETED, ns.ShortName(key)))
end

-- ---------------------------------------------------------------
-- Receiving
-- ---------------------------------------------------------------
local function HandleMessage(msg, sender)
    sender = ns.FullName(sender)
    -- Ignore our own echo from the guild/group channel
    if not sender or sender:lower() == ns.me:lower() then return end

    if msg:sub(1, 2) == "V|" then
        local key, s, tagStr, ts = msg:match("^V|([^|]+)|(%d+)|([%a,]*)|(%d+)$")
        s, ts = tonumber(s), tonumber(ts)
        if not key or not s or s > 10 then return end
        if ts > time() + 300 then return end              -- timestamp from the future
        if ts < time() - MAX_AGE then return end          -- too old, would be removed anyway
        if key:lower() == sender:lower() then return end  -- no self-rating
        local kind, _, owner = ns.ParseKey(key)
        if kind == "pet" and owner:lower() == sender:lower() then return end
        ns.db.votes[key] = ns.db.votes[key] or {}
        local old = ns.db.votes[key][sender]
        if not old or ts > old.ts then
            -- A vote only counts for its sender -> nobody can fake votes for others
            ns.db.votes[key][sender] = { s = s, tags = ns.ParseTags(tagStr), ts = ts }
        end
    elseif msg == "REQ" then
        local now = GetTime()
        if lastReq[sender] and now - lastReq[sender] < 120 then return end
        lastReq[sender] = now
        -- Reply with our own votes, including deletions, newest first
        local mine = {}
        for key, votes in pairs(ns.db.votes) do
            if votes[ns.me] then mine[#mine + 1] = { key, votes[ns.me] } end
        end
        table.sort(mine, function(a, b) return a[2].ts > b[2].ts end)
        for i = 1, math.min(#mine, MAX_SYNC_VOTES) do
            Enqueue(VoteMessage(mine[i][1], mine[i][2]), "WHISPER", sender)
        end
    end
end

-- ---------------------------------------------------------------
-- Saved data maintenance
-- ---------------------------------------------------------------

-- Convert votes from v0.1 (single tag field "t") to the current format
local function MigrateDB(db)
    for _, votes in pairs(db.votes) do
        for _, v in pairs(votes) do
            if v.t ~= nil then
                v.tags = v.tags or {}
                if VALID_TAG[v.t] then v.tags[v.t] = true end
                v.t = nil
            end
            v.tags = v.tags or {}
            v.ts = v.ts or 0
        end
    end
end

-- Convert player keys to the canonical format and merge duplicates,
-- including own echo votes stored by earlier versions (newest vote wins)
local function NormalizeDB(db)
    local myLower = ns.me:lower()
    local normalized = {}
    for key, votes in pairs(db.votes) do
        local k = key
        if ns.ParseKey(key) == "player" then k = ns.FullName(key) end
        if k then
            normalized[k] = normalized[k] or {}
            for voter, v in pairs(votes) do
                local vk = ns.FullName(voter)
                if vk then
                    if vk:lower() == myLower then vk = ns.me end
                    local old = normalized[k][vk]
                    if not old or v.ts > old.ts then normalized[k][vk] = v end
                end
            end
        end
    end
    db.votes = normalized
end

-- Remove votes older than MAX_AGE and names without any votes left
local function PruneDB(db)
    local limit = time() - MAX_AGE
    for key, votes in pairs(db.votes) do
        for voter, v in pairs(votes) do
            if v.ts < limit then votes[voter] = nil end
        end
        if next(votes) == nil then db.votes[key] = nil end
    end
end

-- ---------------------------------------------------------------
-- Slash commands
-- ---------------------------------------------------------------
local CMD = {
    gilde = "guild", guild = "guild",
    ["löschen"] = "delete", loeschen = "delete", delete = "delete",
    top = "hall", liste = "hall", list = "hall", ruhmeshalle = "hall",
    optionen = "options", options = "options", config = "options",
    check = "check", sync = "sync", min = "min",
    badge = "badge", own = "own", eigene = "own", elvui = "elvui",
}

local function TargetGuildKey()
    local ok, key = pcall(ns.UnitGuildKey, "target")
    return ok and key or nil
end

SLASH_NAMESCORE1 = "/ns"
SLASH_NAMESCORE2 = "/namescore"
SlashCmdList.NAMESCORE = function(input)
    local args, raw = {}, {}
    for w in (input or ""):gmatch("%S+") do
        raw[#raw + 1] = w
        args[#args + 1] = w:lower()
    end
    local cmd = CMD[args[1] or ""] or args[1] or ""

    if cmd == "" then
        ns.OpenRating(ns.TargetKey())
    elseif ns.ParseStars(cmd) then
        local tags = {}
        for i = 2, #args do
            local t = TAG_ALIAS[args[i]]
            if t then tags[t] = true end
        end
        ns.Rate(ns.TargetKey(), cmd, tags)
    elseif cmd == "guild" then
        local key = TargetGuildKey()
        if key then ns.OpenRating(key) else ns.Print(L.NO_GUILD) end
    elseif cmd == "delete" then
        if args[2] == "gilde" or args[2] == "guild" then
            ns.DeleteVote(TargetGuildKey())
        else
            ns.DeleteVote(ns.TargetKey())
        end
    elseif cmd == "check" and raw[2] then
        local t = ns.FindKey(table.concat(raw, " ", 2))
        ns.Print(ns.ShortName(t) .. ": " .. ns.ScoreLine(t))
    elseif cmd == "sync" then
        Broadcast("REQ")
        ns.Print(L.SYNC_REQUESTED)
    elseif cmd == "hall" then
        ns.ToggleHall()
    elseif cmd == "options" then
        ns.OpenOptions()
    elseif cmd == "min" and tonumber(args[2]) then
        local n = math.max(1, math.min(5, math.floor(tonumber(args[2]))))
        ns.db.settings.minVotes = n
        ns.Print(string.format(L.MIN_SET, n))
    elseif cmd == "badge" then
        ns.ToggleSetting("showBadge", L.OPT_BADGE)
    elseif cmd == "own" then
        ns.ToggleSetting("showOwn", L.OPT_OWN)
    elseif cmd == "elvui" then
        ns.ToggleSetting("elvSkin", L.OPT_ELVUI)
    else
        ns.Print(L.HELP_HEADER)
        ns.Print(L.HELP_OPEN)
        ns.Print(L.HELP_RATE)
        ns.Print(L.HELP_GUILD)
        ns.Print(L.HELP_DELETE)
        ns.Print(L.HELP_CHECK)
        ns.Print(L.HELP_HALL)
        ns.Print(L.HELP_OPTIONS)
        ns.Print(L.HELP_SYNC)
    end
end

-- ---------------------------------------------------------------
-- Events
-- ---------------------------------------------------------------
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("CHAT_MSG_ADDON")
ev:RegisterEvent("GROUP_JOINED")

ev:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" and ... == ADDON_NAME then
        NameScoreDB = NameScoreDB or {}
        ns.db = NameScoreDB
        ns.db.votes = ns.db.votes or {}
        ns.db.settings = ns.db.settings or {}
        for k, v in pairs(ns.DEFAULTS) do
            if ns.db.settings[k] == nil then ns.db.settings[k] = v end
        end
        ns.db.useChannel = nil   -- leftover from v0.1/v0.2
        MigrateDB(ns.db)
        C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
        if ns.BuildOptions then pcall(ns.BuildOptions) end
    elseif event == "PLAYER_LOGIN" then
        ns.me = ns.FullName(UnitName("player"))
        NormalizeDB(ns.db)
        PruneDB(ns.db)
        C_Timer.After(8, function()
            -- Leave the sync channel used by earlier versions
            local id = GetChannelName(OLD_SYNC_CHANNEL)
            if id and id > 0 then LeaveChannelByName(OLD_SYNC_CHANNEL) end
            Broadcast("REQ")
        end)
    elseif event == "GROUP_JOINED" then
        C_Timer.After(3, function() Broadcast("REQ") end)
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, msg, _, sender = ...
        if prefix == PREFIX and ns.db and ns.me then HandleMessage(msg, sender) end
    end
end)
