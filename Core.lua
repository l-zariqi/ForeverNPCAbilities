local addonName, addon = ...
local descriptionKeyBinding = "CLICK ForeverNPCAbilitiesDescriptionKeyButton:LeftButton"

local database
local state = addon.State

local function getNpcIDFromGUID(guid)
    if not guid then
        return nil
    end

    local npcID = guid:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
        or guid:match("^Vehicle%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
    if npcID then
        return tonumber(npcID)
    end

    local legacyID = guid:match("^0xF130(%x%x%x%x)")
    if legacyID then
        return tonumber(legacyID, 16)
    end
end

local function getNpcID(unit)
    return getNpcIDFromGUID(UnitGUID(unit))
end

local function getSpellTexture(spellID)
    if not spellID then
        return nil
    end

    if C_Spell and type(C_Spell.GetSpellTexture) == "function" then
        local texture = C_Spell.GetSpellTexture(spellID)
        if texture then
            return texture
        end
    end

    if type(GetSpellTexture) == "function" then
        return GetSpellTexture(spellID)
    end
end

local function getSpellDescription(spellID)
    if not spellID then
        return nil
    end

    if C_Spell and type(C_Spell.GetSpellDescription) == "function" then
        local description = C_Spell.GetSpellDescription(spellID)
        if type(description) == "string" and description ~= "" then
            return description
        end
    end

    if type(GetSpellDescription) == "function" then
        local description = GetSpellDescription(spellID)
        if type(description) == "string" and description ~= "" then
            return description
        end
    end
end

local function schoolNameFromMask(mask)
    if type(mask) ~= "number" or mask == 0 then
        return nil
    end

    local schools = {
        {mask = 1, name = "Physical"},
        {mask = 2, name = "Holy"},
        {mask = 4, name = "Fire"},
        {mask = 8, name = "Nature"},
        {mask = 16, name = "Frost"},
        {mask = 32, name = "Shadow"},
        {mask = 64, name = "Arcane"},
    }
    local names = {}
    for _, school in ipairs(schools) do
        if mask % (school.mask * 2) >= school.mask then
            names[#names + 1] = school.name
        end
    end
    return #names > 0 and table.concat(names, "/") or nil
end

local function getSpellSchool(spellID)
    if not spellID then
        return nil
    end

    local schoolMasks = ForeverNPCAbilitiesSpellSchools
    local mask = schoolMasks and schoolMasks[spellID]
    if not mask and database and database.spellSchools then
        mask = database.spellSchools[spellID]
    end
    return schoolNameFromMask(mask)
end

local function formatBinding(binding)
    local parts = {}
    local labels = {
        CTRL = "Ctrl",
        ALT = "Alt",
        SHIFT = "Shift",
    }
    for part in binding:gmatch("[^-]+") do
        parts[#parts + 1] = labels[part] or part
    end
    return table.concat(parts, "+")
end

local function getDescriptionKeyLabel()
    if database and database.descriptionModifier then
        return formatBinding(database.descriptionModifier)
    end

    local key1, key2 = GetBindingKey(descriptionKeyBinding)
    if key1 and key2 then
        return formatBinding(key1) .. " or " .. formatBinding(key2)
    end
    local key = key1 or key2
    return key and formatBinding(key) or nil
end

local function addAbilityLine(tooltip, ability)
    local icon = ability.texture and ("|T" .. tostring(ability.texture) .. ":16:16:0:0:64:64:4:60:4:60|t ") or ""
    tooltip:AddLine(icon .. ability.name, 1, 1, 1, true)
    local details = database.details
    if details then
        if details.range and ability.range and ability.range ~= "" then
            tooltip:AddLine("Range: " .. ability.range, 0.85, 0.85, 0.85, true)
        end
        if details.castTime and ability.castTime and ability.castTime ~= "" then
            tooltip:AddLine("Cast time: " .. ability.castTime, 0.85, 0.85, 0.85, true)
        end
        if details.spellSchool and ability.spellSchool and ability.spellSchool ~= "" then
            tooltip:AddLine("Spell school: " .. ability.spellSchool, 0.85, 0.85, 0.85, true)
        end
    end
    if (database.alwaysShowDescriptions or state.descriptionKeyDown)
        and ability.description
        and ability.description ~= ""
    then
        tooltip:AddLine(ability.description, 1, 0.82, 0, true)
    end
end

local function refreshGameTooltip()
    if not GameTooltip:IsShown() then
        return
    end

    local _, unit = GameTooltip:GetUnit()
    if unit and UnitExists(unit) then
        GameTooltip:SetUnit(unit)
    end
end

local function appendAbilities(tooltip)
    if tooltip ~= GameTooltip then
        return
    end

    if not database or not database.enabled then
        return
    end

    local _, unit = tooltip:GetUnit()
    if not unit or not UnitExists(unit) then
        return
    end

    local isEnemy = UnitCanAttack("player", unit)
    local isFriendly = UnitIsFriend("player", unit)
    if (isEnemy and not database.showEnemyUnits)
        or (isFriendly and not database.showFriendlyUnits)
        or (not isEnemy and not isFriendly)
    then
        return
    end

    local npcID = getNpcID(unit)
    if not npcID then
        return
    end

    local knownAbilities = {}
    local knownNames = {}
    local function addKnownAbility(name, spellID, description, metadata)
        if type(name) ~= "string" or name == "" then
            return
        end
        local normalizedName = string.lower(name)
        local existing = knownNames[normalizedName]
        if not existing then
            metadata = metadata or {}
            existing = {
                name = name,
                spellID = spellID,
                description = description,
                texture = getSpellTexture(spellID),
                range = metadata.range,
                castTime = metadata.castTime,
                spellSchool = metadata.spellSchool or getSpellSchool(spellID),
            }
            knownNames[normalizedName] = existing
            knownAbilities[#knownAbilities + 1] = existing
        else
            metadata = metadata or {}
            existing.description = existing.description or description
            existing.spellID = existing.spellID or spellID
            existing.texture = existing.texture or getSpellTexture(spellID)
            existing.range = existing.range or metadata.range
            existing.castTime = existing.castTime or metadata.castTime
            existing.spellSchool = existing.spellSchool or metadata.spellSchool or getSpellSchool(spellID)
        end
    end

    local manualAbilities = addon.Abilities[npcID]
    if type(manualAbilities) == "table" then
        for _, ability in ipairs(manualAbilities) do
            if type(ability) == "table" then
                addKnownAbility(ability.name, ability.spellID, ability.description, ability)
            else
                addKnownAbility(ability)
            end
        end
    end

    local npcData = ForeverNPCAbilitiesNpcData and ForeverNPCAbilitiesNpcData[npcID]
    local englishSpells = ForeverNPCAbilitiesSpellData and ForeverNPCAbilitiesSpellData.en
    if npcData and type(npcData.classic_spell_ids) == "table" and type(englishSpells) == "table" then
        for _, spellID in ipairs(npcData.classic_spell_ids) do
            local spell = englishSpells[spellID]
            local spellName = spell and spell.name
            if not spellName and C_Spell and type(C_Spell.GetSpellName) == "function" then
                spellName = C_Spell.GetSpellName(spellID)
            end
            if not spellName and type(GetSpellInfo) == "function" then
                spellName = GetSpellInfo(spellID)
            end
            addKnownAbility(
                spellName,
                spellID,
                (spell and spell.description) or getSpellDescription(spellID),
                {
                    range = spell and spell.range,
                    castTime = spell and spell.cast_time,
                    spellSchool = getSpellSchool(spellID),
                }
            )
        end
    end

    local observedSpells = database.learned[npcID]
    local shownNames = {}
    local hasKnownAbilities = #knownAbilities > 0

    if hasKnownAbilities then
        tooltip:AddLine("Known abilities:", 1, 0.82, 0, true)
        for _, ability in ipairs(knownAbilities) do
            addAbilityLine(tooltip, ability)
            shownNames[string.lower(ability.name)] = true
        end
    end

    local newObservedSpells = {}
    if type(observedSpells) == "table" then
        for spellID, spellName in pairs(observedSpells) do
            local normalizedName = type(spellName) == "string" and string.lower(spellName)
            if normalizedName and spellName ~= "" and not shownNames[normalizedName] then
                local numericSpellID = tonumber(spellID)
                newObservedSpells[#newObservedSpells + 1] = {
                    name = spellName,
                    spellID = numericSpellID,
                    description = getSpellDescription(numericSpellID),
                    texture = getSpellTexture(numericSpellID),
                    spellSchool = getSpellSchool(numericSpellID),
                }
                shownNames[normalizedName] = true
            end
        end
    end

    if state.debugEnabled then
        local learnedCount = 0
        if type(observedSpells) == "table" then
            for _ in pairs(observedSpells) do
                learnedCount = learnedCount + 1
            end
        end
        tooltip:AddLine(
            string.format(
                "FNA debug: NPC %d, %d cataloged, %d observed",
                npcID,
                #knownAbilities,
                learnedCount
            ),
            0.5,
            0.8,
            1,
            true
        )
        tooltip:Show()
    end

    if #newObservedSpells > 0 then
        table.sort(newObservedSpells, function(left, right)
            return left.name < right.name
        end)
        tooltip:AddLine("Observed in combat", 1, 0.82, 0)
        for _, ability in ipairs(newObservedSpells) do
            addAbilityLine(tooltip, ability)
        end
    end

    local hasAbilities = hasKnownAbilities or #newObservedSpells > 0
    local descriptionKey = not database.alwaysShowDescriptions
        and not state.descriptionKeyDown
        and getDescriptionKeyLabel()
    if hasAbilities and descriptionKey then
        tooltip:AddLine("(" .. descriptionKey .. " for details)", 0.8, 0.8, 0.8, true)
    end

    if hasAbilities then
        tooltip:Show()
    end
end

if type(GameTooltip.GetPrimaryTooltipData) == "function"
    and TooltipDataProcessor
    and type(TooltipDataProcessor.AddTooltipPostCall) == "function"
    and Enum
    and Enum.TooltipDataType
    and Enum.TooltipDataType.Unit
then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, appendAbilities)
    state.tooltipHookRegistered = true
    state.tooltipHookMethod = "registered (tooltip data)"
elseif GameTooltip:HasScript("OnTooltipSetUnit") then
    GameTooltip:HookScript("OnTooltipSetUnit", appendAbilities)
    state.tooltipHookRegistered = true
    state.tooltipHookMethod = "registered (legacy script)"
else
    state.tooltipHookMethod = "unsupported by this client"
end

local descriptionKeyFrame = CreateFrame("Frame")
local descriptionInputLatched = false

local function isDescriptionKeyDown()
    if database and database.descriptionModifier == "CTRL" then
        return IsControlKeyDown()
    elseif database and database.descriptionModifier == "ALT" then
        return IsAltKeyDown()
    elseif database and database.descriptionModifier == "SHIFT" then
        return IsShiftKeyDown()
    end

    local key1, key2 = GetBindingKey(descriptionKeyBinding)
    for _, binding in ipairs({key1, key2}) do
        if binding then
            local key = binding
            local needsControl = key:match("^CTRL%-") ~= nil
            local needsAlt = key:match("^ALT%-") ~= nil
            local needsShift = key:match("^SHIFT%-") ~= nil
            key = key:gsub("^CTRL%-", ""):gsub("^ALT%-", ""):gsub("^SHIFT%-", "")

            if IsKeyDown(key)
                and (not needsControl or IsControlKeyDown())
                and (not needsAlt or IsAltKeyDown())
                and (not needsShift or IsShiftKeyDown())
            then
                return true
            end
        end
    end
    return false
end

local function updateDescriptionKeyState()
    local isDown = isDescriptionKeyDown()
    if isDown then
        return
    end

    descriptionKeyFrame:SetScript("OnUpdate", nil)
    descriptionInputLatched = false
    if database.hotkeyMode ~= "TOGGLE" and state.descriptionKeyDown then
        state.descriptionKeyDown = false
        refreshGameTooltip()
    end
end

local function activateDescriptionKey()
    if not descriptionInputLatched then
        descriptionInputLatched = true
        if database.hotkeyMode == "TOGGLE" then
            state.descriptionKeyDown = not state.descriptionKeyDown
        else
            state.descriptionKeyDown = true
        end
        refreshGameTooltip()
    end
    descriptionKeyFrame:SetScript("OnUpdate", updateDescriptionKeyState)
end

local descriptionKeyButton = CreateFrame("Button", "ForeverNPCAbilitiesDescriptionKeyButton", UIParent)
descriptionKeyButton:SetSize(1, 1)
descriptionKeyButton:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
descriptionKeyButton:SetAlpha(0)
descriptionKeyButton:RegisterForClicks("AnyDown")
descriptionKeyButton:SetScript("OnClick", activateDescriptionKey)
descriptionKeyButton:Show()

descriptionKeyFrame:RegisterEvent("MODIFIER_STATE_CHANGED")
descriptionKeyFrame:SetScript("OnEvent", function(_, _, _, keyState)
    if not database or not database.descriptionModifier then
        return
    end

    if keyState == 1 then
        activateDescriptionKey()
    elseif keyState == 0 then
        updateDescriptionKeyState()
    end
end)

function addon.SetHotkeyMode(mode)
    if not database then
        return
    end
    database.hotkeyMode = mode == "TOGGLE" and "TOGGLE" or "HOLD"
    descriptionInputLatched = false
    state.descriptionKeyDown = false
    descriptionKeyFrame:SetScript("OnUpdate", nil)
    refreshGameTooltip()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, _, loadedAddon)
    if loadedAddon ~= addonName then
        return
    end

    database = ForeverNPCAbilitiesDB
    if type(database.showEnemyUnits) ~= "boolean" then
        database.showEnemyUnits = true
    end
    if type(database.showFriendlyUnits) ~= "boolean" then
        database.showFriendlyUnits = true
    end
    if type(database.details) ~= "table" then
        database.details = {}
    end
    for _, key in ipairs({"range", "castTime", "spellSchool"}) do
        if type(database.details[key]) ~= "boolean" then
            database.details[key] = true
        end
    end
    if type(database.spellSchools) ~= "table" then
        database.spellSchools = {}
    end
    local legacyKey1, legacyKey2 = GetBindingKey("FNA_SHOW_DESCRIPTIONS")
    local migratedBinding = false
    if legacyKey1 and SetBinding(legacyKey1, descriptionKeyBinding) then
        migratedBinding = true
    end
    if legacyKey2 and legacyKey2 ~= legacyKey1 and SetBinding(legacyKey2, descriptionKeyBinding) then
        migratedBinding = true
    end
    if migratedBinding then
        SaveBindings(GetCurrentBindingSet())
    end
end)

local npcDataCount = 0
for _ in pairs(ForeverNPCAbilitiesNpcData or {}) do
    npcDataCount = npcDataCount + 1
end
state.npcDataCount = npcDataCount
state.coreLoaded = true
