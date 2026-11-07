-- NameScore UI: tooltip badge, rating window with stars & tags, ElvUI skin
local ADDON_NAME, ns = ...
local L = ns.L

local STAR_TEX = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1"

-- ---------------------------------------------------------------
-- ElvUI detection (optional)
-- ---------------------------------------------------------------
local function GetElvUI()
    if not ElvUI then return nil end
    local ok, E = pcall(function() return unpack(ElvUI) end)
    if not ok or not E then return nil end
    local okS, S = pcall(E.GetModule, E, "Skins")
    return E, (okS and S) or nil
end

local function ElvFont(fs, E, size)
    if E and E.media and E.media.normFont then
        fs:SetFont(E.media.normFont, size, "OUTLINE")
    end
end

-- ---------------------------------------------------------------
-- Tooltip badge
-- ---------------------------------------------------------------
local badge

local function CreateBadge()
    local E = GetElvUI()

    badge = CreateFrame("Frame", nil, GameTooltip)
    badge:SetHeight(40)

    -- Square with the score, border in rank color.
    -- Built from plain textures on purpose: Blizzard's BackdropTemplate does
    -- Lua math on the frame size, which is a secret value inside a tooltip in
    -- dungeons and throws an error on every resize.
    badge.box = CreateFrame("Frame", nil, badge)
    badge.box:SetSize(38, 38)
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

    badge.score = badge.box:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    badge.score:SetPoint("CENTER", 0, 0)

    badge.rank = badge:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    badge.rank:SetPoint("TOPLEFT", badge.box, "TOPRIGHT", 8, -1)

    badge.votes = badge:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    badge.votes:SetPoint("TOPRIGHT", badge, "TOPRIGHT", 0, -2)

    badge.bar = CreateFrame("StatusBar", nil, badge)
    badge.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    badge.bar:SetMinMaxValues(0, 10)
    badge.bar:SetHeight(6)
    badge.bar:SetPoint("LEFT", badge.box, "RIGHT", 8, 0)
    badge.bar:SetPoint("RIGHT", badge, "RIGHT", 0, 0)
    badge.bar.bg = badge.bar:CreateTexture(nil, "BACKGROUND")
    badge.bar.bg:SetAllPoints()
    badge.bar.bg:SetColorTexture(0.16, 0.17, 0.21, 1)

    badge.tags = badge:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    badge.tags:SetPoint("BOTTOMLEFT", badge.box, "BOTTOMRIGHT", 8, 1)

    if E then
        if E.media.normTex then badge.bar:SetStatusBarTexture(E.media.normTex) end
        ElvFont(badge.score, E, 16)
        ElvFont(badge.rank, E, 13)
        ElvFont(badge.votes, E, 11)
        ElvFont(badge.tags, E, 11)
    end

    badge:Hide()
end

local function HideBadge(tt)
    if badge then badge:Hide() end
    if tt and tt.SetMinimumWidth then tt:SetMinimumWidth(0) end
end

-- In instances the game can hide unit data behind "secret values";
-- those must not be used in string operations, so we skip them.
-- Note: no comparisons on the value itself, they are not allowed on secrets.
local function IsSecret(v)
    return issecretvalue ~= nil and issecretvalue(v) == true
end

local function AddToTooltip(tt, unit)
    -- In dungeons the tooltip's unit token can be secret; the plain
    -- "mouseover" token points to the same player and may still be readable
    if IsSecret(unit) or not unit then unit = "mouseover" end
    if not ns.db or not ns.me or not UnitExists(unit) or not UnitIsPlayer(unit) then return end
    local name, realm = UnitName(unit)
    if IsSecret(name) or IsSecret(realm) then return end
    if type(name) ~= "string" then return end
    local target = ns.FullName(name, realm)
    if not target then return end

    local avg, n, tags = ns.GetScore(target)
    if not avg then
        tt:AddLine("|cffff8000NameScore|r |cff777777– " .. L.NOT_RATED .. "|r")
        tt:Show()
        return
    end

    if not badge then CreateBadge() end
    local r = ns.Rank(avg)
    local cr, cg, cb = ns.HexToRGB(r.hex)

    badge.score:SetText(string.format("%.1f", avg))
    badge.score:SetTextColor(cr, cg, cb)
    for _, edge in ipairs(badge.box.edges) do edge:SetColorTexture(cr, cg, cb, 1) end
    badge.rank:SetText(r.label:upper())
    badge.rank:SetTextColor(cr, cg, cb)
    badge.votes:SetText(n .. " " .. ns.Plural(n, L.VOTE, L.VOTES))
    badge.bar:SetValue(avg)
    badge.bar:SetStatusBarColor(cr, cg, cb)

    local parts = {}
    for i = 1, math.min(#tags, 3) do
        local label = ns.TagLabel(tags[i].tag)
        parts[#parts + 1] = (i == 1) and ("|cffffd100" .. label .. "|r") or label
    end
    if #parts > 0 then
        badge.tags:SetText(table.concat(parts, "  ·  "))
    else
        badge.tags:SetText("|cff777777" .. L.NO_TAGS .. "|r")
    end

    -- Reserve space in the tooltip (4 lines leave room below for other addons)
    -- and place the badge on top of it
    for _ = 1, 4 do tt:AddLine(" ") end
    local first = _G[tt:GetName() .. "TextLeft" .. (tt:NumLines() - 3)]
    badge:SetParent(tt)
    badge:SetFrameLevel(tt:GetFrameLevel() + 5)
    badge:ClearAllPoints()
    badge:SetPoint("TOPLEFT", first, "TOPLEFT", 0, -2)
    badge:SetPoint("RIGHT", tt, "RIGHT", -10, 0)
    if tt.SetMinimumWidth then tt:SetMinimumWidth(230) end
    badge:Show()
    tt:Show()
end

-- A tooltip error must never spam the player: catch it, hide the badge
-- and report only the first one per session so it can be fixed.
local errorReported = false
local function SafeAddToTooltip(tt)
    local ok, err = pcall(function()
        local _, unit = tt:GetUnit()
        AddToTooltip(tt, unit)
    end)
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
local state = { stars = 0, tags = {} }

local function UpdateStars()
    for i, b in ipairs(frame.stars) do
        local on = i <= state.stars
        b.tex:SetDesaturated(not on)
        b.tex:SetAlpha(on and 1 or 0.35)
    end
    frame.send:SetEnabled(state.stars > 0)
end

local function UpdateTags()
    for tag, b in pairs(frame.tagButtons) do
        local on = state.tags[tag]
        local fs = b:GetFontString()
        if fs then
            if on then fs:SetTextColor(1, 0.82, 0) else fs:SetTextColor(0.75, 0.75, 0.75) end
        end
        if frame.elv and b.SetBackdropBorderColor then
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
        ElvFont(frame.title, E, 14)
        ElvFont(frame.current, E, 12)
    end)
    if ok then frame.elv = E end
end

local function BuildFrame()
    frame = CreateFrame("Frame", "NameScoreFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(300, 200)
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
    frame.title:SetPoint("TOP", 0, -5)

    frame.current = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.current:SetPoint("TOP", 0, -32)

    -- 5 stars
    frame.stars = {}
    for i = 1, 5 do
        local b = CreateFrame("Button", nil, frame)
        b:SetSize(36, 36)
        b:SetPoint("TOP", frame, "TOP", (i - 3) * 42, -50)
        b.tex = b:CreateTexture(nil, "ARTWORK")
        b.tex:SetAllPoints()
        b.tex:SetTexture(STAR_TEX)
        b:SetScript("OnClick", function()
            state.stars = i
            UpdateStars()
        end)
        b:SetScript("OnEnter", function()
            GameTooltip:SetOwner(b, "ANCHOR_TOP")
            GameTooltip:SetText(i .. " " .. ns.Plural(i, L.STAR, L.STARS))
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function() GameTooltip:Hide() end)
        frame.stars[i] = b
    end

    -- Tags (multiple allowed)
    frame.tagButtons = {}
    for i, tag in ipairs(ns.TAGS) do
        local b = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        b:SetSize(64, 22)
        b:SetPoint("TOPLEFT", frame, "TOPLEFT", 14 + (i - 1) * 68, -100)
        b:SetText(ns.TagLabel(tag))
        b:SetScript("OnClick", function()
            state.tags[tag] = not state.tags[tag] or nil
            UpdateTags()
        end)
        frame.tagButtons[tag] = b
    end

    frame.send = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.send:SetSize(270, 28)
    frame.send:SetPoint("BOTTOM", 0, 16)
    frame.send:SetText(L.SUBMIT)
    frame.send:SetScript("OnClick", function()
        ns.Rate(frame.target, state.stars, state.tags)
        frame:Hide()
    end)

    ApplyElvUISkin()
end

-- ---------------------------------------------------------------
-- Right-click menu entry ("NameScore > Rate name") on player menus
-- ---------------------------------------------------------------
local MENU_TAGS = {
    "MENU_UNIT_PLAYER",                    -- players in the world
    "MENU_UNIT_TARGET",                    -- target frame
    "MENU_UNIT_FOCUS",                     -- focus frame
    "MENU_UNIT_PARTY",                     -- party frames
    "MENU_UNIT_RAID_PLAYER",               -- raid frames
    "MENU_UNIT_ENEMY_PLAYER",              -- players of the other faction
    "MENU_UNIT_FRIEND",                    -- names in chat
    "MENU_UNIT_GUILD",                     -- guild roster
    "MENU_UNIT_COMMUNITIES_GUILD_MEMBER",  -- guild & communities window
    "MENU_UNIT_COMMUNITIES_WOW_MEMBER",
}

-- Works out the player key from a menu's context: from the unit if it is
-- readable, otherwise from the name the menu was opened for
local function MenuTargetKey(ctx)
    if not ctx then return nil end
    local unit = ctx.unit
    if unit and not IsSecret(unit) and UnitExists(unit) then
        if not UnitIsPlayer(unit) then return nil end
        local name, realm = UnitName(unit)
        if not IsSecret(name) and not IsSecret(realm) and type(name) == "string" then
            return ns.FullName(name, realm)
        end
    end
    local name, server = ctx.name, ctx.server
    if IsSecret(name) or IsSecret(server) or type(name) ~= "string" then return nil end
    return ns.FullName(name, server)
end

local function AddMenuEntry(owner, rootDescription, contextData)
    local ok, key = pcall(MenuTargetKey, contextData)
    if not ok or not key or not ns.me or key:lower() == ns.me:lower() then return end
    rootDescription:CreateDivider()
    rootDescription:CreateTitle("NameScore")
    rootDescription:CreateButton(L.MENU_RATE, function() ns.OpenRating(key) end)
end

if Menu and Menu.ModifyMenu then
    for _, tag in ipairs(MENU_TAGS) do
        Menu.ModifyMenu(tag, AddMenuEntry)
    end
end

function ns.OpenRating(target)
    if not target then ns.Print(L.NO_TARGET) return end
    if target == ns.me then ns.Print(L.NO_SELF) return end
    if not frame then BuildFrame() end

    frame.target = target
    state.stars, state.tags = 0, {}
    local mine = ns.MyVote(target)
    if mine then
        state.stars = math.floor(mine.s / 2 + 0.5)
        for t in pairs(mine.tags or {}) do state.tags[t] = true end
    end

    frame.title:SetText(ns.ShortName(target))
    frame.current:SetText(string.format(L.CURRENT, ns.ScoreLine(target)))
    UpdateStars()
    UpdateTags()
    frame:Show()
end
