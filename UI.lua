-- NameScore UI: Abzeichen im Tooltip, Bewertungsfenster mit Sternen & Tags, ElvUI-Skin
local ADDON_NAME, ns = ...

local BACKDROP_TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil
local WHITE = "Interface\\Buttons\\WHITE8x8"
local STAR_TEX = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1"

-- ---------------------------------------------------------------
-- ElvUI erkennen (optional)
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
-- Tooltip-Abzeichen (Variante B)
-- ---------------------------------------------------------------
local badge

local function CreateBadge()
    local E = GetElvUI()

    badge = CreateFrame("Frame", nil, GameTooltip)
    badge:SetHeight(40)

    -- Quadrat mit Score, Rahmen in Rangfarbe
    badge.box = CreateFrame("Frame", nil, badge, BACKDROP_TEMPLATE)
    badge.box:SetSize(38, 38)
    badge.box:SetPoint("LEFT")
    badge.box:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 2 })
    badge.box:SetBackdropColor(0, 0, 0, 0.6)

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

local function AddToTooltip(tt, unit)
    unit = unit or "mouseover"
    if not ns.db or not UnitExists(unit) or not UnitIsPlayer(unit) then return end
    local name, realm = UnitName(unit)
    local target = ns.FullName(name, realm)
    if not target then return end

    local avg, n, tags = ns.GetScore(target)
    if not avg then
        tt:AddLine("|cffff8000NameScore|r |cff777777– noch nicht bewertet|r")
        tt:Show()
        return
    end

    if not badge then CreateBadge() end
    local r = ns.Rank(avg)
    local cr, cg, cb = ns.HexToRGB(r.hex)

    badge.score:SetText(string.format("%.1f", avg))
    badge.score:SetTextColor(cr, cg, cb)
    badge.box:SetBackdropBorderColor(cr, cg, cb, 1)
    badge.rank:SetText(r.label:upper())
    badge.rank:SetTextColor(cr, cg, cb)
    badge.votes:SetText(n .. (n == 1 and " Stimme" or " Stimmen"))
    badge.bar:SetValue(avg)
    badge.bar:SetStatusBarColor(cr, cg, cb)

    local parts = {}
    for i = 1, math.min(#tags, 3) do
        local label = ns.TAG_LABEL[tags[i].tag]
        parts[#parts + 1] = (i == 1) and ("|cffffd100" .. label .. "|r") or label
    end
    badge.tags:SetText(table.concat(parts, "  ·  "))

    -- Platz im Tooltip reservieren und das Abzeichen darüberlegen
    tt:AddLine(" ")
    tt:AddLine(" ")
    tt:AddLine(" ")
    local first = _G[tt:GetName() .. "TextLeft" .. (tt:NumLines() - 2)]
    badge:SetParent(tt)
    badge:SetFrameLevel(tt:GetFrameLevel() + 5)
    badge:ClearAllPoints()
    badge:SetPoint("TOPLEFT", first, "TOPLEFT", 0, -2)
    badge:SetPoint("RIGHT", tt, "RIGHT", -10, 0)
    if tt.SetMinimumWidth then tt:SetMinimumWidth(230) end
    badge:Show()
    tt:Show()
end

if TooltipDataProcessor and Enum and Enum.TooltipDataType then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tt)
        if tt ~= GameTooltip then return end
        local _, unit = tt:GetUnit()
        AddToTooltip(tt, unit)
    end)
else
    GameTooltip:HookScript("OnTooltipSetUnit", function(tt)
        local _, unit = tt:GetUnit()
        AddToTooltip(tt, unit)
    end)
end
GameTooltip:HookScript("OnTooltipCleared", HideBadge)
GameTooltip:HookScript("OnHide", HideBadge)

-- ---------------------------------------------------------------
-- Bewertungsfenster (Variante B: Sterne & Tags)
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
    tinsert(UISpecialFrames, "NameScoreFrame") -- ESC schließt

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", 0, -5)

    frame.current = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.current:SetPoint("TOP", 0, -32)

    -- 5 Sterne
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
            GameTooltip:SetText(i .. (i == 1 and " Stern" or " Sterne"))
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function() GameTooltip:Hide() end)
        frame.stars[i] = b
    end

    -- Tags (mehrere möglich)
    frame.tagButtons = {}
    for i, tag in ipairs(ns.TAGS) do
        local b = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        b:SetSize(64, 22)
        b:SetPoint("TOPLEFT", frame, "TOPLEFT", 14 + (i - 1) * 68, -100)
        b:SetText(ns.TAG_LABEL[tag])
        b:SetScript("OnClick", function()
            state.tags[tag] = not state.tags[tag] or nil
            UpdateTags()
        end)
        frame.tagButtons[tag] = b
    end

    frame.send = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.send:SetSize(270, 28)
    frame.send:SetPoint("BOTTOM", 0, 16)
    frame.send:SetText("Senden")
    frame.send:SetScript("OnClick", function()
        ns.Rate(frame.target, state.stars, state.tags)
        frame:Hide()
    end)

    ApplyElvUISkin()
end

function ns.OpenRating(target)
    if not target then ns.Print("Ziele zuerst einen Spieler an.") return end
    if target == ns.me then ns.Print("Den eigenen Namen bewerten zählt nicht. ;)") return end
    if not frame then BuildFrame() end

    frame.target = target
    state.stars, state.tags = 0, {}
    local mine = ns.MyVote(target)
    if mine then
        state.stars = math.floor(mine.s / 2 + 0.5)
        for t in pairs(mine.tags or {}) do state.tags[t] = true end
    end

    frame.title:SetText(ns.ShortName(target))
    frame.current:SetText("Aktuell: " .. ns.ScoreLine(target))
    UpdateStars()
    UpdateTags()
    frame:Show()
end
