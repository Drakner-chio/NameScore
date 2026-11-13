-- NameScore minimap button (LibDataBroker + LibDBIcon) and addon compartment entry.
-- The libraries are added by the release packager (.pkgmeta externals). Without
-- them (e.g. a plain GitHub download) the minimap button is simply missing, the
-- addon compartment entry and /ns top still work.
local _, ns = ...
local L = ns.L

local ICON = "Interface\\AddOns\\NameScore\\media\\Icon"
local DBIcon

local function OnClick(button)
    if button == "RightButton" then ns.OpenOptions() else ns.ToggleHall() end
end

local function FillTooltip(tt)
    tt:AddLine("|cffff8000NameScore|r")
    tt:AddLine(L.MM_LEFT, 1, 1, 1)
    tt:AddLine(L.MM_RIGHT, 1, 1, 1)
    if ns.db then
        tt:AddLine(string.format(L.MM_VOTES, ns.CountVotes()), 0.6, 0.6, 0.6)
        local users = ns.GuildCountText()
        if users then tt:AddLine(users, 0.6, 0.6, 0.6, true) end
        if ns.newerVersion then
            tt:AddLine(string.format(L.MM_UPDATE, ns.newerVersion), 0.12, 1, 0)
        end
    end
end

-- Called once the saved variables are loaded
function ns.BuildMinimap()
    ns.db.minimap = ns.db.minimap or {}
    ns.db.minimap.hide = not ns.Setting("showMinimap")

    local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
    DBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
    if not LDB then return end

    local launcher = LDB:NewDataObject("NameScore", {
        type = "launcher",
        text = "NameScore",
        icon = ICON,
        OnClick = function(_, button) OnClick(button) end,
        OnTooltipShow = FillTooltip,
    })
    if DBIcon and launcher then
        DBIcon:Register("NameScore", launcher, ns.db.minimap)
    end
end

function ns.SetMinimapShown(show)
    ns.db.settings.showMinimap = show and true or false
    ns.db.minimap = ns.db.minimap or {}
    ns.db.minimap.hide = not show
    if DBIcon then
        if show then DBIcon:Show("NameScore") else DBIcon:Hide("NameScore") end
    end
end

-- Addon compartment (the addon menu at the minimap); registered in the .toc
function NameScore_OnAddonCompartmentClick(_, button)
    OnClick(button)
end

function NameScore_OnAddonCompartmentEnter(_, menuButtonFrame)
    GameTooltip:SetOwner(menuButtonFrame, "ANCHOR_LEFT")
    FillTooltip(GameTooltip)
    GameTooltip:Show()
end

function NameScore_OnAddonCompartmentLeave()
    GameTooltip:Hide()
end
