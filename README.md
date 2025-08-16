# Typstborne

A simple template for creating documents for [Daggerheart](https://www.daggerheart.com).
Check out the `test_template.pdf` to see what's currently possible.

## Features

- Parse stat blocks from json and format them in the style of official stat blocks
- Generate encounter tables. Print them out and run your encounters. Mark hit points, strees and conditions.
- Styling for tables, boxed text and map keys.

## Usage

Copy `daggerheart_template.typ` into your project and import it in your document:

### Parse and Display Adversaries and Environments

```typst
#import "daggerheart_template.typ": adversary, daggerheart, encounter_table, environment

#adversary(json("adversary_json/Apprentice Assassin.json"))
```

### Create Encounter Tables

`encounter_table` builds a list of adversaries including the things you would usually track as GM during an encounter, i.e. DC, thresholds, HP, Stress and conditions. Optionally, you can add empty rows in case you need to add something on the fly. You can also add a number of PCs and a Tier - it will automatically calculate and display used and optimal battle points.

```typst
#box(radius: 4pt, stroke: 0.5pt, inset: 10pt, encounter_table(
    (
        ("adversary": json("adversary_json/Jagged Knife Lieutenant.json"), "count": 1),
        ("adversary": json("adversary_json/Jagged Knife Hexer.json"), "count": 1),
        ("adversary": json("adversary_json/Jagged Knife Bandit.json"), "count": 3),
        ("adversary": json("adversary_json/Jagged Knife Lackey.json"), "count": 3),
    ),
    encounter_name: "Jagged Knife Encounter",
    tier: 1,
    display_battle_points: true,
    add_empty_rows: 3,
    display_conditions: false,
    number_pcs: 3,
))
```

## Disclaimer:

This project uses content from the [Daggerheart System Reference Document 1.0](https://www.daggerheart.com/srd/), © Critical Role, LLC, under the terms of the [Darrington Press Community Gaming (DPCGL) License](http://www.darringtonpress.com/license).