import unittest

from update_wowhead_abilities import (
    parse_npc_reference,
    parse_spell_links,
    render_lua,
)


class ImporterTests(unittest.TestCase):
    def test_parse_npc_id_or_url(self):
        self.assertEqual(parse_npc_reference("246017"), 246017)
        self.assertEqual(
            parse_npc_reference("https://www.wowhead.com/forever/npc=246017/unstable-sentinel"),
            246017,
        )

    def test_reject_invalid_npc_reference(self):
        for value in ("0", "https://www.wowhead.com/forever/spell=123", "npc=123abc"):
            with self.subTest(value=value), self.assertRaises(ValueError):
                parse_npc_reference(value)

    def test_parse_and_deduplicate_spell_links(self):
        result = parse_spell_links(
            [
                ("/forever/spell=123/example", " Example  Spell "),
                ("/forever/spell=123/example", "Example Spell"),
                ("/forever/spell=456/other", "Other"),
            ]
        )
        self.assertEqual(
            result,
            [
                {"name": "Example Spell", "spellID": 123},
                {"name": "Other", "spellID": 456},
            ],
        )

    def test_render_lua_escapes_names_and_sorts_ids(self):
        lua = render_lua(
            {
                "20": [{"name": 'A "quoted" spell', "spellID": 201}],
                "3": [{"name": "Back\\slash", "spellID": 31}],
            }
        )
        self.assertLess(lua.index("addon.Abilities[3]"), lua.index("addon.Abilities[20]"))
        self.assertIn(r'name = "A \"quoted\" spell"', lua)
        self.assertIn(r'name = "Back\\slash"', lua)


if __name__ == "__main__":
    unittest.main()
