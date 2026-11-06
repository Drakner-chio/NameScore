-- NameScore: Spielernamen bewerten, Community-Score im Tooltip
-- Kern: Datenhaltung, Score-Berechnung, In-Game-Sync, Slash-Befehle
local ADDON_NAME, ns = ...

local PREFIX = "NAMESCORE"
local SYNC_CHANNEL = "NameScoreSync"
local MAX_SYNC_VOTES = 300      -- max. eigene Stimmen pro Sync-Antwort
local SEND_INTERVAL = 0.25      -- Sekunden zwischen Addon-Nachrichten (Drosselung)

ns.TAGS = { "lustig", "episch", "kreativ", "cringe" }
ns.TAG_LABEL = { lustig = "Lustig", episch = "Episch", kreativ = "Kreativ", cringe = "Cringe" }
local VALID_TAG = {}
for _, t in ipairs(ns.TAGS) do VALID_TAG[t] = true end

-- Rang-Skala im Stil der Item-Qualitäten
ns.RANKS = {
    { min = 9.5, label = "Legendär",     hex = "ff8000" },
    { min = 8.5, label = "Episch",       hex = "a335ee" },
    { min = 7.0, label = "Selten",       hex = "0070dd" },
    { min = 5.0, label = "Ungewöhnlich", hex = "1eff00" },
    { min = 3.0, label = "Gewöhnlich",   hex = "ffffff" },
    { min = 0,   label = "Schrott",      hex = "9d9d9d" },
}

local lastReq = {}

-- ---------------------------------------------------------------
-- Hilfsfunktionen
-- ---------------------------------------------------------------
function ns.Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffff8000NameScore|r: " .. msg)
end

local function MyRealm()
    local r = GetNormalizedRealmName and GetNormalizedRealmName()
    if not r or r == "" then r = (GetRealmName() or ""):gsub("%s", "") end
    return r
end

function ns.FullName(name, realm)
    if not name or name == "" then return nil end
    if name:find("-", 1, true) then return name end
    if not realm or realm == "" then realm = MyRealm() end
    if realm == "" then return name end
    return name .. "-" .. realm
end

function ns.ShortName(full)
    return (full:match("^([^-]+)")) or full
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

-- Liefert Durchschnitt (1-10), Anzahl Stimmen und Tags nach Häufigkeit sortiert
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
    if not avg then return "noch nicht bewertet" end
    local r = ns.Rank(avg)
    return string.format("|cff%s%.1f %s|r |cffaaaaaa(%d %s)|r",
        r.hex, avg, r.label, n, n == 1 and "Stimme" or "Stimmen")
end

function ns.MyVote(target)
    local votes = ns.db.votes[target]
    return votes and votes[ns.me]
end

-- ---------------------------------------------------------------
-- Senden mit Drosselung (Blizzard limitiert Addon-Nachrichten)
-- ---------------------------------------------------------------
local queue = {}

local function Enqueue(msg, chatType, target)
    queue[#queue + 1] = { msg, chatType, target }
end

C_Timer.NewTicker(SEND_INTERVAL, function()
    local m = table.remove(queue, 1)
    if m then C_ChatInfo.SendAddonMessage(PREFIX, m[1], m[2], m[3]) end
end)

local function SyncChannelIndex()
    if not ns.db or not ns.db.useChannel then return nil end
    local id = GetChannelName(SYNC_CHANNEL)
    if id and id > 0 then return id end
    return nil
end

local function Broadcast(msg)
    if IsInGuild() then Enqueue(msg, "GUILD") end
    if IsInRaid() then Enqueue(msg, "RAID")
    elseif IsInGroup() then Enqueue(msg, "PARTY") end
    local ch = SyncChannelIndex()
    if ch then Enqueue(msg, "CHANNEL", ch) end
end

local function VoteMessage(target, v)
    return string.format("V|%s|%d|%s|%d", target, v.s, ns.SerializeTags(v.tags), v.ts)
end

-- ---------------------------------------------------------------
-- Bewerten: 1-5 Sterne, intern als 2-10 gespeichert
-- ---------------------------------------------------------------
function ns.Rate(target, stars, tags)
    if not target then ns.Print("Kein Spieler ausgewählt.") return end
    if target == ns.me then ns.Print("Den eigenen Namen bewerten zählt nicht. ;)") return end
    stars = tonumber(stars)
    if not stars or stars < 1 or stars > 5 or stars ~= math.floor(stars) then
        ns.Print("Bitte 1 bis 5 Sterne vergeben.") return
    end
    local clean = {}
    for t in pairs(tags or {}) do
        if VALID_TAG[t] then clean[t] = true end
    end

    ns.db.votes[target] = ns.db.votes[target] or {}
    local v = { s = stars * 2, tags = clean, ts = time() }
    ns.db.votes[target][ns.me] = v
    Broadcast(VoteMessage(target, v))
    ns.Print(string.format("%s: %d Stern%s vergeben. Neuer Score: %s",
        ns.ShortName(target), stars, stars == 1 and "" or "e", ns.ScoreLine(target)))
end

function ns.TargetFullName()
    if not UnitExists("target") or not UnitIsPlayer("target") then return nil end
    local name, realm = UnitName("target")
    return ns.FullName(name, realm)
end

-- ---------------------------------------------------------------
-- Empfangen
-- ---------------------------------------------------------------
local function HandleMessage(msg, sender)
    sender = ns.FullName(sender)
    if not sender or sender == ns.me then return end

    if msg:sub(1, 2) == "V|" then
        local target, s, tagStr, ts = msg:match("^V|([^|]+)|(%d+)|([%a,]*)|(%d+)$")
        s, ts = tonumber(s), tonumber(ts)
        if not target or not s or s < 1 or s > 10 then return end
        if target == sender then return end          -- keine Selbstbewertung
        if ts > time() + 300 then return end         -- Zeitstempel aus der Zukunft
        ns.db.votes[target] = ns.db.votes[target] or {}
        local old = ns.db.votes[target][sender]
        if not old or ts > old.ts then
            -- Stimme gilt nur für den Absender selbst -> niemand kann fremde Stimmen fälschen
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

-- Stimmen aus v0.1 (ein einzelnes Tag-Feld "t") ins neue Format bringen
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

-- ---------------------------------------------------------------
-- Slash-Befehle
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
        for i = 2, #args do tags[args[i]] = true end
        ns.Rate(ns.TargetFullName(), cmd, tags)
    elseif cmd == "check" and args[2] then
        local t = ns.FullName(raw[2])
        ns.Print(ns.ShortName(t) .. ": " .. ns.ScoreLine(t))
    elseif cmd == "sync" then
        Broadcast("REQ")
        ns.Print("Sync angefragt – Stimmen anderer trudeln gleich ein.")
    elseif cmd == "kanal" then
        ns.db.useChannel = not ns.db.useChannel
        if ns.db.useChannel then JoinTemporaryChannel(SYNC_CHANNEL) else LeaveChannelByName(SYNC_CHANNEL) end
        ns.Print("Öffentlicher Sync-Kanal " .. (ns.db.useChannel and "an" or "aus") .. ".")
    else
        ns.Print("Befehle:")
        ns.Print("/ns – Bewertungsfenster für dein Ziel")
        ns.Print("/ns <1-5> [lustig episch kreativ cringe] – Ziel direkt bewerten")
        ns.Print("/ns check <Name> – Score nachschlagen")
        ns.Print("/ns sync – Stimmen von anderen anfragen")
        ns.Print("/ns kanal – öffentlichen Sync-Kanal an/aus")
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
        if ns.db.useChannel == nil then ns.db.useChannel = true end
        MigrateDB(ns.db)
        C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
    elseif event == "PLAYER_LOGIN" then
        ns.me = ns.FullName(UnitName("player"))
        C_Timer.After(8, function()
            if ns.db.useChannel then
                JoinTemporaryChannel(SYNC_CHANNEL)
                -- Kanal aus den Chatfenstern ausblenden
                C_Timer.After(1, function()
                    for i = 1, NUM_CHAT_WINDOWS do
                        local cf = _G["ChatFrame" .. i]
                        if cf then ChatFrame_RemoveChannel(cf, SYNC_CHANNEL) end
                    end
                end)
            end
            Broadcast("REQ")
        end)
    elseif event == "GROUP_JOINED" then
        C_Timer.After(3, function() Broadcast("REQ") end)
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, msg, _, sender = ...
        if prefix == PREFIX and ns.db and ns.me then HandleMessage(msg, sender) end
    end
end)
