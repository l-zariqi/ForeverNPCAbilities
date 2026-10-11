local addonName, addon = ...

local descriptionKeyBinding = "CLICK ForeverNPCAbilitiesDescriptionKeyButton:LeftButton"

local defaultAbilityColors = {
    name = {r = 1, g = 1, b = 1},
    description = {r = 1, g = 0.82, b = 0},
    details = {r = 0.85, g = 0.85, b = 0.85},
}

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
    if type(ForeverNPCAbilitiesDB.colors) ~= "table" then
        ForeverNPCAbilitiesDB.colors = {}
    end
    if ForeverNPCAbilitiesDB.detailDisplayMode ~= "KEY" and ForeverNPCAbilitiesDB.detailDisplayMode ~= "NEVER" then
        ForeverNPCAbilitiesDB.detailDisplayMode = "ALWAYS"
    end
    for _, key in ipairs({"range", "castTime", "spellSchool"}) do
        if type(ForeverNPCAbilitiesDB.details[key]) ~= "boolean" then
            ForeverNPCAbilitiesDB.details[key] = false
        end
    end
    for key, defaultColor in pairs(defaultAbilityColors) do
        local color = ForeverNPCAbilitiesDB.colors[key]
        if type(color) ~= "table" then
            ForeverNPCAbilitiesDB.colors[key] = {r = defaultColor.r, g = defaultColor.g, b = defaultColor.b}
        else
            if type(color.r) ~= "number" then
                color.r = defaultColor.r
            end
            if type(color.g) ~= "number" then
                color.g = defaultColor.g
            end
            if type(color.b) ~= "number" then
                color.b = defaultColor.b
            end
        end
    end
    return ForeverNPCAbilitiesDB
end

local function getAbilityColor(colorKey)
    local colors = getDatabase().colors
    local defaultColor = defaultAbilityColors[colorKey]
    local color = colors[colorKey]
    if type(color) ~= "table" then
        return defaultColor.r, defaultColor.g, defaultColor.b
    end
    return color.r or defaultColor.r, color.g or defaultColor.g, color.b or defaultColor.b
end

local refreshCurrentTooltip

local function setAbilityColor(colorKey, r, g, b)
    local colors = getDatabase().colors
    colors[colorKey] = {
        r = r,
        g = g,
        b = b,
    }
    refreshCurrentTooltip()
end

local function resetAbilityColors()
    local colors = getDatabase().colors
    for key, defaultColor in pairs(defaultAbilityColors) do
        colors[key] = {
            r = defaultColor.r,
            g = defaultColor.g,
            b = defaultColor.b,
        }
    end
    refreshCurrentTooltip()
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

local function setOptionTooltip(frame, title, text)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(title, 1, 1, 1)
        GameTooltip:AddLine(text, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

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
enabledCheck.Text:SetTextColor(1, 1, 1)
setOptionTooltip(enabledCheck, "Enable NPC ability tooltips", "Show known NPC abilities in unit tooltips.")
enabledCheck:SetScript("OnShow", function(self)
    self:SetChecked(getDatabase().enabled)
end)
enabledCheck:SetScript("OnClick", function(self)
    getDatabase().enabled = self:GetChecked()
end)

local alwaysShowDescriptionsCheck = CreateFrame("CheckButton", nil, optionsPanel, "InterfaceOptionsCheckButtonTemplate")
alwaysShowDescriptionsCheck:SetPoint("TOPLEFT", enabledCheck, "BOTTOMLEFT", 0, -4)
alwaysShowDescriptionsCheck.Text:SetText("Always show ability descriptions")
alwaysShowDescriptionsCheck.Text:SetTextColor(1, 1, 1)
setOptionTooltip(alwaysShowDescriptionsCheck, "Always show ability descriptions", "Show available ability descriptions without holding the description key.")
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

refreshCurrentTooltip = function()
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
enemyUnitsCheck.Text:SetTextColor(1, 1, 1)
setOptionTooltip(enemyUnitsCheck, "Enemy units", "Show known abilities for hostile NPCs.")
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
friendlyUnitsCheck.Text:SetTextColor(1, 1, 1)
setOptionTooltip(friendlyUnitsCheck, "Friendly units", "Show known abilities for friendly NPCs.")
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
setOptionTooltip(hotkeyModeDropdown, "Hotkey mode", "Hold mode shows descriptions only while the key is held. Toggle mode switches descriptions on or off each time the key is pressed.")

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
setOptionTooltip(bindingButton, "Description key", "Choose the key used to show descriptions, or right-click to clear the binding.")
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

local detailDisplayDropdown = CreateFrame("Frame", "ForeverNPCAbilitiesDetailDisplayDropdown", optionsPanel, "UIDropDownMenuTemplate")
detailDisplayDropdown:SetPoint("TOPLEFT", detailsLabel, "BOTTOMLEFT", -16, -4)
UIDropDownMenu_SetWidth(detailDisplayDropdown, 190)
setOptionTooltip(detailDisplayDropdown, "Ability detail display", "Choose whether enabled range, cast time, and spell school details are always shown, shown while the description key is active, or hidden.")

local function setDetailDisplayText()
    local mode = getDatabase().detailDisplayMode
    local modeLabels = {
        ALWAYS = "Always",
        KEY = "While key is active",
        NEVER = "Never",
    }
    UIDropDownMenu_SetSelectedValue(detailDisplayDropdown, mode)
    UIDropDownMenu_SetText(detailDisplayDropdown, modeLabels[mode])
end

UIDropDownMenu_Initialize(detailDisplayDropdown, function(_, level)
    local modes = {
        {value = "ALWAYS", text = "Always"},
        {value = "KEY", text = "While key is active"},
        {value = "NEVER", text = "Never"},
    }
    for _, mode in ipairs(modes) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = mode.text
        info.value = mode.value
        info.checked = getDatabase().detailDisplayMode == mode.value
        info.func = function(self)
            getDatabase().detailDisplayMode = self.value
            setDetailDisplayText()
            refreshCurrentTooltip()
        end
        UIDropDownMenu_AddButton(info, level)
    end
end)

detailDisplayDropdown:SetScript("OnShow", function()
    setDetailDisplayText()
end)

local detailOptions = {
    {key = "range", label = "Show Range"},
    {key = "castTime", label = "Show Cast time"},
    {key = "spellSchool", label = "Show Spell school"},
}

for index, option in ipairs(detailOptions) do
    local optionKey = option.key
    local checkbox = CreateFrame("CheckButton", nil, optionsPanel, "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", detailDisplayDropdown, "BOTTOMLEFT", 16, -4 - (index - 1) * 28)
    checkbox.Text:SetText(option.label)
    checkbox.Text:SetTextColor(1, 1, 1)
    local detailTooltips = {
        range = {"Show Range", "Include the ability's range in its tooltip when range details are enabled."},
        castTime = {"Show Cast time", "Include the ability's cast time in its tooltip when cast-time details are enabled."},
        spellSchool = {"Show Spell school", "Include the ability's spell school in its tooltip when spell-school details are enabled."},
    }
    setOptionTooltip(checkbox, detailTooltips[optionKey][1], detailTooltips[optionKey][2])
    checkbox:SetScript("OnShow", function(self)
        self:SetChecked(getDatabase().details[optionKey])
    end)
    checkbox:SetScript("OnClick", function(self)
        getDatabase().details[optionKey] = self:GetChecked()
        refreshCurrentTooltip()
    end)
end

local colorLabel = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
colorLabel:SetPoint("TOPLEFT", detailDisplayDropdown, "BOTTOMLEFT", 4, -4 - #detailOptions * 28 - 12)
colorLabel:SetText("Tooltip colors")

local function updateColorSwatch(button, colorKey)
    local r, g, b = getAbilityColor(colorKey)
    button.colorTexture:SetVertexColor(r, g, b)
end

local colorSwatches = {}
local colorOptions = {
    {key = "name", label = "Ability name"},
    {key = "description", label = "Ability description"},
    {key = "details", label = "Ability details"},
}

local function openAbilityColorPicker(colorKey, swatch)
    local r, g, b = getAbilityColor(colorKey)
    local function applyColor()
        local newR, newG, newB = ColorPickerFrame:GetColorRGB()
        setAbilityColor(colorKey, newR, newG, newB)
        updateColorSwatch(swatch, colorKey)
    end
    local function cancelColor(previousValues)
        if previousValues then
            setAbilityColor(colorKey, previousValues.r, previousValues.g, previousValues.b)
            updateColorSwatch(swatch, colorKey)
        end
    end

    if type(ColorPickerFrame.SetupColorPickerAndShow) == "function" then
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r,
            g = g,
            b = b,
            hasOpacity = false,
            swatchFunc = applyColor,
            cancelFunc = cancelColor,
        })
    elseif type(ColorPickerFrame.SetColorRGB) == "function" then
        ColorPickerFrame:SetColorRGB(r, g, b)
        ColorPickerFrame.previousValues = {r = r, g = g, b = b}
        ColorPickerFrame.func = applyColor
        ColorPickerFrame.cancelFunc = cancelColor
        ColorPickerFrame:Show()
    else
        DEFAULT_CHAT_FRAME:AddMessage("Forever NPC Abilities: this client does not provide a supported color picker.")
    end
end

local colorColumnWidth = 190
for index, option in ipairs(colorOptions) do
    local label = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetText(option.label)
    label:SetTextColor(1, 1, 1)
    label:SetPoint("TOPLEFT", colorLabel, "BOTTOMLEFT", (index - 1) * colorColumnWidth, -8)

    local swatch = CreateFrame("Button", nil, optionsPanel)
    swatch:SetSize(16, 16)
    swatch:SetPoint("LEFT", label, "RIGHT", 6, 0)
    swatch:SetNormalTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
    swatch:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    swatch.colorTexture = swatch:CreateTexture(nil, "ARTWORK")
    swatch.colorTexture:SetSize(10, 10)
    swatch.colorTexture:SetPoint("CENTER")
    swatch.colorTexture:SetTexture("Interface\\Buttons\\WHITE8X8")
    setOptionTooltip(swatch, option.label, "Choose the color used for " .. string.lower(option.label) .. " text in NPC tooltips.")
    swatch:SetScript("OnClick", function()
        openAbilityColorPicker(option.key, swatch)
    end)
    updateColorSwatch(swatch, option.key)
    colorSwatches[option.key] = swatch
end

local resetColorsButton = CreateFrame("Button", nil, optionsPanel, "UIPanelButtonTemplate")
resetColorsButton:SetSize(180, 24)
resetColorsButton:SetPoint("TOPLEFT", colorLabel, "BOTTOMLEFT", 0, -36)
resetColorsButton:SetText("Reset colors to default")
setOptionTooltip(resetColorsButton, "Reset colors to default", "Restore the original white, gold, and light gray tooltip text colors.")
resetColorsButton:SetScript("OnClick", function()
    resetAbilityColors()
    for key, swatch in pairs(colorSwatches) do
        updateColorSwatch(swatch, key)
    end
end)

optionsPanel:SetScript("OnShow", function()
    setHotkeyModeText()
    setDetailDisplayText()
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
