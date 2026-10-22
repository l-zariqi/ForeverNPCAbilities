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


## Debug

- Use `/fna status`, `/fna debug`, `/fna on`, `/fna off`, or `/fna toggle` to check and control tooltip output.

- `/fna status` reports whether the core and tooltip hook loaded.

- `/fna debug` adds the hovered NPC ID and catalog counts to its tooltip. The setting is saved between sessions.
