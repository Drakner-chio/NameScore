-- NameScore UI: tooltip badge, guild score, rating window, right-click menus
local ADDON_NAME, ns = ...
local L = ns.L
local IsSecret = ns.IsSecret

-- Own star (media/Star.tga): the raid target star looks different in WoW: Forever
local STAR_TEX = "Interface\\AddOns\\NameScore\\media\\Star"
local STAR_INLINE = "|T" .. STAR_TEX .. ":0|t"

-- ---------------------------------------------------------------
-- EllesmereUI (optional): official skinning API, see its SKINNING_API.md.
-- EUI calls us once at login with a set of skin functions S; our windows are
-- created later, so each window registers its skin code with ns.WhenEUI.
-- ---------------------------------------------------------------
local euiQueue = {}

function ns.HasEUI()
    return EllesmereUI ~= nil and EllesmereUI.RegisterSkin ~= nil and ns.Setting("elvSkin")
end

-- Runs fn(S) now if EllesmereUI is ready, otherwise as soon as it is
function ns.WhenEUI(fn)
    if ns.EUI then
        local ok, err = pcall(fn, ns.EUI)
        if not ok then geterrorhandler()(err) end
    else
        euiQueue[#euiQueue + 1] = fn
    end
end

if EllesmereUI and EllesmereUI.RegisterSkin then
    EllesmereUI.RegisterSkin("NameScore", function(S)
        if not ns.Setting("elvSkin") then return end
        ns.EUI = S
        for _, fn in ipairs(euiQueue) do ns.WhenEUI(fn) end
        euiQueue = {}
    end)
end

-- ---------------------------------------------------------------
-- ElvUI detection (optional, only when EllesmereUI isn't skinning us)
-- ---------------------------------------------------------------
function ns.GetElvUI()
    if not ElvUI or not ns.Setting("elvSkin") or ns.HasEUI() then return nil end
    local ok, E = pcall(function() return unpack(ElvUI) end)
    if not ok or not E then return nil end
    local okS, S = pcall(E.GetModule, E, "Skins")
    return E, (okS and S) or nil
end

function ns.ElvFont(fs, E, size)
    if E and E.media and E.media.normFont then
        fs:SetFont(E.media.normFont, size, "OUTLINE")
    end
end
local GetElvUI, ElvFont = ns.GetElvUI, ns.ElvFont

-- ---------------------------------------------------------------
-- Tooltip badge
-- ---------------------------------------------------------------
local badge

local function CreateBadge()
    local E = GetElvUI()

    -- Compact badge, two tooltip lines high:
    -- [score] RANK · tags ............ n votes · you: x
    -- [     ] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    badge = CreateFrame("Frame", nil, GameTooltip)
    badge:SetHeight(24)

    -- Square with the score, border in rank color.
    -- Built from plain textures on purpose: Blizzard's BackdropTemplate does
    -- Lua math on the frame size, which is a secret value inside a tooltip in
    -- dungeons and throws an error on every resize.
    badge.box = CreateFrame("Frame", nil, badge)
    badge.box:SetSize(32, 24)
    badge.box:SetPoint("LEFT")

    local bg = badge.box:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.6)

    local function Edge(p1, p2, w, h)
        local t = badge.box:CreateTexture(nil, "BORDER")
        t:SetPoint(p1)
        t:SetPoint(p2)
        if w then t:SetWidth(w) end
        if h then t:SetHeight(h) end
        return t
    end
    badge.box.edges = {
        Edge("TOPLEFT", "TOPRIGHT", nil, 2),
        Edge("BOTTOMLEFT", "BOTTOMRIGHT", nil, 2),
        Edge("TOPLEFT", "BOTTOMLEFT", 2, nil),
        Edge("TOPRIGHT", "BOTTOMRIGHT", 2, nil),
    }

    badge.score = badge.box:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    badge.score:SetPoint("CENTER", 0, 0)

    badge.votes = badge:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    badge.votes:SetPoint("TOPRIGHT", badge, "TOPRIGHT", 0, -1)

    -- Rank and tags in one line; cut off with "..." instead of running into the votes
    badge.rank = badge:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    badge.rank:SetPoint("TOPLEFT", badge.box, "TOPRIGHT", 6, -1)
    badge.rank:SetPoint("RIGHT", badge.votes, "LEFT", -6, 0)
    badge.rank:SetJustifyH("LEFT")
    badge.rank:SetWordWrap(false)

    badge.bar = CreateFrame("StatusBar", nil, badge)
    badge.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    badge.bar:SetMinMaxValues(0, 10)
    badge.bar:SetHeight(4)
    badge.bar:SetPoint("BOTTOMLEFT", badge.box, "BOTTOMRIGHT", 6, 2)
    badge.bar:SetPoint("RIGHT", badge, "RIGHT", 0, 0)
    badge.bar.bg = badge.bar:CreateTexture(nil, "BACKGROUND")
    badge.bar.bg:SetAllPoints()
    badge.bar.bg:SetColorTexture(0.16, 0.17, 0.21, 1)

    if E then
        if E.media.normTex then badge.bar:SetStatusBarTexture(E.media.normTex) end
        ElvFont(badge.score, E, 12)
        ElvFont(badge.rank, E, 10)
        ElvFont(badge.votes, E, 10)
    end
    if ns.HasEUI() then
        ns.WhenEUI(function(S)
            S.Font(badge.score)
            S.Font(badge.rank)
            S.Font(badge.votes)
        end)
    end

    badge:Hide()
end

local function HideBadge(tt)
    if badge then badge:Hide() end
    if tt and tt.SetMinimumWidth then tt:SetMinimumWidth(0) end
end

-- " · you: 3.5" if enabled and we voted
local function OwnSuffix(key)
    if not ns.Setting("showOwn") then return "" end
    local mine = ns.MyVote(key)
    if not mine then return "" end
    return " · " .. string.format(L.YOURS, ns.FormatStars(mine.s / 2))
end

local function TooltipLines(tt)
    local lines, name = {}, tt:GetName()
    for i = 1, tt:NumLines() do
        local fs = _G[name .. "TextLeft" .. i]
        lines[i] = fs and fs:GetText()
    end
    return lines
end

-- Appends the guild score to the tooltip line that shows the guild name
local function AnnotateGuild(tt, unit)
    local gkey = ns.UnitGuildKey(unit)
    if not gkey then return end
    local avg, n = ns.GetScore(gkey)
    local own = ns.Setting("showOwn") and ns.MyVote(gkey)
    if not ((avg and n >= ns.MinVotes()) or own) then return end

    local text = ""
    if avg and n >= ns.MinVotes() then
        local r = ns.Rank(avg)
        text = string.format("%s |cff%s%.1f|r", STAR_INLINE, r.hex, avg)
    end
    if own then
        text = text .. " |cffaaaaaa(" .. string.format(L.YOURS, ns.FormatStars(own.s / 2)) .. ")|r"
    end

    local guildName = gkey:sub(3)
    local name = tt:GetName()
    for i = 2, math.min(tt:NumLines(), 5) do
        local fs = _G[name .. "TextLeft" .. i]
        local t = fs and fs:GetText()
        if type(t) == "string" and not IsSecret(t) and t:find(guildName, 1, true) then
            fs:SetText(t .. "  " .. text)
            return
        end
    end
end

local function AddToTooltip(tt)
    if not ns.db or not ns.me or not ns.Setting("showBadge") then return end

    -- In dungeons the tooltip's unit token can be secret; the plain
    -- "mouseover" token points to the same unit and may still be readable
    local _, unit = tt:GetUnit()
    if IsSecret(unit) or not unit then unit = "mouseover" end
    local key = ns.UnitKey(unit, TooltipLines(tt))
    if not key then return end

    if UnitIsPlayer(unit) then AnnotateGuild(tt, unit) end

    local avg, n, tags = ns.GetScore(key)
    if not avg then
        tt:AddLine("|cffff8000NameScore|r |cff777777– " .. L.NOT_RATED .. "|r")
        tt:Show()
        return
    end
    if n < ns.MinVotes() then
        tt:AddLine("|cffff8000NameScore|r |cff777777– " ..
            string.format(L.TOO_FEW, n, ns.MinVotes()) .. OwnSuffix(key) .. "|r")
        tt:Show()
        return
    end

    if not badge then CreateBadge() end
    local r = ns.Rank(avg)
    local cr, cg, cb = ns.HexToRGB(r.hex)

    badge.score:SetText(string.format("%.1f", avg))
    badge.score:SetTextColor(cr, cg, cb)
    for _, edge in ipairs(badge.box.edges) do edge:SetColorTexture(cr, cg, cb, 1) end
    badge.votes:SetText(n .. " " .. ns.Plural(n, L.VOTE, L.VOTES) .. OwnSuffix(key))
    badge.bar:SetValue(avg)
    badge.bar:SetStatusBarColor(cr, cg, cb)

    -- "RANK · Tag1 · Tag2": rank in its color, top tag gold, second tag grey
    local line = "|cff" .. r.hex .. r.label:upper() .. "|r"
    for i = 1, math.min(#tags, 2) do
        local color = (i == 1) and "|cffffd100" or "|cffcccccc"
        line = line .. " |cff777777·|r " .. color .. ns.TagLabel(tags[i].tag) .. "|r"
    end
    badge.rank:SetText(line)

    -- Reserve two lines in the tooltip and place the badge on top of them
    for _ = 1, 2 do tt:AddLine(" ") end
    local first = _G[tt:GetName() .. "TextLeft" .. (tt:NumLines() - 1)]
    badge:SetParent(tt)
    badge:SetFrameLevel(tt:GetFrameLevel() + 5)
    badge:ClearAllPoints()
    badge:SetPoint("TOPLEFT", first, "TOPLEFT", 0, 0)
    badge:SetPoint("RIGHT", tt, "RIGHT", -10, 0)
    if tt.SetMinimumWidth then tt:SetMinimumWidth(240) end
    badge:Show()
    tt:Show()
end

-- A tooltip error must never spam the player: catch it, hide the badge
-- and report only the first one per session so it can be fixed.
local errorReported = false
local function SafeAddToTooltip(tt)
    local ok, err = pcall(AddToTooltip, tt)
    if not ok then
        if badge then badge:Hide() end
        if not errorReported then
            errorReported = true
            local msg = type(err) == "string" and err or "unknown error"
            if ns.db then ns.db.lastError = msg end
            ns.Print(L.TOOLTIP_ERROR .. " " .. msg)
        end
    end
end

if TooltipDataProcessor and Enum and Enum.TooltipDataType then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tt)
        if tt ~= GameTooltip then return end
        SafeAddToTooltip(tt)
    end)
else
    GameTooltip:HookScript("OnTooltipSetUnit", SafeAddToTooltip)
end
GameTooltip:HookScript("OnTooltipCleared", HideBadge)
GameTooltip:HookScript("OnHide", HideBadge)

-- ---------------------------------------------------------------
-- Rating window (stars & tags)
-- ---------------------------------------------------------------
local frame
-- state.half = number of half stars (0-10), i.e. the internal 1-10 score
local state = { half = 0, tags = {} }
local STAR_SIZE = 36

-- Each star has a dim full star behind and a bright overlay on top that
-- shows the full star, only its left half, or nothing.
local function UpdateStars()
    for i, star in ipairs(frame.stars) do
        local filled = state.half - (i - 1) * 2   -- 2 = full, 1 = half, <=0 = empty
        if filled >= 2 then
            star.on:SetWidth(STAR_SIZE)
            star.on:SetTexCoord(0, 1, 0, 1)
            star.on:Show()
        elseif filled == 1 then
            star.on:SetWidth(STAR_SIZE / 2)
            star.on:SetTexCoord(0, 0.5, 0, 1)
            star.on:Show()
        else
            star.on:Hide()
        end
    end
    frame.send:SetEnabled(state.half > 0)
end

local function UpdateTags()
    for tag, b in pairs(frame.tagButtons) do
        local on = state.tags[tag]
        local fs = b:GetFontString()
        if frame.eui then
            -- EllesmereUI: selected tags in the user's accent color
            if fs then
                if on then fs:SetTextColor(frame.eui.GetAccentColor()) else fs:SetTextColor(0.7, 0.7, 0.7) end
            end
        elseif fs then
            if on then fs:SetTextColor(1, 0.82, 0) else fs:SetTextColor(0.75, 0.75, 0.75) end
        end
        if frame.eui then
            -- nothing else to do, the flat EUI button has no highlight state
        elseif frame.elv and b.SetBackdropBorderColor then
            if on then
                b:SetBackdropBorderColor(1, 0.82, 0)
            else
                local c = frame.elv.media.bordercolor or { 0, 0, 0 }
                b:SetBackdropBorderColor(c[1], c[2], c[3])
            end
        else
            if on then b:LockHighlight() else b:UnlockHighlight() end
        end
    end
end

local function ApplyElvUISkin()
    local E, S = GetElvUI()
    if not E or not S then return end
    local ok = pcall(function()
        if frame.StripTextures then frame:StripTextures() end
        frame:SetTemplate("Transparent")
        if frame.CloseButton then S:HandleCloseButton(frame.CloseButton) end
        for _, b in pairs(frame.tagButtons) do S:HandleButton(b) end
        S:HandleButton(frame.send)
        S:HandleButton(frame.delete)
        ElvFont(frame.title, E, 14)
        ElvFont(frame.current, E, 12)
    end)
    if ok then frame.elv = E end
end

local function SkinRatingEUI(S)
    S.Shell(frame)
    if frame.CloseButton then S.CloseButton(frame.CloseButton) end
    for _, b in pairs(frame.tagButtons) do
        S.Button(b)
        if b:GetFontString() then S.Font(b:GetFontString()) end
    end
    for _, b in ipairs({ frame.send, frame.delete }) do
        S.Button(b)
        S.StateButtonLabel(b)   -- white when usable, grey when disabled
        if b:GetFontString() then S.Font(b:GetFontString()) end
    end
    S.Font(frame.title)
    S.Font(frame.current)
    frame.eui = S
    -- Accent color changes live: recolor the selected tags
    S.OnLooksChanged(function() if frame:IsShown() then UpdateTags() end end)
    UpdateTags()
end

local function BuildFrame()
    frame = CreateFrame("Frame", "NameScoreFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(340, 204)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:Hide()
    tinsert(UISpecialFrames, "NameScoreFrame") -- ESC closes the window

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOPLEFT", 10, -5)
    frame.title:SetPoint("TOPRIGHT", -30, -5)
    frame.title:SetWordWrap(false)

    frame.current = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.current:SetPoint("TOP", 0, -32)

    -- 5 stars; clicking the left half of a star gives a half star
    frame.stars = {}
    for i = 1, 5 do
        local star = CreateFrame("Frame", nil, frame)
        star:SetSize(STAR_SIZE, STAR_SIZE)
        star:SetPoint("TOP", frame, "TOP", (i - 3) * 42, -50)

        star.off = star:CreateTexture(nil, "ARTWORK")
        star.off:SetAllPoints()
        star.off:SetTexture(STAR_TEX)
        star.off:SetDesaturated(true)
        star.off:SetAlpha(0.35)

        star.on = star:CreateTexture(nil, "OVERLAY")
        star.on:SetPoint("TOPLEFT")
        star.on:SetHeight(STAR_SIZE)
        star.on:SetTexture(STAR_TEX)

        -- Two invisible click areas: left half = x.5, right half = full star
        for side = 1, 2 do
            local value = (i - 1) * 2 + side          -- in half stars
            local b = CreateFrame("Button", nil, star)
            b:SetSize(STAR_SIZE / 2, STAR_SIZE)
            b:SetPoint(side == 1 and "LEFT" or "RIGHT")
            b:SetScript("OnClick", function()
                state.half = value
                UpdateStars()
            end)
            b:SetScript("OnEnter", function()
                local stars = value / 2
                GameTooltip:SetOwner(star, "ANCHOR_TOP")
                GameTooltip:SetText(ns.FormatStars(stars) .. " " .. ns.Plural(stars, L.STAR, L.STARS))
                GameTooltip:Show()
            end)
            b:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end
        frame.stars[i] = star
    end

    -- Tags (multiple allowed)
    frame.tagButtons = {}
    for i, tag in ipairs(ns.TAGS) do
        local b = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        -- 4 tags in the first row, the rest centered in the second
        local row, col = math.floor((i - 1) / 4), (i - 1) % 4
        local inRow = math.min(4, #ns.TAGS - row * 4)
        local startX = (340 - (inRow * 76 + (inRow - 1) * 4)) / 2
        b:SetSize(76, 22)
        b:SetPoint("TOPLEFT", frame, "TOPLEFT", startX + col * 80, -98 - row * 26)
        b:SetText(ns.TagLabel(tag))
        b:SetScript("OnClick", function()
            state.tags[tag] = not state.tags[tag] or nil
            UpdateTags()
        end)
        frame.tagButtons[tag] = b
    end

    frame.send = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.send:SetSize(218, 28)
    frame.send:SetPoint("BOTTOMLEFT", 15, 16)
    frame.send:SetText(L.SUBMIT)
    frame.send:SetScript("OnClick", function()
        ns.Rate(frame.target, state.half / 2, state.tags)
        frame:Hide()
    end)

    frame.delete = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.delete:SetSize(88, 28)
    frame.delete:SetPoint("BOTTOMRIGHT", -15, 16)
    frame.delete:SetText(L.DELETE)
    frame.delete:SetScript("OnClick", function()
        ns.DeleteVote(frame.target)
        frame:Hide()
    end)

    if ns.HasEUI() then
        ns.WhenEUI(SkinRatingEUI)
    else
        ApplyElvUISkin()
    end
end

function ns.OpenRating(key)
    if not key then ns.Print(L.NO_TARGET) return end
    local reason = ns.OwnReason(key)
    if reason then ns.Print(reason) return end
    if not frame then BuildFrame() end

    frame.target = key
    state.half, state.tags = 0, {}
    local mine = ns.MyVote(key)
    if mine then
        state.half = mine.s
        for t in pairs(mine.tags or {}) do state.tags[t] = true end
    end

    local kind = ns.ParseKey(key)
    local title = ns.ShortName(key)
    if kind == "guild" then title = L.GUILD_LABEL .. " " .. title end
    frame.title:SetText(title)
    frame.current:SetText(string.format(L.CURRENT, ns.ScoreLine(key)))
    frame.delete:SetEnabled(mine ~= nil)
    UpdateStars()
    UpdateTags()
    frame:Show()
end

-- ---------------------------------------------------------------
-- Right-click menu entries on player and pet menus
-- ---------------------------------------------------------------
local MENU_TAGS = {
    "MENU_UNIT_PLAYER",                    -- players in the world
    "MENU_UNIT_TARGET",                    -- target frame (players and pets)
    "MENU_UNIT_FOCUS",                     -- focus frame
    "MENU_UNIT_PARTY",                     -- party frames
    "MENU_UNIT_RAID_PLAYER",               -- raid frames
    "MENU_UNIT_ENEMY_PLAYER",              -- players of the other faction
    "MENU_UNIT_FRIEND",                    -- names in chat
    "MENU_UNIT_GUILD",                     -- guild roster
    "MENU_UNIT_COMMUNITIES_GUILD_MEMBER",  -- guild & communities window
    "MENU_UNIT_COMMUNITIES_WOW_MEMBER",
    "MENU_UNIT_OTHERPET",                  -- other players' pets
    "MENU_UNIT_PARTYPET",                  -- pets of party members
    "MENU_UNIT_RAID_PET",                  -- pets in the raid
}

-- Works out what the menu was opened for: from the unit if it is readable,
-- otherwise from the name the menu was opened for (chat, guild roster)
local function MenuKeys(ctx)
    if not ctx then return nil end
    local unit = ctx.unit
    if unit and not IsSecret(unit) and UnitExists(unit) then
        local key = ns.UnitKey(unit)
        if key then return key, ns.UnitGuildKey(unit) end
        if not UnitIsPlayer(unit) then return nil end
    end
    local name, server = ctx.name, ctx.server
    if IsSecret(name) or IsSecret(server) or type(name) ~= "string" then return nil end
    return ns.FullName(name, server), nil
end

local function AddMenuEntry(owner, rootDescription, contextData)
    if not ns.me then return end
    local ok, key, guildKey = pcall(MenuKeys, contextData)
    if not ok then return end
    local rateName = key and not ns.OwnReason(key)
    local rateGuild = guildKey and not ns.OwnReason(guildKey)
    if not rateName and not rateGuild then return end

    rootDescription:CreateDivider()
    rootDescription:CreateTitle("NameScore")
    if rateName then
        rootDescription:CreateButton(L.MENU_RATE, function() ns.OpenRating(key) end)
    end
    if rateGuild then
        rootDescription:CreateButton(L.MENU_RATE_GUILD, function() ns.OpenRating(guildKey) end)
    end
end

if Menu and Menu.ModifyMenu then
    for _, tag in ipairs(MENU_TAGS) do
        Menu.ModifyMenu(tag, AddMenuEntry)
    end
end
