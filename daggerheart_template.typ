#import "@preview/cmarker:0.1.6"

#let numberingH(c) = {
  return numbering(c.numbering, ..counter(heading).at(c.location()))
}

#let currentH(level: 1) = {
  let elems = query(selector(heading.where(level: level)).after(here()))

  if elems.len() != 0 and elems.first().location().page() == here().page() {
    return [#elems.first().body]
  } else {
    elems = query(selector(heading.where(level: level)).before(here()))
    if elems.len() != 0 {
      return [#elems.last().body]
    }
  }
  return ""
}

#let signed_value(value) = {
  if value > 0 {
    [+#value]
  } else {
    [#value]
  }
}


#let boxed_text(content, width: 80%, fill: luma(240)) = {
  block(width: width, fill: fill, [
    #line(length: 100%, stroke: 0.5pt + black)
    #content
    #line(length: 100%, stroke: 0.5pt + black)
  ])
}

#let map-key(number, circle_args: (radius: 0.35em, fill: black), text_args: (size: 0.5em, fill: white)) = {
  box(circle(..circle_args)[#align(center + horizon, text(..text_args)[#number])])
}


#let format_experience(exp) = {
  [#exp.name #signed_value(exp.value)]
}

#let adversary_stats(statistics, experience) = {
  boxed_text(fill: luma(240), width: 100%, [
    #pad(left: 1em)[
      *Difficulty:* #statistics.difficulty |
      #if statistics.major != none {
        [*Thresholds:* #statistics.major/#statistics.severe |]
      } else {
        [*Thresholds:* None |]
      }
      *HP:* #statistics.hp |
      *Stress:* #statistics.stress
      #linebreak()
      *ATK:* #signed_value(statistics.atk) |
      *#statistics.weapon:* #statistics.range |
      *Damage:* #statistics.damage #statistics.damage_type
    ]
    #if experience.len() > 0 {
      line(length: 100%, stroke: (paint: gray, thickness: 0.5pt, dash: "dotted"))
      pad(left: 1em)[
        *Experiences:* #experience.map(format_experience).join(", ")
      ]
    }
  ])
}

#let environment_stats(difficulty, potential_adversaries) = {
  boxed_text(fill: luma(240), width: 100%, pad(left: 1em)[
    *Difficulty:* #difficulty \
    *Potential Adversaries:* #potential_adversaries.join(", ")
  ])
}

#let questions(q, size: 0.85em) = text(style: "italic", weight: "light", size: size)[#q]

#let features(features) = {
  show regex("\d*d\d+((\+|-)\d+)?"): set text(weight: "bold")
  show regex("Countdown \(\d+d\d+\)"): emph
  set par(hanging-indent: 1em, spacing: 1em)
  [
    #text(size: 1.2em, upper("Features"))
    #parbreak()
    #for feature in features {
      [
        #emph([*#feature.name -- #feature.type:*]) #cmarker.render(feature.description) \
        #if "questions" in feature {
          text(style: "italic", weight: "light")[#feature.questions]
        }
        #parbreak()
      ]
    }
  ]
}

#let adversary(adv, width: 100%, block_stroke: 0.5pt) = {
  set text(
    size: 0.8em, //7pt,
    // font: "Avenir",
  )
  set par(spacing: 0.65em)
  block(
    stroke: block_stroke,
    width: width,
    inset: 5pt,
    radius: 2pt,
    breakable: false,
  )[
    #text(size: 1.4em)[#upper(strong(adv.name))]

    #emph([*Tier #adv.tier #upper(adv.type)*]) \
    #emph(adv.description) \
    *Motives & Tactics:* #adv.motives_and_tactics
    #adversary_stats(adv.statistics, adv.experience)
    #features(adv.features)
  ]
}

#let environment(env, width: 100%, block_stroke: 0.5pt) = {
  set text(
    size: 0.8em, //7pt,
    // font: "Avenir",
  )
  set par(spacing: 0.65em)
  block(
    stroke: block_stroke,
    width: width,
    inset: 5pt,
    radius: 2pt,
    breakable: false,
  )[
    #text(size: 1.4em)[#upper(strong(env.name))]

    #emph([*Tier #env.tier #upper(env.type)*]) \
    #emph(env.description) \
    *Impulses:* #env.impulses
    #environment_stats(env.difficulty, env.potential_adversaries)
    #features(env.features)
  ]
}

#let adversary_short(adv, display_conditions: true) = {
  let color = luma(125)
  let s = adv.statistics
  let c = box(circle(radius: 0.4em, stroke: 0.5pt))
  let b = box(rect(width: 0.7em, height: 0.7em, stroke: 0.5pt))
  let hp = range(s.hp).map(_ => c).join(h(0.2em))
  let stress = range(s.stress).map(_ => c).join(h(0.2em))
  let name = [#upper(adv.name)]
  let th = if lower(adv.type) == "minion" {
    name = [#upper(adv.name) #text(fill: color, upper(adv.features.at(0).name))]
    [None]
  } else if lower(adv.type).split(" ").at(0) == "horde" {
    name = [#upper(adv.name) #text(fill: color, upper(adv.type))]
  } else {
    [#s.major / #s.severe]
  }
  let d = (
    "name": name,
    "difficulty": [#s.difficulty],
    "threshold": th,
    "hp": [#hp],
    "stress": [#stress],
  )
  let conditions = (
    "vulnerable": b,
    "restrained": b,
    "hidden": b,
  )
  if display_conditions {
    d += conditions
  }
  d
}

#let _type_points = (
  "minion": 1,
  "social": 1,
  "support": 1,
  "horde": 2,
  "ranged": 2,
  "skulk": 2,
  "standard": 2,
  "leader": 3,
  "bruiser": 4,
  "solo": 5,
)

#let calculate_battlepoints(adversaries, tier, number_pcs) = {
  let points = 0
  let adjustment = 0
  let solos = 0
  let no_horde_bruiser_leader_solo = true
  let is_lower_tier = false
  let minions = 0
  for a in adversaries {
    let t = lower(a.type).split(" ").at(0) // Needed for Horde (X/HP)
    if t == "minion" {
      minions += 1
    } else {
      points += _type_points.at(t)
    }
    if t == "solo" {
      solos += 1
      no_horde_bruiser_leader_solo = false
    }
    if t == "horde" or t == "bruiser" or t == "leader" {
      no_horde_bruiser_leader_solo = false
    }
    if a.tier < tier {
      is_lower_tier = true
    }
  }
  points += calc.floor(minions / number_pcs)
  if is_lower_tier {
    points -= 1
  }
  if no_horde_bruiser_leader_solo {
    points += 1
  }
  points
}

#let empty_line(display_conditions: true) = {
  let c = box(circle(radius: 0.4em, stroke: (thickness: 0.5pt, dash: "densely-dotted")))
  let b = box(rect(width: 0.7em, height: 0.7em, stroke: 0.5pt))
  let hp = range(12).map(_ => c).join(h(0.2em))
  let stress = range(12).map(_ => c).join(h(0.2em))
  let row = ([], [], align(center, "/"), hp, stress)
  if display_conditions {
    row += (b, b, b)
  }
  row
}

#let encounter_table(
  adversaries,
  display_battle_points: false,
  number_pcs: 4,
  tier: 0,
  encounter_name: none,
  display_conditions: true,
  add_empty_rows: 0,
  battle_point_adjustment: 0,
) = {
  let with_duplicates = ()
  for ac in adversaries {
    for _ in range(ac.count) {
      with_duplicates.push(ac.adversary)
    }
  }
  if with_duplicates.len() == 0 {
    display_battle_points = false
  }

  let standard_bps = (3 * number_pcs) + 2 + battle_point_adjustment

  let caption = if display_battle_points {
    if encounter_name != none {
      [#encounter_name\ #text(
          0.8em,
          [*Battle Points:* #calculate_battlepoints(with_duplicates, tier, number_pcs) / #standard_bps | *Tier:* #tier | *PCs:* #number_pcs],
        )]
    } else {
      [#text(
          0.8em,
          [*Battle Points:* #calculate_battlepoints(with_duplicates, tier, number_pcs) / #standard_bps | *Tier:* #tier | *PCs:* #number_pcs],
        )]
    }
  } else {
    encounter_name
  }

  let empty_lines = range(add_empty_rows).map(_ => empty_line(display_conditions: display_conditions)).flatten()
  let align = (
    left + horizon,
    center + horizon,
    center + horizon,
    left,
    left,
  )
  let columns = (
    1fr,
    2.5em,
    5em,
    7.3em,
    7.3em,
  )
  let header = ("Name", "DC", "M / S", "HP", "Stress")

  if display_conditions {
    align += (
      center + horizon,
      center + horizon,
      center + horizon,
    )
    columns += (auto, auto, auto)
    header += ("V", "R", "H")
  }

  figure(caption: caption, table(
    gutter: 0.5pt,
    align: align,
    columns: columns,
    table.header(..header),
    ..with_duplicates.map(a => adversary_short(a, display_conditions: display_conditions).values()).flatten(),
    ..empty_lines,
  ))
}


// Actual template
#let daggerheart(
  paper: "a4",
  font: "Avenir",
  font_size: 10pt,
  doc,
) = {
  set page(
    paper: paper,
    margin: auto, //(inside: 2.5cm, outside: 2cm, y: 1.75cm),
    background: none,
    numbering: "1",
    footer: context {
      align(right, stack(
        dir: ltr,
        spacing: 1em,
        upper(currentH()),
        line(length: 100%, angle: 90deg, stroke: (dash: "dotted")),
        counter(page).display(),
      ))
    },
  )

  set text(
    size: font_size,
    font: font,
  )

  // Fear & Stress
  show regex("(M|m)ark (\d|a) Stress"): set text(weight: "bold")
  show regex("(S|s)pend (\d|a) Fear"): set text(weight: "bold")
  show regex("(L|l)ose (\d|a) Fear"): set text(weight: "bold")

  // Conditions
  show "Vulnerable": emph("Vulnerable")
  show "Hidden": emph("Hidden")
  show "Restrained": emph("Restrained")

  // // Dice
  // show regex("\d+d\d+((\+|-)\d+)?"): set text(weight: "bold")
  // show regex("Countdown \(\d+d\d+\)"): emph

  // Headings
  show heading.where(level: 1): it => block(width: 100%, below: 1.2em)[
    #set align(left)
    #set text(size: 2em, weight: "regular")
    #upper(it.body)
  ]

  show heading.where(level: 2): it => block(width: 100%)[
    #set align(left)
    #set text(size: 1.6em, weight: "bold")
    #upper(it.body)
  ]

  show heading.where(level: 3): it => block(width: 100%)[
    #set align(left)
    #set text(size: 1.4em, weight: "regular")
    #upper(it.body)
  ]

  show heading.where(level: 4): it => block(width: 100%)[
    #set align(left)
    #set text(size: 1.3em, weight: "regular")
    // #box(rect(width: 0.8em, height: 0.8em, fill: gray))
    #upper(it.body)
  ]

  // Table in figure
  show figure.where(kind: table): it => {
    show figure.caption: set text(
      size: 1.4em,
      weight: "regular",
    )
    show figure.caption: it => { align(left, upper(it)) }
    it
  }

  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(numbering: none)

  // Table
  set table(
    fill: (x, y) => if y == 0 {
      return none
    } else if calc.rem(y, 2) == 0 {
      return luma(240)
    },
    stroke: (_, y) => if y == 0 { (bottom: 1pt) },
  )
  show table.cell.where(y: 0): it => { align(bottom, upper(text(weight: "bold", it))) }

  doc
}




