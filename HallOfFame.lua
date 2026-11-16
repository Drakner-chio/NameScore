-- NameScore hall of fame: best and worst rated names, and your own votes
local _, ns = ...
local L = ns.L

local ROWS = 15
local MIN_ROWS = 4          -- the window never gets smaller than this many rows
local ROW_TOP, ROW_H, BOTTOM = 60, 21, 45
local STAR_INLINE = "|TInterface\\AddOns\\NameScore\\media\\Star:0|t"
local KIND_COLOR = { player = "ffffff", guild = "40c040", pet = "c8a070" }

local hall
local currentTab = "top"

-- Entries for one tab: { key, avg, n, mine }
local function Collect(tab)
    local list = {}
    local min = ns.MinVotes()
    for key in pairs(ns.db.votes) do
        local avg, n = ns.GetScore(key)
        local mine = ns.MyVote(key)
        if tab == "mine" then
            if mine and not ns.IsOptedOut(key) then list[#list + 1] = { key = key, avg = avg, n = n, mine = mine } end
        elseif avg and n >= min then
            list[#list + 1] = { key = key, avg = avg, n = n, mine = mine }
        end
    end
    -- Ties: more votes first, then alphabetically, so the order never jumps
    if tab == "top" then
        table.sort(list, function(a, b)
            if a.avg ~= b.avg then return a.avg > b.avg end
            if a.n ~= b.n then return a.n > b.n end
            return ns.ShortName(a.key) < ns.ShortName(b.key)
        end)
    elseif tab == "flop" then
        table.sort(list, function(a, b)
            if a.avg ~= b.avg then return a.avg < b.avg end
            if a.n ~= b.n then return a.n > b.n end
            return ns.ShortName(a.key) < ns.ShortName(b.key)
        end)
    else
        table.sort(list, function(a, b) return a.mine.ts > b.mine.ts end)
    end
    return list
end

-- The window is only as tall as the rows it shows. Its top edge stays where it
-- is, so switching tabs doesn't make the window jump.
local function FitHeight(rows)
    rows = math.max(MIN_ROWS, math.min(ROWS, rows))
    hall:SetHeight(ROW_TOP + rows * ROW_H + BOTTOM)
end

-- After dragging: anchor at the top left corner, so height changes grow downwards
local function PinTop()
    local left, top = hall:GetLeft(), hall:GetTop()
    if not left or not top then return end
    hall:ClearAllPoints()
    hall:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
end

-- "Judges" tab: who rated the most names (shared counts + ourselves)
local function RefreshJudges()
    local list = ns.JudgeList()
    for i, row in ipairs(hall.rows) do
        local j = list[i]
        row.key = nil
        row.judge = j
        if j then
            local r = ns.JudgeRank(j.n)
            row.pos:SetText(i)
            local name = ns.ShortName(j.name)
            if j.me then name = "|cffffd100" .. name .. "|r" end
            row.name:SetText(ns.JudgeIcon(r, 14) .. " " .. name)
            row.score:SetText("|cffaaaaaa" .. j.n .. "|r")
            row:Show()
        else
            row:Hide()
        end
    end
    hall.empty:SetShown(#list == 0)
    FitHeight(#list)
end

-- "Me" tab: your own name, guild and pets as plain text lines (not clickable)
local function RefreshMe()
    local lines = ns.MyStatsLines()
    -- Own judge rank on top
    local n, f = ns.MyJudgeCount(), ns.MyFaction()
    local r = ns.JudgeRank(n)
    table.insert(lines, 1, { r > 0 and (ns.JudgeIcon(r, 14) .. " |cffffd100" .. ns.JudgeName(r, f) .. "|r") or ("|cffaaaaaa" .. L.JUDGE_NONE .. "|r"),
        r > 0 and ("|cffaaaaaa" .. n .. "|r") or "" })
    table.insert(lines, 2, { "   |cffaaaaaa" .. ns.JudgeNextText(n, f) .. "|r", "" })
    for i, row in ipairs(hall.rows) do
        local line = lines[i]
        row.key = nil
        row.judge = nil
        if line then
            row.pos:SetText("")
            row.name:SetText(line[1])
            row.score:SetText(line[2])
            row:Show()
        else
            row:Hide()
        end
    end
    hall.empty:SetShown(false)
    FitHeight(#lines)
end

local function Refresh()
    local special = currentTab == "me" or currentTab == "judges"
    if currentTab == "me" then RefreshMe() end
    if currentTab == "judges" then RefreshJudges() end
    local list = special and {} or Collect(currentTab)
    for i, row in ipairs(hall.rows) do
        if special then break end
        row.judge = nil
        local e = list[i]
        if e then
            local kind = ns.ParseKey(e.key)
            row.key = e.key
            row.pos:SetText(i)
            row.name:SetText("|cff" .. KIND_COLOR[kind] .. ns.ShortName(e.key) .. "|r")
            if currentTab == "mine" then
                local right = STAR_INLINE .. " " .. ns.FormatStars(e.mine.s / 2)
                if e.avg and e.n >= ns.MinVotes() then
                    right = string.format("|cff%s%.1f|r  ", ns.Rank(e.avg).hex, e.avg) .. right
                end
                row.score:SetText(right)
            else
                local r = ns.Rank(e.avg)
                row.score:SetText(string.format("|cffaaaaaa%d|r  |cff%s%.1f|r", e.n, r.hex, e.avg))
            end
            row:Show()
        else
            row.key = nil
            row:Hide()
        end
    end
    if not special then
        hall.empty:SetShown(#list == 0)
        FitHeight(#list)
    end

    for tab, b in pairs(hall.tabs) do
        if hall.eui then
            -- EllesmereUI: active tab label in the user's accent color
            local fs = b:GetFontString()
            if fs then
                if tab == currentTab then fs:SetTextColor(hall.eui.GetAccentColor()) else fs:SetTextColor(0.7, 0.7, 0.7) end
            end
        elseif tab == currentTab then
            b:LockHighlight()
        else
            b:UnlockHighlight()
        end
    end
    if currentTab == "mine" then
        hall.footer:SetText(L.HALL_FOOTER_MINE)
    elseif currentTab == "me" then
        hall.footer:SetText(L.ME_FOOTER)
    elseif currentTab == "judges" then
        hall.footer:SetText(string.format(L.JUDGE_FOOTER, ns.JudgeNextText(ns.MyJudgeCount(), ns.MyFaction())))
    else
        hall.footer:SetText(string.format(L.HALL_FOOTER, ns.MinVotes(), ns.CountVotes()))
    end
end

local function Build()
    hall = CreateFrame("Frame", "NameScoreHallFrame", UIParent, "BasicFrameTemplateWithInset")
    hall:SetSize(340, ROW_TOP + ROWS * ROW_H + BOTTOM)
    -- Anchored at the top: the window grows and shrinks downwards
    hall:SetPoint("TOP", UIParent, "CENTER", 200, (ROW_TOP + ROWS * ROW_H + BOTTOM) / 2)
    hall:SetMovable(true)
    hall:EnableMouse(true)
    hall:SetClampedToScreen(true)
    hall:RegisterForDrag("LeftButton")
    hall:SetScript("OnDragStart", hall.StartMoving)
    hall:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        PinTop()
    end)
    hall:SetFrameStrata("DIALOG")
    hall:Hide()
    tinsert(UISpecialFrames, "NameScoreHallFrame") -- ESC closes the window

    hall.title = hall:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    hall.title:SetPoint("TOP", 0, -5)
    hall.title:SetText(L.HALL_TITLE)

    -- Tabs
    hall.tabs = {}
    local tabs = { { "top", L.TAB_TOP }, { "flop", L.TAB_FLOP }, { "mine", L.TAB_MINE }, { "me", L.TAB_ME }, { "judges", L.TAB_JUDGES } }
    for i, t in ipairs(tabs) do
        local b = CreateFrame("Button", nil, hall, "UIPanelButtonTemplate")
        b:SetSize(60, 22)
        b:SetPoint("TOPLEFT", 12 + (i - 1) * 63, -30)
        b:SetText(t[2])
        b:SetScript("OnClick", function()
            currentTab = t[1]
            Refresh()
        end)
        hall.tabs[t[1]] = b
    end

    -- Rows: click opens the rating window for that name
    hall.rows = {}
    for i = 1, ROWS do
        local row = CreateFrame("Button", nil, hall)
        row:SetSize(312, 20)
        row:SetPoint("TOPLEFT", 14, -60 - (i - 1) * 21)
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

        row.pos = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.pos:SetPoint("LEFT", 2, 0)
        row.pos:SetWidth(22)
        row.pos:SetJustifyH("LEFT")

        row.score = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.score:SetPoint("RIGHT", -2, 0)
        row.score:SetJustifyH("RIGHT")

        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.name:SetPoint("LEFT", row.pos, "RIGHT", 4, 0)
        row.name:SetPoint("RIGHT", row.score, "LEFT", -8, 0)
        row.name:SetJustifyH("LEFT")
        row.name:SetWordWrap(false)

        row:SetScript("OnClick", function(self)
            if self.key then ns.OpenRating(self.key) end
        end)
        -- Judges tab: full rank name and the next rank on hover
        row:SetScript("OnEnter", function(self)
            local j = self.judge
            if not j then return end
            local r = ns.JudgeRank(j.n)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(ns.ShortName(j.name), 1, 1, 1)
            GameTooltip:AddLine(ns.JudgeIcon(r, 16) .. " " .. ns.JudgeName(r, j.f), 1, 0.82, 0)
            GameTooltip:AddLine(string.format(L.JUDGE_COUNT, j.n), 0.7, 0.7, 0.7)
            GameTooltip:AddLine(ns.JudgeNextText(j.n, j.f), 0.7, 0.7, 0.7)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        hall.rows[i] = row
    end

    hall.empty = hall:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    hall.empty:SetPoint("TOP", 0, -100)
    hall.empty:SetText(L.HALL_EMPTY)

    hall.footer = hall:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hall.footer:SetPoint("BOTTOM", 0, 12)
    hall.footer:SetWidth(316)

    -- Refresh when opened again, so new votes show up
    hall:SetScript("OnShow", Refresh)

    -- EllesmereUI look (official skinning API)
    if ns.HasEUI() then
        ns.WhenEUI(function(S)
            S.Shell(hall)
            if hall.CloseButton then S.CloseButton(hall.CloseButton) end
            for _, b in pairs(hall.tabs) do
                S.Button(b)
                if b:GetFontString() then S.Font(b:GetFontString()) end
            end
            S.Font(hall.title)
            S.Font(hall.empty)
            S.Font(hall.footer)
            for _, row in ipairs(hall.rows) do
                S.Font(row.pos)
                S.Font(row.name)
                S.Font(row.score)
            end
            hall.eui = S
            S.OnLooksChanged(function() if hall:IsShown() then Refresh() end end)
        end)
    end

    -- ElvUI look
    local E, S = ns.GetElvUI()
    if E and S then
        pcall(function()
            if hall.StripTextures then hall:StripTextures() end
            hall:SetTemplate("Transparent")
            if hall.CloseButton then S:HandleCloseButton(hall.CloseButton) end
            for _, b in pairs(hall.tabs) do S:HandleButton(b) end
            ns.ElvFont(hall.title, E, 14)
        end)
    end
end

function ns.ToggleHall()
    if not hall then Build() end
    if hall:IsShown() then hall:Hide() else hall:Show() end
end
