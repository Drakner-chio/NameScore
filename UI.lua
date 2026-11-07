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

    -- Compact badge, two tooltip lines high:
    -- [score] RANK · tags ............ n votes
    -- [     ] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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
    badge.votes:SetText(n .. " " .. ns.Plural(n, L.VOTE, L.VOTES))
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
    if tt.SetMinimumWidth then tt:SetMinimumWidth(220) end
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
        ns.Rate(frame.target, state.half / 2, state.tags)
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
    state.half, state.tags = 0, {}
    local mine = ns.MyVote(target)
    if mine then
        state.half = mine.s
        for t in pairs(mine.tags or {}) do state.tags[t] = true end
    end

    frame.title:SetText(ns.ShortName(target))
    frame.current:SetText(string.format(L.CURRENT, ns.ScoreLine(target)))
    UpdateStars()
    UpdateTags()
    frame:Show()
end
