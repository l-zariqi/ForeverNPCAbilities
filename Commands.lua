local _, addon = ...
local descriptionKeyBinding = "CLICK ForeverNPCAbilitiesDescriptionKeyButton:LeftButton"

local state = {
    coreLoaded = false,
    tooltipHookRegistered = false,
    tooltipHookMethod = nil,
    debugEnabled = false,
}

addon.State = state

local function getDatabase()
    if type(ForeverNPCAbilitiesDB) ~= "table" then
        ForeverNPCAbilitiesDB = {}
    end
    if type(ForeverNPCAbilitiesDB.enabled) ~= "boolean" then
        ForeverNPCAbilitiesDB.enabled = true
    end
    if type(ForeverNPCAbilitiesDB.learned) ~= "table" then
        ForeverNPCAbilitiesDB.learned = {}
    end
    return ForeverNPCAbilitiesDB
end

local function reportStatus()
    local database = getDatabase()
    local coreStatus = state.coreLoaded and "loaded" or "not loaded"
    local tooltipStatus = state.tooltipHookMethod or "not registered"
    local npcDataStatus = state.npcDataCount and (state.npcDataCount .. " NPCs loaded") or "NPC data not loaded"
    local descriptionKey = database.descriptionModifier or GetBindingKey(descriptionKeyBinding) or "not set"
    DEFAULT_CHAT_FRAME:AddMessage(
        "Forever NPC Abilities: core " .. coreStatus
            .. ", tooltip callback " .. tooltipStatus
            .. ", " .. npcDataStatus
            .. ", description key " .. descriptionKey
            .. ", debug " .. (state.debugEnabled and "on" or "off")
            .. ", " .. (database.enabled and "enabled" or "disabled") .. "."
    )
end

SLASH_FNA1 = "/fna"
SLASH_FNA2 = "/forevernpcabilities"
SlashCmdList.FNA = function(message)
    local command = string.lower((message or ""):match("^%s*(.-)%s*$"))
    local database = getDatabase()

    if command == "on" then
        database.enabled = true
        DEFAULT_CHAT_FRAME:AddMessage("Forever NPC Abilities enabled.")
    elseif command == "off" then
        database.enabled = false
        DEFAULT_CHAT_FRAME:AddMessage("Forever NPC Abilities disabled.")
    elseif command == "toggle" then
        database.enabled = not database.enabled
        DEFAULT_CHAT_FRAME:AddMessage("Forever NPC Abilities " .. (database.enabled and "enabled." or "disabled."))
    elseif command == "debug" then
        state.debugEnabled = not state.debugEnabled
        DEFAULT_CHAT_FRAME:AddMessage("Forever NPC Abilities tooltip debug " .. (state.debugEnabled and "enabled; hover an NPC." or "disabled."))
    elseif command == "" or command == "status" then
        reportStatus()
    else
        DEFAULT_CHAT_FRAME:AddMessage("Forever NPC Abilities: use /fna status, /fna debug, /fna on, /fna off, or /fna toggle. Set the description key in the addon options.")
    end
end
