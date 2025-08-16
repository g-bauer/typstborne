#import "daggerheart_template.typ": adversary, boxed_text, daggerheart, encounter_table, environment, map-key
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#show: daggerheart

= Daggerheart Template

A minimal #emph("typst") template to build documents for Daggerheart.

- Default font: Avenir
- Default text size: 10pt
- Default page size: A4

You can change the defaults. Use the ```typst with``` statement:

```typst
#show: daggerheart.with(font: Arial, font_size: 8pt, paper: a5)
// your content comes here
```

== Main Features

Automatically sets conditions italic. E.g. writing ```typst Hidden, Vulnerable, and Restrained```
is shown as: Hidden, Vulnerable, and Restrained.

=== Read statblocks directly from json files
To read an Adversary statblock, you can use
```typst
#adversary(json("adversary_json/Apprentice Assassin.json"))
```

which yields

#adversary(json("adversary_json/Apprentice Assassin.json"))

The template automatically sets dice formulas, and phrases like "spend a Fear" (or spend 2 Fear) or "mark a Stress" in #strong("bold").
You can adjust the appearance, for example by removing the box and changing the font:

```typst
#text(font: "Arial", size: 8pt, adversary(
  json("adversary_json/Apprentice Assassin.json"),
  width: 50%,
  block_stroke: 0pt,
))
```

yields

#text(font: "Arial", size: 8pt, adversary(
  json("adversary_json/Apprentice Assassin.json"),
  width: 50%,
  block_stroke: 0pt,
))

Of course, this also works for Environment stat blocks. \
For example: ```typst #environment(json("environment_json/bustling_marketplace.json"))``` gives

#environment(json("environment_json/bustling_marketplace.json"))

The questions are automatically formatted and use a lighter font.
Both Adversaries and Environments use relative font sizes, so when you change the default of the document, they will adjust accordingly.

#pagebreak()
=== Encounter Tables

Since all data comes from json in a structured way, we can do cool stuff with it. For example, we can build a nice table for encounters that can be printed and used at the table.

```typst
#encounter_table(
  (
    ("adversary": json("adversary_json/Master Assassin.json"), "count": 1),
    ("adversary": json("adversary_json/Assassin Poisoner.json"), "count": 1),
  ),
  encounter_name: none
)
```

Is parsed as:

#encounter_table(
  (
    ("adversary": json("adversary_json/Master Assassin.json"), "count": 1),
    ("adversary": json("adversary_json/Assassin Poisoner.json"), "count": 1),
  ),
  encounter_name: none,
)

The *V*, *R*, and *H* columns can be used to marked the Vulnerable, Restrained, and Hidden condition, respectively.

==== Customization
There are some additional features.
For example, Horde and Minion Adversaries are presented with additional information.
You can also specify the _tier_ and _number_pcs_ and calculate the Battle Points.
And lets also add a couple of empty rows in case we have to improvise.
To keep the table more clean, let's also remove the conditions and put it in a box.

```typst
#box(radius: 4pt, stroke: 0.5pt, inset: 10pt, encounter_table(
  (
    ("adversary": json("adversary_json/Jagged Knife Lieutenant.json"), "count": 1),
    ("adversary": json("adversary_json/Jagged Knife Hexer.json"), "count": 1),
    ("adversary": json("adversary_json/Jagged Knife Bandit.json"), "count": 3),
    ("adversary": json("adversary_json/Jagged Knife Lackey.json"), "count": 3),
  ),
  encounter_name: "Jagged Knife Encounter",
  tier: 0, // 0 is default
  display_battle_points: true,
  add_empty_rows: 3,
  display_conditions: false,
  number_pcs: 3,
))
```

Results in:

#box(radius: 4pt, stroke: 0.5pt, inset: 10pt, encounter_table(
  (
    ("adversary": json("adversary_json/Jagged Knife Lieutenant.json"), "count": 1),
    ("adversary": json("adversary_json/Jagged Knife Hexer.json"), "count": 1),
    ("adversary": json("adversary_json/Jagged Knife Bandit.json"), "count": 3),
    ("adversary": json("adversary_json/Jagged Knife Lackey.json"), "count": 3),
  ),
  encounter_name: "Jagged Knife Encounter",
  tier: 0,
  display_battle_points: true,
  add_empty_rows: 3,
  display_conditions: false,
  number_pcs: 3,
))

Minions show the HP needed for additional kills in parantheses.
You can adjust the Battle Points via _battle_point_adjustment_.
The tables automatically apply adjustments for two or more Solos, if adversaries from lower tiers are used and if no Bruisers, Hordes, Leaders or Solos are present.

Combining these features, we can build one-page encounter summaries - check out the next page.
#pagebreak()

#text(size: 8pt, page(flipped: true, margin: 15pt, footer: [], [
  = Jagged Knife Encounter
  #grid(
    columns: (2.0fr, 1fr, 1fr),
    rows: (auto, auto),
    gutter: 10pt,
    [#box(radius: 2pt, stroke: 0.5pt, inset: 10pt, encounter_table(
        (
          ("adversary": json("adversary_json/Jagged Knife Lieutenant.json"), "count": 1),
          ("adversary": json("adversary_json/Jagged Knife Hexer.json"), "count": 1),
          ("adversary": json("adversary_json/Jagged Knife Bandit.json"), "count": 3),
          ("adversary": json("adversary_json/Jagged Knife Lackey.json"), "count": 3),
        ),
        tier: 0,
        display_battle_points: true,
        display_conditions: false,
        number_pcs: 3,
        add_empty_rows: 5,
      ))
      #environment(json("environment_json/bustling_marketplace.json"))
    ],
    [
      #adversary(json("adversary_json/Jagged Knife Lieutenant.json"))
      #adversary(json("adversary_json/Jagged Knife Hexer.json"))
      #adversary(json("adversary_json/Jagged Knife Bandit.json"))
    ],
    [
      #adversary(json("adversary_json/Jagged Knife Lackey.json"))
      #adversary(json("adversary_json/Jagged Knife Kneebreaker.json"))
      #adversary(json("adversary_json/Jagged Knife Sniper.json"))
    ],
  )
]))

= Mores Features

The current Header1 is dynamically shown at the bottom of the page next to the page number.

=== Boxed Text

```typst
#boxed_text(width: 50%)[
  #pad(top: 0em, left: 1.5em, bottom: 0em)[
    $arrow.r$ Tier 1 encompasses level 1 only. \
    $arrow.r$ Tier 2 encompasses levels 2-4. \
    $arrow.r$ Tier 3 encompasses levels 5-7. \
    $arrow.r$ Tier 4 encompasses levels 8-10.
  ]
]
```

yields
#boxed_text(width: 50%)[
  #pad(top: 0em, left: 1.5em, bottom: 0em)[
    $arrow.r$ Tier 1 encompasses level 1 only. \
    $arrow.r$ Tier 2 encompasses levels 2-4. \
    $arrow.r$ Tier 3 encompasses levels 5-7. \
    $arrow.r$ Tier 4 encompasses levels 8-10.
  ]
]

=== Tables

There is minimal support for tables (header entries are uppercase), rows alternate in colors.
Of course, you can use all typst table features.

```typst
#box(width: 100%, figure(caption: "Tier 1 Armor", table(
  columns: (auto, auto, auto, 1fr),
  align: (left, center, center, left),
  table.header("Name", "Base\nThresholds", "Base\nScore", "Feature"),

  [*Gambeson Armor*], "5 / 11", "3", [_*Flexible*_: +1 Evasion],
  [*Leather Armor*], "6 / 13", "3", [--],
  [*Chainmail Armor*], "7 / 15", "4", [_*Heavy:*_ -1 to Evasion],
  [*Full Plate Armor*], "7 / 15", "4", [_*Very Heavy:*_ -2 to Evasion; -1 to Agility],
)))
```

#box(width: 100%, figure(caption: "Tier 1 Armor", table(
  columns: (auto, auto, auto, 1fr),
  align: (left, center, center, left),
  table.header("Name", "Base\nThresholds", "Base\nScore", "Feature"),

  [*Gambeson Armor*], "5 / 11", "3", [_*Flexible*_: +1 Evasion],
  [*Leather Armor*], "6 / 13", "3", [--],
  [*Chainmail Armor*], "7 / 15", "4", [_*Heavy:*_ -1 to Evasion],
  [*Full Plate Armor*], "7 / 15", "4", [_*Very Heavy:*_ -2 to Evasion; -1 to Agility],
)))

=== Map Key

A map key can be used to refer to a location on a map, e.g. ```typst #map-key(2)``` yields #map-key(2). You can change color, radius, stroke etc.
