local frames = {}
local hooks = {}
local lines = {}
local currentNpcID = 262397

GameTooltip = {
    HasScript = function(_, name) return name == "OnTooltipSetUnit" end,
    HookScript = function(_, name, callback) hooks[name] = callback end,
    GetUnit = function() return "Test NPC", "target" end,
    AddLine = function(_, text) lines[#lines + 1] = text end,
    Show = function() end,
    IsShown = function() return false end,
}

function CreateFrame()
    local frame = {scripts = {}, events = {}}
    function frame:SetScript(name, callback) self.scripts[name] = callback end
    function frame:RegisterEvent(name) self.events[name] = true end
    function frame:SetSize() end
    function frame:SetPoint() end
    function frame:SetAlpha() end
    function frame:RegisterForClicks() end
    function frame:Show() end
    frames[#frames + 1] = frame
    return frame
end

function UnitExists() return true end
function UnitCanAttack() return true end
function UnitReaction() return 1 end
function UnitIsFriend() return false end
function UnitGUID() return "Creature-0-0-0-0-" .. currentNpcID .. "-00000000" end
function GetBindingKey() return nil end

ForeverNPCAbilitiesDB = {
    enabled = true,
    learned = {
        [262397] = {
            [1604] = "Dazed",
            [7] = "dAzEd",
            [8] = "Observed ability",
        },
    },
    alwaysShowDescriptions = true,
    abilityIconBorderStyle = "NONE",
}
ForeverNPCAbilitiesSpellData = {
    en = {
        [1] = {description = "Bundled description"},
        [3] = {description = "Bundled override"},
        [5] = {name = "Classic", description = "Classic description"},
        [6] = {description = ""},
    },
}
ForeverNPCAbilitiesNpcData = {
    [262397] = {classic_spell_ids = {5}},
}
C_Spell = {
    GetSpellDescription = function(id)
        if id == 2 then return "Client description" end
        if id == 3 then return "Client override" end
        if id == 6 then return "Empty fallback description" end
    end,
}

local addon = {
    State = {},
    Abilities = {
        [262397] = {
            {name = "Bundled", spellID = 1},
            {name = "Client", spellID = 2},
            {name = "Explicit", spellID = 3, description = "Explicit description"},
            {name = "Unavailable", spellID = 4},
            {name = "Empty", spellID = 6, description = ""},
            {name = "Dazed", spellID = 1604},
            {name = "Localized daze", spellID = 1604},
            "Dazed",
            "Piercing Howl",
        },
    },
}

assert(loadfile("Core.lua"))("ForeverNPCAbilities", addon)
for _, frame in ipairs(frames) do
    if frame.events.ADDON_LOADED then
        frame.scripts.OnEvent(frame, "ADDON_LOADED", "ForeverNPCAbilities")
    end
end

local function hasLine(expected)
    for _, line in ipairs(lines) do
        if line == expected then return true end
    end
    return false
end

hooks.OnTooltipSetUnit(GameTooltip)
assert(hasLine("Bundled description"))
assert(hasLine("Client description"))
assert(hasLine("Explicit description"))
assert(hasLine("Classic description"))
assert(hasLine("Empty fallback description"))
assert(not hasLine("Bundled override"))
assert(not hasLine("Client override"))
assert(hasLine("Unavailable"))
assert(not hasLine("Dazed"))
assert(not hasLine("dAzEd"))
assert(not hasLine("Localized daze"))
assert(hasLine("Piercing Howl"))
assert(hasLine("Observed ability"))

lines = {}
ForeverNPCAbilitiesDB.alwaysShowDescriptions = false
hooks.OnTooltipSetUnit(GameTooltip)
assert(not hasLine("Bundled description"))
assert(not hasLine("Client description"))
assert(not hasLine("Explicit description"))
assert(not hasLine("Classic description"))
assert(not hasLine("Empty fallback description"))

addon.State.descriptionKeyDown = true
lines = {}
hooks.OnTooltipSetUnit(GameTooltip)
assert(hasLine("Bundled description"))
assert(hasLine("Client description"))
assert(hasLine("Explicit description"))
assert(hasLine("Classic description"))
assert(hasLine("Empty fallback description"))

local manualAddon = {}
assert(loadfile("Abilities.lua"))("ForeverNPCAbilities", manualAddon)
assert(manualAddon.Abilities[256798][1].name == "Flame Shock")
assert(manualAddon.Abilities[256798][1].spellID == 15039)
addon.Abilities[256798] = manualAddon.Abilities[256798]
assert(loadfile("Database/Abilities/enUS.lua"))()
currentNpcID = 256798
lines = {}
hooks.OnTooltipSetUnit(GameTooltip)
assert(hasLine("Flame Shock"))
assert(hasLine(ForeverNPCAbilitiesSpellData.en[15039].description))

assert(manualAddon.Abilities[256749][1].name == "Enrage")
assert(manualAddon.Abilities[256749][1].spellID == 8599)
addon.Abilities[256749] = manualAddon.Abilities[256749]
currentNpcID = 256749
lines = {}
hooks.OnTooltipSetUnit(GameTooltip)
assert(hasLine("Enrage"))
assert(not hasLine("Dazed"))

assert(manualAddon.Abilities[263071][1].name == "Enrage")
assert(manualAddon.Abilities[263071][1].spellID == 8599)
assert(manualAddon.Abilities[263071][2].name == "Hamstring")
assert(manualAddon.Abilities[263071][2].spellID == 9080)
assert(manualAddon.Abilities[263071][3].name == "Wind Strike")
assert(manualAddon.Abilities[263071][3].spellID == 1270400)
addon.Abilities[263071] = manualAddon.Abilities[263071]
currentNpcID = 263071
lines = {}
hooks.OnTooltipSetUnit(GameTooltip)
assert(hasLine("Enrage"))
assert(hasLine("Hamstring"))
assert(hasLine("Wind Strike"))
assert(not hasLine("Dazed"))

local generatedAddon = {Abilities = {}}
assert(loadfile("Database/wowheadAbilities.lua"))("ForeverNPCAbilities", generatedAddon)
assert(generatedAddon.Abilities[259758][2].name == "Smash")
assert(generatedAddon.Abilities[259758][3].name == "War Stomp")
assert(generatedAddon.Abilities[259758][4].name == "Shoot")
assert(generatedAddon.Abilities[259758][4].spellID == 1316579)
addon.Abilities[259758] = generatedAddon.Abilities[259758]
currentNpcID = 259758
lines = {}
hooks.OnTooltipSetUnit(GameTooltip)
assert(hasLine("Smash"))
assert(hasLine("War Stomp"))
assert(hasLine("Shoot"))
assert(not hasLine("Dazed"))

assert(manualAddon.Abilities[257017][1].name == "Tendon Rip")
assert(manualAddon.Abilities[257017][1].spellID == 3604)
addon.Abilities[257017] = manualAddon.Abilities[257017]
currentNpcID = 257017
lines = {}
hooks.OnTooltipSetUnit(GameTooltip)
assert(hasLine("Tendon Rip"))
assert(hasLine("Reduces an enemy's movement speed by 71% for 8 sec."))

assert(manualAddon.Abilities[259269][1].name == "Fevered Fatigue")
assert(manualAddon.Abilities[259269][1].spellID == 8139)
addon.Abilities[259269] = manualAddon.Abilities[259269]
currentNpcID = 259269
lines = {}
hooks.OnTooltipSetUnit(GameTooltip)
assert(hasLine("Fevered Fatigue"))
assert(hasLine(ForeverNPCAbilitiesSpellData.en[8139].description))

addon.Abilities[42] = {"Dazed"}
ForeverNPCAbilitiesDB.learned[42] = {[1604] = "Dazed"}
currentNpcID = 42
lines = {}
hooks.OnTooltipSetUnit(GameTooltip)
assert(not hasLine("Known abilities:"))
assert(not hasLine("Observed in combat"))
assert(not hasLine("Dazed"))

print("Tooltip ability and description tests passed.")
