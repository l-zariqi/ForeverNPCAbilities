# Forever NPC Abilities

An addon for the WoW client used by Forever (Interface 16001). It appends known abilities to NPC tooltips, including friendly units that are not attackable, when you hover over them.

## Install

Copy the `ForeverNPCAbilities` folder into the game's `Interface\AddOns` folder, then enable the addon on the character select screen.

## Ability data

The bundled catalog includes NPC abilities that appear immediately when you hover a listed NPC, whether it is friendly or hostile. Vehicle units are also supported when their NPC ID is present in the catalog. Automatic combat-log learning is disabled because this Forever client blocks the addon's combat-log event registration. Previously saved observations remain available, but NPCs missing from the catalog will not be learned automatically.

The bundled catalog also includes the original NpcAbilities Classic NPC-to-spell mappings and English spell data. For NPCs in that catalog, abilities appear immediately when you hover them, with the spell icon and description where available. The dataset is credited to [rubenzantingh/NpcAbilities](https://github.com/rubenzantingh/NpcAbilities) and was adapted with the author's permission.

Spell school masks are bundled from Wago.Tools' Classic `SpellMisc` data (build `1.60.1.70245`), with missing records backfilled from TBC Classic (build `2.5.6.70006`). School details may be unavailable for spell IDs absent from both exports.

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

Open the game's **Options > AddOns > Forever NPC Abilities** page to enable or disable tooltips, always show descriptions, choose a **Hold** or **Toggle** hotkey mode, assign the description key, and use the **Show Range**, **Show Cast time**, and **Show Spell school** checkboxes to control which details appear. Range and cast time come from the bundled spell catalog; school data comes from the bundled Wago.Tools export. In Hold mode, hold the selected key while hovering an NPC to show descriptions; in Toggle mode, press it to switch descriptions on or off. When descriptions are not always shown, the tooltip shows a hint such as “(Ctrl for details)” below the ability list. The key capture button accepts normal keys, key combinations, and modifier keys by themselves. Right-click the key button to clear its binding.

Use the **Enemy units** and **Friendly units** checkboxes in the options panel to choose which unit types show abilities. Both are enabled by default. Neutral units are neither type and do not show abilities.

Use `/fna status`, `/fna debug`, `/fna on`, `/fna off`, or `/fna toggle` to check and control tooltip output. `/fna status` reports whether the core and tooltip hook loaded. `/fna debug` adds the hovered NPC ID and catalog counts to its tooltip. The setting is saved between sessions.
