local addonName, addon = ...

local descriptionKeyBinding = "CLICK ForeverNPCAbilitiesDescriptionKeyButton:LeftButton"

local function getDatabase()
    if type(ForeverNPCAbilitiesDB) ~= "table" then
        ForeverNPCAbilitiesDB = {}
    end
    if type(ForeverNPCAbilitiesDB.enabled) ~= "boolean" then
        ForeverNPCAbilitiesDB.enabled = true
    end
    if type(ForeverNPCAbilitiesDB.alwaysShowDescriptions) ~= "boolean" then
        ForeverNPCAbilitiesDB.alwaysShowDescriptions = false
    end
    if type(ForeverNPCAbilitiesDB.showEnemyUnits) ~= "boolean" then
        ForeverNPCAbilitiesDB.showEnemyUnits = true
    end
    if type(ForeverNPCAbilitiesDB.showFriendlyUnits) ~= "boolean" then
        ForeverNPCAbilitiesDB.showFriendlyUnits = true
    end
    if ForeverNPCAbilitiesDB.hotkeyMode ~= "TOGGLE" then
        ForeverNPCAbilitiesDB.hotkeyMode = "HOLD"
    end
    if type(ForeverNPCAbilitiesDB.learned) ~= "table" then
        ForeverNPCAbilitiesDB.learned = {}
    end
    if type(ForeverNPCAbilitiesDB.details) ~= "table" then
        ForeverNPCAbilitiesDB.details = {}
    end
    for _, key in ipairs({"range", "castTime", "spellSchool"}) do
        if type(ForeverNPCAbilitiesDB.details[key]) ~= "boolean" then
            ForeverNPCAbilitiesDB.details[key] = true
        end
    end
    return ForeverNPCAbilitiesDB
end

local function getBindingText()
    local modifier = getDatabase().descriptionModifier
    if modifier then
        return modifier
    end

    local key1, key2 = GetBindingKey(descriptionKeyBinding)
    if key1 and key2 then
        return key1 .. " or " .. key2
    end
    return key1 or key2 or "Not set"
end

local function updateBindingText(button)
    button:SetText("Description key: " .. getBindingText())
end

local function clearBinding()
    local key1, key2 = GetBindingKey(descriptionKeyBinding)
    if key1 then
        SetBinding(key1)
    end
    if key2 then
        SetBinding(key2)
    end
    SaveBindings(GetCurrentBindingSet())
end

local function saveBinding(key)
    clearBinding()
    if key and not SetBinding(key, descriptionKeyBinding) then
        DEFAULT_CHAT_FRAME:AddMessage("Forever NPC Abilities: could not assign that key.")
        return false
    end
    SaveBindings(GetCurrentBindingSet())
    getDatabase().descriptionModifier = nil
    return true
end

local function saveModifier(modifier)
    clearBinding()
    getDatabase().descriptionModifier = modifier
    return true
end

local optionsPanel = CreateFrame("Frame")
optionsPanel.name = "Forever NPC Abilities"

local title = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Forever NPC Abilities")

local description = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
description:SetWidth(580)
description:SetJustifyH("LEFT")
description:SetText("Set a key to hold while hovering over an NPC to show ability descriptions.")

local enabledCheck = CreateFrame("CheckButton", nil, optionsPanel, "InterfaceOptionsCheckButtonTemplate")
enabledCheck:SetPoint("TOPLEFT", description, "BOTTOMLEFT", -4, -16)
enabledCheck.Text:SetText("Enable NPC ability tooltips")
enabledCheck:SetScript("OnShow", function(self)
    self:SetChecked(getDatabase().enabled)
end)
enabledCheck:SetScript("OnClick", function(self)
    getDatabase().enabled = self:GetChecked()
end)

local alwaysShowDescriptionsCheck = CreateFrame("CheckButton", nil, optionsPanel, "InterfaceOptionsCheckButtonTemplate")
alwaysShowDescriptionsCheck:SetPoint("TOPLEFT", enabledCheck, "BOTTOMLEFT", 0, -4)
alwaysShowDescriptionsCheck.Text:SetText("Always show ability descriptions")
alwaysShowDescriptionsCheck:SetScript("OnShow", function(self)
    self:SetChecked(getDatabase().alwaysShowDescriptions)
end)
alwaysShowDescriptionsCheck:SetScript("OnClick", function(self)
    getDatabase().alwaysShowDescriptions = self:GetChecked()
    if GameTooltip:IsShown() then
        local _, unit = GameTooltip:GetUnit()
        if unit and UnitExists(unit) then
            GameTooltip:SetUnit(unit)
        end
    end
end)

local function refreshCurrentTooltip()
    if GameTooltip:IsShown() then
        local _, unit = GameTooltip:GetUnit()
        if unit and UnitExists(unit) then
            GameTooltip:SetUnit(unit)
        end
    end
end

local unitTypesLabel = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
unitTypesLabel:SetPoint("TOPLEFT", alwaysShowDescriptionsCheck, "BOTTOMLEFT", 4, -12)
unitTypesLabel:SetText("Show abilities for")

local enemyUnitsCheck = CreateFrame("CheckButton", nil, optionsPanel, "InterfaceOptionsCheckButtonTemplate")
enemyUnitsCheck:SetPoint("TOPLEFT", unitTypesLabel, "BOTTOMLEFT", -4, -4)
enemyUnitsCheck.Text:SetText("Enemy units")
enemyUnitsCheck:SetScript("OnShow", function(self)
    self:SetChecked(getDatabase().showEnemyUnits)
end)
enemyUnitsCheck:SetScript("OnClick", function(self)
    getDatabase().showEnemyUnits = self:GetChecked()
    refreshCurrentTooltip()
end)

local friendlyUnitsCheck = CreateFrame("CheckButton", nil, optionsPanel, "InterfaceOptionsCheckButtonTemplate")
friendlyUnitsCheck:SetPoint("TOPLEFT", enemyUnitsCheck, "BOTTOMLEFT", 0, -4)
friendlyUnitsCheck.Text:SetText("Friendly units")
friendlyUnitsCheck:SetScript("OnShow", function(self)
    self:SetChecked(getDatabase().showFriendlyUnits)
end)
friendlyUnitsCheck:SetScript("OnClick", function(self)
    getDatabase().showFriendlyUnits = self:GetChecked()
    refreshCurrentTooltip()
end)

local hotkeyModeLabel = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
hotkeyModeLabel:SetPoint("TOPLEFT", friendlyUnitsCheck, "BOTTOMLEFT", 4, -8)
hotkeyModeLabel:SetText("Hotkey mode")

local hotkeyModeDropdown = CreateFrame("Frame", "ForeverNPCAbilitiesHotkeyModeDropdown", optionsPanel, "UIDropDownMenuTemplate")
hotkeyModeDropdown:SetPoint("TOPLEFT", hotkeyModeLabel, "BOTTOMLEFT", -16, -4)
UIDropDownMenu_SetWidth(hotkeyModeDropdown, 140)

local function setHotkeyModeText()
    local mode = getDatabase().hotkeyMode
    UIDropDownMenu_SetSelectedValue(hotkeyModeDropdown, mode)
    UIDropDownMenu_SetText(hotkeyModeDropdown, mode == "TOGGLE" and "Toggle" or "Hold")
end

UIDropDownMenu_Initialize(hotkeyModeDropdown, function(_, level)
    local modes = {
        {value = "HOLD", text = "Hold"},
        {value = "TOGGLE", text = "Toggle"},
    }
    for _, mode in ipairs(modes) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = mode.text
        info.value = mode.value
        info.checked = getDatabase().hotkeyMode == mode.value
        info.func = function(self)
            getDatabase().hotkeyMode = self.value
            setHotkeyModeText()
            if addon.SetHotkeyMode then
                addon.SetHotkeyMode(self.value)
            end
        end
        UIDropDownMenu_AddButton(info, level)
    end
end)

hotkeyModeDropdown:SetScript("OnShow", function(self)
    setHotkeyModeText()
end)

local bindingButton = CreateFrame("Button", nil, optionsPanel, "UIPanelButtonTemplate")
bindingButton:SetSize(240, 24)
bindingButton:SetPoint("TOPLEFT", hotkeyModeDropdown, "BOTTOMLEFT", 16, -8)
bindingButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
bindingButton:SetScript("OnShow", function(self)
    updateBindingText(self)
end)
bindingButton:SetScript("OnClick", function(self, mouseButton)
    if mouseButton == "RightButton" then
        saveModifier(nil)
        updateBindingText(self)
        return
    end

    self:EnableKeyboard(true)
    self:SetPropagateKeyboardInput(false)
    self:SetText("Press a key (Esc to cancel)")
    self:SetScript("OnKeyDown", function(button, key)
        button:SetPropagateKeyboardInput(false)
        if key == "ESCAPE" then
            button:SetScript("OnKeyDown", nil)
            button:EnableKeyboard(false)
            updateBindingText(button)
            return
        end

        local modifierKeys = {
            LSHIFT = "SHIFT",
            RSHIFT = "SHIFT",
            LCTRL = "CTRL",
            RCTRL = "CTRL",
            LALT = "ALT",
            RALT = "ALT",
        }
        local modifier = modifierKeys[key]
        if modifier then
            button:SetScript("OnKeyDown", nil)
            button:EnableKeyboard(false)
            saveModifier(modifier)
            DEFAULT_CHAT_FRAME:AddMessage("Forever NPC Abilities description key set to " .. modifier .. ".")
            updateBindingText(button)
            return
        end

        local modifiers = {}
        if IsControlKeyDown() then
            modifiers[#modifiers + 1] = "CTRL"
        end
        if IsAltKeyDown() then
            modifiers[#modifiers + 1] = "ALT"
        end
        if IsShiftKeyDown() then
            modifiers[#modifiers + 1] = "SHIFT"
        end
        modifiers[#modifiers + 1] = key
        local binding = table.concat(modifiers, "-")

        button:SetScript("OnKeyDown", nil)
        button:EnableKeyboard(false)
        if saveBinding(binding) then
            DEFAULT_CHAT_FRAME:AddMessage("Forever NPC Abilities description key set to " .. binding .. ".")
        end
        updateBindingText(button)
    end)
end)

local bindingHelp = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
bindingHelp:SetPoint("TOPLEFT", bindingButton, "BOTTOMLEFT", 0, -8)
bindingHelp:SetWidth(580)
bindingHelp:SetJustifyH("LEFT")
bindingHelp:SetText("Click to assign a key, key combination, or modifier by itself. Hold it while hovering over an NPC to reveal descriptions. Right-click to clear it.")

local detailsLabel = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
detailsLabel:SetPoint("TOPLEFT", bindingHelp, "BOTTOMLEFT", 0, -18)
detailsLabel:SetText("Ability details")

local detailOptions = {
    {key = "range", label = "Show Range"},
    {key = "castTime", label = "Show Cast time"},
    {key = "spellSchool", label = "Show Spell school"},
}

for index, option in ipairs(detailOptions) do
    local optionKey = option.key
    local checkbox = CreateFrame("CheckButton", nil, optionsPanel, "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", detailsLabel, "BOTTOMLEFT", 0, -8 - (index - 1) * 28)
    checkbox.Text:SetText(option.label)
    checkbox:SetScript("OnShow", function(self)
        self:SetChecked(getDatabase().details[optionKey])
    end)
    checkbox:SetScript("OnClick", function(self)
        getDatabase().details[optionKey] = self:GetChecked()
        refreshCurrentTooltip()
    end)
end

optionsPanel:SetScript("OnShow", function()
    setHotkeyModeText()
end)

local category
if Settings and type(Settings.RegisterCanvasLayoutCategory) == "function"
    and type(Settings.RegisterAddOnCategory) == "function"
then
    category = Settings.RegisterCanvasLayoutCategory(optionsPanel, optionsPanel.name)
    Settings.RegisterAddOnCategory(category)
elseif type(InterfaceOptions_AddCategory) == "function" then
    InterfaceOptions_AddCategory(optionsPanel)
end

addon.OptionsPanel = optionsPanel
addon.OptionsCategory = category
