# Forever NPC Abilities

An addon for the WoW client used by Forever (Interface 16001). It appends a list of known abilities to the tooltip for an attackable NPC when you hover over it.

## Install

Copy the `ForeverNPCAbilities` folder into the game's `Interface\AddOns` folder, then enable the addon on the character select screen.

## Ability data

The bundled catalog includes NPC abilities that appear immediately when you hover a listed NPC. Automatic combat-log learning is disabled because this Forever client blocks the addon's combat-log event registration. Previously saved observations remain available, but NPCs missing from the catalog will not be learned automatically.

The bundled catalog also includes the original NpcAbilities Classic NPC-to-spell mappings and English spell data. For NPCs in that catalog, abilities appear immediately when you hover them, with the spell icon and description where available. The dataset is credited to [rubenzantingh/NpcAbilities](https://github.com/rubenzantingh/NpcAbilities) and was adapted with the author's permission.

You can add a manually maintained catalog in `Abilities.lua`, keyed by the NPC ID shown on the [Forever Wowhead NPC database](https://www.wowhead.com/forever/npcs). Each entry is a list of ability names:

```lua
addon.Abilities = {
    [12345] = {
        "Ability name",
        "Another ability",
    },
}
```

Replace `12345` and the example names with NPC and ability data you have permission to use. The game client does not provide complete NPC spell lists, and addons cannot query Wowhead while running in-game.

Open the game's **Options > AddOns > Forever NPC Abilities** page to enable or disable tooltips, always show descriptions, choose a **Hold** or **Toggle** hotkey mode, assign the description key, and use the **Show Range**, **Show Cast time**, and **Show Spell school** checkboxes to control which details appear. Range and cast time come from the bundled spell catalog. Spell school may appear for abilities with previously saved observations. In Hold mode, hold the selected key while hovering an NPC to show descriptions; in Toggle mode, press it to switch descriptions on or off. When descriptions are not always shown, the tooltip shows a hint such as “(Ctrl for details)” below the ability list. The key capture button accepts normal keys, key combinations, and modifier keys by themselves. Right-click the key button to clear its binding.

Use `/fna status`, `/fna debug`, `/fna on`, `/fna off`, or `/fna toggle` to check and control tooltip output. `/fna status` reports whether the core and tooltip hook loaded. `/fna debug` adds the hovered NPC ID and catalog counts to its tooltip. The setting is saved between sessions.
