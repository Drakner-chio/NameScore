-- NameScore settings: panel in the game's options menu (Esc > Options > AddOns)
-- with a chat fallback if the panel API is not available.
local _, ns = ...
local L = ns.L

local category

function ns.BuildOptions()
    if not (Settings and Settings.RegisterVerticalLayoutCategory and Settings.RegisterAddOnSetting) then
        return
    end
    local s = ns.db.settings
    local cat = Settings.RegisterVerticalLayoutCategory("NameScore")

    local function Checkbox(key, label, tip)
        local setting = Settings.RegisterAddOnSetting(cat, "NameScore_" .. key, key, s,
            Settings.VarType.Boolean, label, ns.DEFAULTS[key])
        Settings.CreateCheckbox(cat, setting, tip)
    end

    Checkbox("showBadge", L.OPT_BADGE, L.OPT_BADGE_TIP)
    Checkbox("showOwn", L.OPT_OWN, L.OPT_OWN_TIP)

    local sizeSetting = Settings.RegisterAddOnSetting(cat, "NameScore_badgeSize", "badgeSize", s,
        Settings.VarType.Number, L.OPT_SIZE, ns.DEFAULTS.badgeSize)
    local function SizeOptions()
        local c = Settings.CreateControlTextContainer()
        for size = 1, 3 do c:Add(size, ns.SizeLabel(size)) end
        return c:GetData()
    end
    local CreateDropdown = Settings.CreateDropdown or Settings.CreateDropDown
    CreateDropdown(cat, sizeSetting, SizeOptions, L.OPT_SIZE_TIP)

    local minSetting = Settings.RegisterAddOnSetting(cat, "NameScore_minVotes", "minVotes", s,
        Settings.VarType.Number, L.OPT_MIN, ns.DEFAULTS.minVotes)
    local sliderOptions = Settings.CreateSliderOptions(1, 5, 1)
    if MinimalSliderWithSteppersMixin and MinimalSliderWithSteppersMixin.Label then
        sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)
    end
    Settings.CreateSlider(cat, minSetting, sliderOptions, L.OPT_MIN_TIP)

    Checkbox("elvSkin", L.OPT_ELVUI, L.OPT_ELVUI_TIP)

    local mm = Settings.RegisterAddOnSetting(cat, "NameScore_showMinimap", "showMinimap", s,
        Settings.VarType.Boolean, L.OPT_MINIMAP, ns.DEFAULTS.showMinimap)
    Settings.CreateCheckbox(cat, mm, L.OPT_MINIMAP_TIP)
    if mm and mm.SetValueChangedCallback then
        mm:SetValueChangedCallback(function(_, value) ns.SetMinimapShown(value) end)
    end

    Settings.RegisterAddOnCategory(cat)
    category = cat
end

local function OnOff(v)
    return v and "|cff1eff00ON|r" or "|cffff4040OFF|r"
end

function ns.OpenOptions()
    if category and Settings and Settings.OpenToCategory then
        local ok = pcall(Settings.OpenToCategory, category:GetID())
        if ok then return end
    end
    -- Fallback: show the settings in chat with the commands to change them
    ns.Print(L.OPT_BADGE .. ": " .. OnOff(ns.Setting("showBadge")) .. "  (/ns badge)")
    ns.Print(L.OPT_OWN .. ": " .. OnOff(ns.Setting("showOwn")) .. "  (/ns own)")
    ns.Print(L.OPT_SIZE .. ": " .. ns.SizeLabel(ns.Setting("badgeSize")) .. "  (/ns size 1-3)")
    ns.Print(L.OPT_MIN .. ": " .. ns.Setting("minVotes") .. "  (/ns min 1-5)")
    ns.Print(L.OPT_ELVUI .. ": " .. OnOff(ns.Setting("elvSkin")) .. "  (/ns elvui)")
    ns.Print(L.OPT_MINIMAP .. ": " .. OnOff(ns.Setting("showMinimap")) .. "  (/ns minimap)")
end

-- Toggle a boolean setting from chat
function ns.ToggleSetting(key, label)
    ns.db.settings[key] = not ns.Setting(key)
    ns.Print(label .. ": " .. OnOff(ns.db.settings[key]))
end
