#import "@preview/cetz:0.2.2"
#import cetz.draw: *

#let anchors(anchors) = {
  for (k, v) in anchors {
    anchor(k, v)
  }
}

#let and-gate-body = {
  group(name: "and", {
    merge-path(close: true, {
      arc((0,0), start: -90deg, stop: 90deg, radius: 0.5, name: "curve", anchor: "origin")
      line(
        (0, 0.5),
        (-0.5, 0.5),
        (-0.5, -0.5)
      )
    })
  
    anchors((
      "bin 1": (-0.5, 0.25),
      "in 1": (rel: (-0.5, 0)),
      "bin 2": (-0.5, -0.25),
      "in 2": (rel: (-0.5, 0)),
      "bout": (0.5, 0),
      "out": (rel: (0.5, 0)),
      "north": (0, 0.5),
      "south": (rel: (0, -1)),
      "east": "out",
      // "west": ("in 1", "|-", "center"),
      // "left": ("bin 1", "|-", "center"),
      "right": "bout"
    ))
  })
}

#let or-gate-body = {
  group(name: "or", {
    merge-path(close: true, {
      arc((0.5, 0), start: -90deg, stop: -30deg, anchor: "arc-end", name: "bcurve")
      arc((0.5,0), start: 30deg, stop: 90deg, anchor: "arc-start", name: "tcurve")
      line("tcurve.end", (-0.5, 0.5))
      arc((), start: 30deg, stop: -30deg, anchor: "arc-start", name: "la")
      line("bcurve.start", "la.end")
    })
  
    // x coordinate of where the input legs touch the body of the gate
    let x = calc.cos(calc.asin(0.25)) - calc.cos(calc.asin(0.5)) - 0.5
    anchors((
      "bin 1": (x, 0.25),
      "in 1": (-1, 0.25),
      "bin 2": (x, -0.25),
      "in 2": (-1, -0.25),
      "bout": (0.5, 0),
      "out": (rel: (0.5, 0)),
      "north": (0, 0.5),
      "south": (rel: (0, -1)),
      "east": "out",
      // "west": ("in 1", "|-", "center"),
      // "left": ("bin 1", "|-", "center"),
      "right": "bout"
    ))
  })
}

#let xor-bar = {
  group(name: "xor", {
    arc((-0.6, -0.5), start: -30deg, stop: 30deg)
    anchors((
      "ibin 1": "bin 1",
      "ibin 2": "bin 2",
      "bin 1": (rel: (-0.1, 0), to: "bin 1"),
      "bin 2": (rel: (-0.1, 0), to: "bin 2"),
      // "body left": "left",
      // "left": (rel: (-0.1, 0), to: "left")
    ))
  })
}

#let logic-gate-legs(g) = for a in ("in 1", "in 2", "out") {
  line(g + ".b" + a, g + "." + a)
}

#let and-gate = {
  and-gate-body
  logic-gate-legs("and")
}

#let or-gate = {
  or-gate-body
  logic-gate-legs("or")
}

#let xor-gate = {
  group(name: "xor", {
    or-gate-body
    copy-anchors("or")
    logic-gate-legs("or")
    xor-bar
  })
}