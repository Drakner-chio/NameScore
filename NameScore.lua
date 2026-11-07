-- NameScore: rate player names, community score in the tooltip
-- Core: data storage, score calculation, in-game sync, slash commands
local ADDON_NAME, ns = ...
local L = ns.L

local PREFIX = "NAMESCORE"
local OLD_SYNC_CHANNEL = "NameScoreSync"
local MAX_SYNC_VOTES = 300      -- max. own votes sent per sync reply
local SEND_INTERVAL = 0.25      -- seconds between addon messages (throttling)

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

-- Canonical key for player names. WoW: Forever has surnames and reports them
-- in different shapes: UnitName("player") gives "First Last", targets give
-- ("First", "Last") and addon message senders arrive as "First-Last".
-- All of them become "First-Last", so the same player always has one key.
function ns.FullName(name, realm)
    if not name or name == "" then return nil end
    local full = name
    if realm and realm ~= "" then full = name .. "-" .. realm end
    full = full:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", "-")
    if full == "" then return nil end
    return full
end

-- Readable name for chat and windows: "First-Last" -> "First Last"
function ns.ShortName(full)
    return (full:gsub("-", " "))
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

-- Returns average (1-10), number of votes and tags sorted by frequency
function ns.GetScore(target)
    local votes = ns.db and ns.db.votes[target]
    if not votes then return nil end
    local sum, n, counts = 0, 0, {}
    for _, v in pairs(votes) do
        sum = sum + v.s
        n = n + 1
        if v.tags then
            for t in pairs(v.tags) do counts[t] = (counts[t] or 0) + 1 end
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

function ns.ScoreLine(target)
    local avg, n = ns.GetScore(target)
    if not avg then return L.NOT_RATED end
    local r = ns.Rank(avg)
    return string.format("|cff%s%.1f %s|r |cffaaaaaa(%d %s)|r",
        r.hex, avg, r.label, n, ns.Plural(n, L.VOTE, L.VOTES))
end

function ns.MyVote(target)
    local votes = ns.db.votes[target]
    return votes and votes[ns.me]
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

local function VoteMessage(target, v)
    return string.format("V|%s|%d|%s|%d", target, v.s, ns.SerializeTags(v.tags), v.ts)
end

-- ---------------------------------------------------------------
-- Rating: 1-5 stars, stored internally as 2-10
-- ---------------------------------------------------------------
function ns.Rate(target, stars, tags)
    if not target then ns.Print(L.NO_TARGET) return end
    if target == ns.me then ns.Print(L.NO_SELF) return end
    stars = tonumber(stars)
    if not stars or stars < 1 or stars > 5 or stars ~= math.floor(stars) then
        ns.Print(L.STARS_RANGE) return
    end
    local clean = {}
    for t in pairs(tags or {}) do
        if VALID_TAG[t] then clean[t] = true end
    end

    ns.db.votes[target] = ns.db.votes[target] or {}
    local v = { s = stars * 2, tags = clean, ts = time() }
    ns.db.votes[target][ns.me] = v
    Broadcast(VoteMessage(target, v))
    ns.Print(string.format(L.RATED, ns.ShortName(target), stars,
        ns.Plural(stars, L.STAR, L.STARS), ns.ScoreLine(target)))
end

function ns.TargetFullName()
    if not UnitExists("target") or not UnitIsPlayer("target") then return nil end
    local name, realm = UnitName("target")
    return ns.FullName(name, realm)
end

-- ---------------------------------------------------------------
-- Receiving
-- ---------------------------------------------------------------
local function HandleMessage(msg, sender)
    sender = ns.FullName(sender)
    -- Ignore our own echo from the guild/group channel
    if not sender or sender:lower() == ns.me:lower() then return end

    if msg:sub(1, 2) == "V|" then
        local target, s, tagStr, ts = msg:match("^V|([^|]+)|(%d+)|([%a,]*)|(%d+)$")
        s, ts = tonumber(s), tonumber(ts)
        if not target or not s or s < 1 or s > 10 then return end
        if target == sender then return end          -- no self-rating
        if ts > time() + 300 then return end         -- timestamp from the future
        ns.db.votes[target] = ns.db.votes[target] or {}
        local old = ns.db.votes[target][sender]
        if not old or ts > old.ts then
            -- A vote only counts for its sender -> nobody can fake votes for others
            ns.db.votes[target][sender] = { s = s, tags = ns.ParseTags(tagStr), ts = ts }
        end
    elseif msg == "REQ" then
        local now = GetTime()
        if lastReq[sender] and now - lastReq[sender] < 120 then return end
        lastReq[sender] = now
        local mine = {}
        for target, votes in pairs(ns.db.votes) do
            if votes[ns.me] then mine[#mine + 1] = { target, votes[ns.me] } end
        end
        table.sort(mine, function(a, b) return a[2].ts > b[2].ts end)
        for i = 1, math.min(#mine, MAX_SYNC_VOTES) do
            Enqueue(VoteMessage(mine[i][1], mine[i][2]), "WHISPER", sender)
        end
    end
end

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
        end
    end
end

-- Convert all keys to the canonical format and merge duplicates,
-- including own echo votes stored by earlier versions (newest vote wins)
local function NormalizeDB(db)
    local myLower = ns.me:lower()
    local normalized = {}
    for target, votes in pairs(db.votes) do
        local t = ns.FullName(target)
        normalized[t] = normalized[t] or {}
        for voter, v in pairs(votes) do
            local vk = ns.FullName(voter)
            if vk:lower() == myLower then vk = ns.me end
            local old = normalized[t][vk]
            if not old or (v.ts or 0) > (old.ts or 0) then normalized[t][vk] = v end
        end
    end
    db.votes = normalized
end

-- ---------------------------------------------------------------
-- Slash commands
-- ---------------------------------------------------------------
SLASH_NAMESCORE1 = "/ns"
SLASH_NAMESCORE2 = "/namescore"
SlashCmdList.NAMESCORE = function(input)
    local args, raw = {}, {}
    for w in (input or ""):gmatch("%S+") do
        raw[#raw + 1] = w
        args[#args + 1] = w:lower()
    end
    local cmd = args[1] or ""

    if cmd == "" then
        ns.OpenRating(ns.TargetFullName())
    elseif tonumber(cmd) then
        local tags = {}
        for i = 2, #args do
            local t = TAG_ALIAS[args[i]]
            if t then tags[t] = true end
        end
        ns.Rate(ns.TargetFullName(), cmd, tags)
    elseif cmd == "check" and raw[2] then
        local t = ns.FindKey(table.concat(raw, " ", 2))
        ns.Print(ns.ShortName(t) .. ": " .. ns.ScoreLine(t))
    elseif cmd == "sync" then
        Broadcast("REQ")
        ns.Print(L.SYNC_REQUESTED)
    else
        ns.Print(L.HELP_HEADER)
        ns.Print(L.HELP_OPEN)
        ns.Print(L.HELP_RATE)
        ns.Print(L.HELP_CHECK)
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
        ns.db.useChannel = nil   -- leftover from v0.1/v0.2
        MigrateDB(ns.db)
        C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
    elseif event == "PLAYER_LOGIN" then
        ns.me = ns.FullName(UnitName("player"))
        NormalizeDB(ns.db)
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
