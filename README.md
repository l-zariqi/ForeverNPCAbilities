# Forever NPC Abilities

Shows known NPC abilities and spell details to the in-game tooltip. It uses a bundled NPC and spell database to show ability names, icons, and available details such as range, cast time, and spell school.

## Install

### CurseForge app

- Open the [Forever NPC Abilities project page](https://www.curseforge.com/wow/addons/forever-npc-abilities) and select **Install** to open it in the CurseForge app. You can also search for **Forever NPC Abilities** in the app's World of Warcraft category.

### Manual installation

- Download the addon from the [Forever NPC Abilities project page](https://www.curseforge.com/wow/addons/forever-npc-abilities), then copy the `ForeverNPCAbilities` folder into the game's `Interface\AddOns` folder.


## Ability data

The bundled catalog includes NPC abilities that appear immediately when you hover a listed NPC, whether it is friendly or hostile. Vehicle units are also supported when their NPC ID is present in the catalog. Automatic combat-log learning is disabled because this Forever client blocks the addon's combat-log event registration. Previously saved observations remain available, but NPCs missing from the catalog will not be learned automatically.

The bundled catalog also includes the original NpcAbilities Classic NPC-to-spell mappings and English spell data. For NPCs in that catalog, abilities appear immediately when you hover them, with the spell icon and description where available.

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

## Options

- Open the game's **Options > AddOns > Forever NPC Abilities** page to enable or disable tooltips, always show descriptions, choose a **Hold** or **Toggle** hotkey mode, assign the description key, and configure ability details.

- Use the **Enemy units** and **Friendly units** checkboxes in the options panel to choose which unit types show abilities. Both are enabled by default.

- Choose whether range, cast time, spell school, and dispel type details are always shown, shown only while the description key is active, or never shown; the individual checkboxes select which detail types are included. You can also hide the “Known abilities” heading while keeping the ability entries visible. Spell school comes from the bundled Wago.Tools export, while dispel type is separate metadata from the bundled spell catalog (for example, Sonic Burst has Physical school and Magic dispel type).

- In Hold mode, hold the selected key while hovering an NPC to show descriptions or key-gated details; in Toggle mode, press it to switch them on or off. When descriptions or details are key-gated, the tooltip shows a hint such as “(CTRL for details)” below the ability list. The key capture button accepts normal keys, key combinations, and modifier keys by themselves. Right-click the key button to clear its binding.

- Ability names can be colored by effect type when the bundled spell data identifies one: poison is green, curse purple, disease brown, magic blue, and bleeds red. Category name colors are off by default; turn them on to use effect colors, or leave them off to use the default yellow for all ability names. Descriptions default to white. Spell icons get a matching colored border. Options let you turn category name colors and matching spell-icon borders on or off independently. Ability names, descriptions, and detail text use their own configurable colors in the options panel; each effect-type name color is configurable there too. Use the reset button to restore the defaults.



## Debug

- Use `/fna status`, `/fna debug`, `/fna on`, `/fna off`, or `/fna toggle` to check and control tooltip output.

- `/fna status` reports whether the core and tooltip hook loaded.

- `/fna debug` adds the hovered NPC ID and catalog counts to its tooltip. The setting is saved between sessions.
