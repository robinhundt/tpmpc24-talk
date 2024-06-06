#import "@preview/polylux:0.3.1": *
#import themes.clean: *
#import "template.typ": *
#import "@preview/cades:0.3.0": qr-code
#import "@preview/cetz:0.2.2"

#show: encrypto-theme.with(
  authors: (underline("Robin Hundt"), "Nora Khayata", "Thomas Schneider"), 
  title: "SEEC: Memory Safety Meets Efficiency in Secure Two-Party Computation",
  note-slides: false
)

#show link: l => text(l, fill: blue)

#let refs = toml("refs.toml")

#let cite(key) = {
  let inner = if type(key) == str {
    link(label(key), refs.at(key).display)
  } else if type(key) == array {
    key.map(k => {
      link(label(k), refs.at(k).display)
    }).join(",")
  }
  [[#inner]]
}

#let rarr = sym.arrow.r 

#let blue-st = rgb("#6C8EBF")
#let green-st = rgb("#82B366")
#let orange-st = rgb("#D79B00")
#let yellow-st = rgb("#D6B656")
#let red-st = rgb("#B85450")

#show figure.where(kind: "code"): it => {
  align(start, it.body)
  v(if it.has("gap") {it.gap} else {0.65em})
  set align(center)
  pad(x: 1cm)[#it.caption]
}

#let code(filename) = {
  raw(read("code/"+filename), lang: "rust", block: true)
}

#let icon-text(icon, folder: "diagrams", height-inc: 1em, content) = {
  let scaled-icon = style(styles => {
    let size = measure(content, styles)
    let height = size.height + height-inc
    image(folder +"/"+ icon, height: height)
  })
  stack(dir:ltr, 
      scaled-icon,
      h(1em),
      align(horizon, content)
    )
}

#let dline = line.with(stroke: (paint: gray, dash: "dashed"))

#title-slide(sub-title: none)[
  #set align(center+horizon)
  #image("diagrams/title-slide.svg", height: 50%)
]

#slide[Feedback][
#set text(size: 10pt)
#stack(dir: ltr)[  
// - move future work to appendix
// - slide 3: split this slide into multiple
// - Slide 7: add headline and black bar so its clear that I'm comparing
- don't spend so much time on memory
- slide 9: don't go into lazy iterator details
- slide 11: don't use preprocessing, but better compile
- practice more
- slide 12: leave out throughput
- slide 12: don't mention that you wouldn't execute AES-CBC in MPC
- slide: mention that I'm benchmarking GMW B
- bench slides: one conclusion for each slide
- slide 17: runtime numbers
- slide 18: remove eval mode
- slide 18: have take home message, memory safety and efficiency
- slide 18 references
- slide 18: reemphasize that sub-circuits don't increase depth
- slide 18: rename to summary
- kasra: slides are overloaded
 	- map what I'm saying to
	- heavy on acronyms
- more clear steps
- legend for acronyms in benchmark
][
  Thomas:
Slide 1: "Joint work with Nora Khayata and Thomas Schneider"
Also say you built SEEC during your Master thesis (that's a great achievement!)

Slide 3: Where do the 70 sth. percent occur in the figure? Couldn't find that.

Slide 4: ALSZ13

Slide 6/7: Call function func rather than process (process resembles a process/thread to me)

Slide 7: Put headlines above left (???) and right (graph-based) column 

Slide 10: Remove "Figure 1:" and "Figure 2:"

Slide 11: Couldn't relate abbreviations (FG) and (IS) to rest of these columns
"Stored MT Streaming" is not clear to me. Maybe "Stored Stream of MTs" instead?

Slide 12: You can remove the Frameworks with which you compare from the previous overview slide on SEEC (saves time and less redundancy)

Slide 12: Explicitly mention your MPC benchmarking tool somewhere (either here or in the SEEC overview slide before) as this is an interesting contribution

Slide 14: Remove , at the end of legends (for ABY, MOTION, MP-SPDZ) also in other slides => just put a white box on top. Also put [DSZ15] etc. references s.t. one sees that this was previous work and from which year

Slide 15: Write out acronyms DL / FG / IS / SL at the bottom again (audience might have forgotten these already by now: DL: Dynamic Layer, ...

Slide 16: Remove 2, 5 intermediate values on x axis as you are not using them.

Slide 17: Fast-LAN => LAN10G, LAN => LAN1G, WAN => WAN100M (self-speaking names)

Slide 18: 16x - 1,983x (round to whole numbers to avoid confusing)

Slide 19: Do NOT say that SEEC is work in progress (this could kill our CCS submission)
Completely move Future Work slide 19 to backup slides to strengthen our CCS submission and save time.
]

]

// #slide(notes: ```md
// - Motivations
// - Preliminaries, specifically the GMW protocol
// - The MPC pipeline
// - our framework SEEC with its support for memory- and round-efficient sub-circuits
// - benchmarks where we compare against several prior works across multiple axes
// ```)[Agenda][
//   #set align(center + horizon)
//   #set image(height: 3em)
//   #show regex(`sub_circuit`.text): set text(fill: orange.darken(10%))
  
//   #grid(columns: (1fr,) * 5, row-gutter: 0.5em)[
//     #image("diagrams/memory.svg", height: 3em)
//   ][
//     #image("diagrams/notes.svg", height: 3em)
//   ][
//     #image("diagrams/graph.svg", height: 3em)
//   ][
//     ```rust
//     #[sub_circuit]
//     ```
//   ][
//     #image("diagrams/bench.svg")
//   ][
//     Memory Safety
//   ][
//     SEEC
//   ][
//     Functions in MPC
//   ][
//     Sub-Circuits
//   ][
//     Benchmarks
//   ]
// ]

#slide(notes: ```md
  - In recent years, Memory Safety of Applications and Programming Languages has received increasing interest. Due to an increasing dependence of our privacy on the security of digital systems, memory safety as one piece of secure systems, is becoming more and more important.
  - However, experience hash shown time and time again, that high-impact vulnerabilities due to memory unsafety are virtually unavoidable in large projects written in C/C++.
  - A recent examination of the high severity security impacting bugs in Chromium revealed that 70 % are due to memory unsafety. And, this is corroborated by other large projects, such as Windows and Android.
  - This is relevant, as MPC applications are networked services, potentially exposed to the Internet, and which are usually written in C/C++. 
  - The Memory Safety of these applications will becomer more important as MPC progesses from research to real-world deployments.
  - The reason C/C++ are so often used in MPC, is the performance and efficiency of the resulting implementations.
  [NEXT SLIDE]
  - To shift MPC from the largely theoretical to the practical we need to optimize its performance and efficiency
  - One aspect of efficiency which we've focused on with SEEC, is memory efficiency
  - This is especially relevant if we want to target mobile devices, where the most common RAM configuration was 4 GB in 2022.
  - But it's also relevant to deployments on servers, where reduced memory consumption can allow us to tackle larger problems or reduce operating costs 
```)[Motivation][
#grid(columns: (1fr, 1fr), gutter: 1em)[
  == Safety
  #set align(center)
  #cetz.canvas({
    let data = (
      ([Security-related assert],     7.1),
      ([Other],     23.9),
      ([Memory Unsafety],      69),)
    import cetz.chart
    import cetz.draw: *
  
    let colors = gradient.linear(blue, green, yellow)
  
    chart.piechart(
      data,
      value-key: 1,
      label-key: 0,
      radius: 3,
      slice-style: colors,
      inner-radius: 1,
      outset: (2,3),
      outset-offset: 7%,
      name: "c",
      outer-label: (content: none),
      inner-label: (content: "%", radius: 115%))
      content((rel: (1,1), to: "c.item-0"), data.at(0).at(0))
      content((rel: (1.1,0), to: "c.item-1"), data.at(1).at(0))
      content((rel: (-3,+4.6), to: "c.item-2"), data.at(2).at(0))
    })
    #text(size: 0.5em)[
      Source: #link("https://www.chromium.org/Home/chromium-security/memory-safety/")[The Chromium Projects - Memory Safety]
    ]
][
  #pause
  == Efficiency
  #set align(horizon + center)
#cetz.canvas({
    let data = (
      ([2],     10.08),
      ([3],     19.96),
      ([4],     34.80),
      ([6],     20.95),
      ([8],     9.17),)
    import cetz.chart
    import cetz.draw: *
  
  
    chart.columnchart(
      data,
      value-key: 1,
      label-key: 0,
      size: (10, 6),
      x-label: "Smartphone RAM (GB)",
      y-label: "%",
      bar-style: (
        fill: blue.lighten(20%),
        stroke: none,
        axes: (
        )
      )
    )})
    #text(size: 0.5em)[
      Source: #link("https://www.scientiamobile.com/how-much-ram-is-in-smartphones/")[scientiamobile, 2022]
    ]
  
  // #image("diagrams/smartphone-ram-2022.png")
  // - No Garbage Collector
  // - Precise control over memory
  // - SIMD support
  // - C/C++ interoperability
]

]

#slide(notes: ```md
- Okay, so what do we contribute with SEEC?
- Because we wanted to achieve a memory safe and efficient MPC framework, which also provides good performance and a nice developer experience, the natural choice was Rust as a programming language for us.
- It's a memory safe language, with performance similar to C/C++, control over memory allocations without garbage collection, and a good developer experience due to fantastic tooling.
- With SEEC, we provide a high-level embedded domain specific language to contruct circuits, and also the option to use FUSE or Bristol circuits.
- We provide a memory- and round-efficient implementation of sub-circuits with optional support for MPC level SIMD.
- And our API supports both function-independent and dependent preprocessing.
- What I personally really like, is that SEEC is extensibile without a need for forking if you use it as a library to implement your protocol in.
- And, it is also cross-platform which we test in our continous integration pipeline.
```)[[#underline[S]EEC #underline[E]xecutes #underline[E]normous #underline[C]ircuits (SEEC)]][
  #set align(left + horizon)
  #set list(marker: none)
  #set stack(dir: ltr, spacing: 1em)
  #grid(columns: (1fr, 1fr), column-gutter: 2em)[
    #set align(center)
    #image("logos/rust-logo.svg", height: 3.5cm)
  ][
    #let icon(name, folder: "diagrams", content) = {
      stack(dir:ltr,
        image(folder + "/"+name+".svg", height: 1.5em),
        align(horizon, content),
      )
      v(-0.4em)
    }
    #stack(dir: ttb, spacing: 0.3em)[
      #icon("code")[High-Level eDSL / FUSE #cite("fuse23")]
    ][
      #icon("graph")[(SIMD) Sub-Circuits]
    ][
      #icon("preprocessing")[Function (In-)Dependent Setup]
    ][
      #icon("extension")[Extensibility w/o forking]
    ][
      #stack(dir:ltr,
        box(height: 1.5em, width: 1.5em, image("logos/windows.svg", height: 1.3em)),
        align(horizon, [Cross-Platform]),
      )
    ]
  ]
]

#slide(notes:```md
- Currently, SEEC is aimed at linear secret sharing based protocols, think GMW, with semi-honest security and two parties. 
- We plan to extend SEEC to also provide facilities for multiple-parties and maliciously secure protocols.
- The currently implemented protocols are  GMW
```[[#underline[S]EEC #underline[E]xecutes #underline[E]normous #underline[C]ircuits (SEEC)]][
  #set align(left + horizon)
  #set list(marker: none)
  #set stack(dir: ltr, spacing: 1em)
  #grid(columns: (1fr, 1fr), column-gutter: 2em)[
    #stack()[
      #image("diagrams/prot-arrows.svg", height: 2cm)
    ][
      - 2PC GMW (A/B) #cite(("gmw","bea92"))
      - 2PC GMW (A+B) #cite("aby")
      - ASTRA (B#sym.ast.basic) #cite("astra")
      - ABY2.0 (B#sym.ast.basic) #cite("aby2")
      - OT: #cite("alsz13"), Silent OT #cite("bcg19")
    ]
  ][
    #stack()[
      #image("diagrams/bench.svg", height: 3cm)
    ][
      #link("https://github.com/encryptogroup/mpc-bench")[encrytpogroup/mpc-bench]
    ]
  ]
  #place(left + bottom, text(size: 0.5em)[#sym.ast.basic Partial Implementation])
]

#slide(alignment: horizon, notes:```md
- in traditional programs, functions are an important tool for building abstractions and organizing code
- they also reduce the size of the binary, inlining every function would result in a tremendous overhead
  - yet, this is exactly what we often do in MPC

```)[Functions in Traditional Programs][
  #code("normal-code.txt")
]

#slide(alignment: horizon, notes: ```md
- ideally when using MPC to securely evaluate a functionality, we want to express it in a high-level way
  - this should include the capability for using functions
  - code should be fairly close to traditional code, to ease development of MPC applications
  - some slight differences such as the changed types here, are okay; and likely necessary
- crucially, we want to not only use functions for organization, but also for reduced memory consumption during the MPC protocol's evaluation
- this is important for the real world deployment of MPC, where we might operate on memory-constrained devices or have very large  inputs
- with our work SEEC, we have implemented and extensively benchmarked and compared one possible solution  
```)[Circuit Reuse in Secure Programs][
  #let color = red.lighten(70%)
  #let mark(dx) = {
    place(
      rect(height: 1.2em, width: 2.7em, fill: color, radius: 30%), dy: -2mm, dx: dx
    )  
  }
  #grid(columns: (1fr, auto, 1fr))[
    #code("normal-code.txt")
  ][
    #place(center + horizon, dx: -0.5em, dline(end: (0%, 75%)))
  ][
    #mark(7em)
    #mark(13.8em)
    #code("secret-code.txt")
  ]
  #let make-opaque(dx) = {
    place(left + bottom, 
      dy: -0.5em,
      dx: dx,
      rect(fill: rgb(255, 255, 255, 120), height: 55%, width: 48%)
    )
  }
  #make-opaque(0%)
  #make-opaque(50%)
]

// #slide([Motivation])[
// Idea of the slide: Show that functions are an important tool for building abstractions and organizing code in normal computation. We want to do the same in MPC. Already mention works like HyCC?
// - left: functions reduce memory of repr
// - right: we want to reduce memory of (circuit) repr
// - should have several function calls
// - have `process` function that takes input and returns output, call twice, second time with output from first
// - add something here
// ]

// #slide[Goldreich, Micali, Wigderson (GMW)][
//   - MPC intro here
//   - explain GMW protocol on a high-level
//   - focus on the property that it takes $O(d)$ communication rounds
// ]


// #slide(notes: ```md
// - okay, but first some preliminaries, what even is MPC?
// - on the left, we now have Alice and Bob who have agreed to compute the previous function, where the `process` function simply computes an AND of its inputs
// - the GMW protocol for secure 
// - briefly explain 2PC and MPC
// - GMW protocol operates on a Boolean circuit representation of a functionality
// - in our example, the earlier source code was translated into a circuit where the `process` function simply computes an AND of the inputs
// - remove alice's head here, otherwise confusing why only single party
// ```)[Goldreich, Micali, Wigderson #cite("gmw")][
//   #box(width: 70%)[
//     #image("diagrams/gmw-Page-1.svg")

//     #let procb = rect(
//       ```rust
//       fn process([SBool; 2]) 
//         -> SBool;
//       ```,
//       inset: (left: 25mm),
//       radius: 20%,
//       stroke: (paint: gray, dash: "dashed")
//     )
//     #place(top + left, procb, dx: 33mm, dy: 49mm)
//   ]
// ]

// #slide(notes: ```md
// - both parties hold secret inputs, which they secret share with each other using a 2 out of 2 XOR secret-sharing
// - for each And gate, they have a local computation 
// ```)[Goldreich, Micali, Wigderson #cite("gmw")][
//   #grid(columns: (70%, 1fr))[
//     #image("diagrams/gmw-Page2.svg")
//   ][
//     #set align(horizon)
//     #set text(size: 0.8em)
//     XOR-Sharing:
//     $ a = [a]_0 xor [a]_1 $
//     Multiplication Triple #cite("bea92"):
//     $ "MT" = (a, b, c) $
//     s.t. $c = a and b$.
//     $ ["MT"]_i = ([a]_i, [b]_i, [c]_i) $
//   ]
// ]

// #slide[Goldreich, Micali, Wigderson #cite("gmw")][
//   #grid(columns: (70%, 1fr))[
//     #image("diagrams/gmw-Page-3.svg")
//   ][
//     #set align(horizon)
//     #set text(size: 0.8em)
//     Multiplicative depth: $d$
  
//     #h(1em) Here: $d = 2$
    
//     Communication rounds: $cal(O)(d)$
//   ]
// ]

// #slide("MPC-Pipeline", alignment: horizon)[
//   #image("diagrams/high-level-pipeline-Page-1.svg")
// ]

// #slide("MPC-Pipeline: Our Focus", alignment: horizon)[
//   #image("diagrams/high-level-pipeline-Page-2.svg")
// ]

#slide(notes: ```md
TODO: Maybe animate this slide
```)[Sub-Circuits in GMW: Challenges][
  #set list(marker: rarr)
  #set text(size: 0.9em)

  #let phase(color, col1, col2) = {
    rect(stroke: (paint: color, dash: "dashed"), radius: 20%, outset: 0.4em)[
      #grid(columns: (1fr, 1fr), col1, col2)
    ]
    
  }
  
  #grid(columns: (30%, 1fr))[
    #image("diagrams/high-level-pipeline-Page-3.svg")
  ][
    #phase(blue-st)[
      ```rust
    func(a);
    func(b);
    ```
    ][
      #set align(horizon)
      `a` and `b` are indepent
    ]
    #pause
    #phase(orange-st)[
      #text(fill: black.lighten(25%), [=== Bytecode VM])
      ```
      func:
        # ...
        ret

      call func
      call func
      ```
      #place(center + horizon, dx: 4cm, dline(end: (0%, 50%)))
    ][
      #text(fill: black.lighten(25%), [=== Graph based])
      #only((2,3), image("diagrams/parallel-circ.svg", height: 40%))
      #place(`func`, dx: 1.5cm, dy: -1.6cm)
      #place(`func`, dx: 6.4cm, dy: -1.6cm)
    ]
    #pause
    #phase(red-st)[
      - Increased rounds
      - `func` only once in memory
      #place(center + horizon, dx: 4cm, dy: 0cm, dline(end: (0%, 15%)))
    ][
      - Concurrent evaluation
      - Increased Memory
    ]
  ]
]

// #slide[Concurrent Evaluation][
//   - example that shows that sub-circuits can't be executed sequentially, but must be executed concurrently
//   - maybe only briefly introduce GCs here if I want to refer to it here
//   - briefly mention GC works where sequential evaluation is okay (maybe bonus slide for this)
// ]

// #slide([SEEC: Design Goals])[
//   - Memory Efficient MPC implementation
//   - Implementation of Sub-Circuits for SS-based protocols
//   - Zero-Overhead Abstractions
//   - Support for FDP protocols
//     - mhh, if I mention that here, do I need to include FIP/FDP split in prelims?
// ]

#let cnt = counter(figure.where(kind: "code")) 
#cnt.step()

#slide([SEEC: eDSL Enables Efficient Circuit Reuse])[
  #set align(center)
  #let split-code(file, lines) = {
    let text = read("code/"+file).split("\n").slice(..lines).join("\n")
    raw(text, lang: "rust", block: true)
  }

  #let opaque-line(dx, dy) = {
    place(left + top, 
      dx: dx,
      dy: dy,
      rect(fill: rgb(255, 255, 255, 120), height: 1.1em, width: 100%)
    )
  }
  #align(horizon, grid(columns: (60%,auto, auto))[
    #set align(top)
    #show regex(`sub_circuit`.text): set text(fill: orange.darken(10%))
    
    #split-code("sub-circuit-macro.txt", (0,9))
    #opaque-line(0em, 3.1em)
    #opaque-line(0em, 7.7em)
  ][
    #show: place.with(dx: -0.7em)
    #line(end: (0%, 65%), stroke: (paint: gray, dash: "dashed"))
  ][
    #set align(top)
    #uncover(2)[#split-code("sub-circuit-macro.txt", (9,14))]
    #opaque-line(0em, -0.2em)
  ])

  
  
  // #uncover((1,2))[Listing #cnt.display(): `#[sub_circuit]` macro turns function into memory-efficient reusable sub-circuit. ]
  
]

#slide[SEEC: Sub-Circuits Are Not Inlined][
  #set par(leading: 1.2em)
  #grid(columns: (auto, 1fr), gutter: 1.5em)[
    #show regex(`sub_circuit`.text): set text(fill: orange.darken(10%))
    #place(raw("#[sub_circuit]\nfn func(...)", lang: "rust"), dx: 110mm, dy: 50mm)
    #image("diagrams/seec-parallel-circ.svg")
  ][
    #show: only.with(2)
    #place(dline(end: (0%, 100%)), dx: -4mm)
    #set align(horizon)
    #let h = icon-text("online.svg")[== Online]
    #align(center, h)
    #v(2cm)

    - Layer iteration *as if* inlined (DL)
      - No increase in depth
    - Partial and concurrent evaluation
    // Layers of sub-circuits are iterated *as if* inlined.
    
    // Sub-circuits can be evaluated partially and concurrently. 
  ]
]

// #slide([SEEC: In-Memory Representation])[
//   - not sure if I want to have this here or maybe in appendix
//   - I could have the AES-CBC example here where I show that I can have a sub-circuit multiple times withtin a larger circuit without replicating its definition
//   - maybe here have running example but at circuit level with circ references
//     - this i kind of need anyway for the benchmarks
//   - or maybe I could expand on the circuit connections datastructure
// ]


// Some figure counter hacks that were necessary to get it to work
// with the animation

#slide([Single Instruction, Multiple Data])[
  #set align(bottom + center)
  #grid(columns: (1fr, 1fr))[
    #box({
      image("diagrams/seec-simd-Page-1.svg")
      [Traditional SIMD, e.g., in\ MOTION #cite("motion22").]
    })
  ][
    #pause
    #let cnt = locate(loc => {
      fcnt.at(loc).first() + 1
    }) 
    
    #box({
      image("diagrams/seec-simd-Page-2.svg")
      [SIMD Sub-Circuits in SEEC.\ #hide("a")]
    })
  ]
  #v(1.5cm)
]

#slide(notes: ```md
- TODO: Explain optimizations
- text ist zu erschlagend
- spacing etwas erhöhen, text vllt. etwas kleiner
- maybe auch vorherige scritte ausgrauen
```)[SEEC: Optimizations][
  #show heading: set align(center)
  #let vline = line(end: (0%, 100%), stroke: (paint: gray, dash: "dashed"))
  #show image: set align(center)
  #set image(height: 2em)
  // #show list: set text(size: 0.9em)
  #set par(leading: 0.9em)
  #let make-opaque = {
    place(left + top, 
      dy: -0.5em,
      rect(fill: rgb(255, 255, 255, 120), height: 100%, width: 100%)
    )
  }
  
  #grid(columns: (1fr, auto, 1fr, auto, 1fr), gutter: 5pt)[
    === Static Layers (SL)
    #image("diagrams/graph.svg")
    #h(1em)
    - Transforms Dynamic Layer (DL) representation
    - Layers are precomputed for every call site
    - Precomputed layers are stored deduplicated
    #only((2,3), make-opaque)
  ][#vline][
    === Early Deallocation (ED)
    #image("diagrams/online.svg")
    #h(1em)
    #uncover((2,3))[
      - Unneeded gate outputs are freed
      - Only applies to SIMD circuits
    ]
    #only((1,3), make-opaque)
  ][#vline][
    === Streaming MTs (SMT)
    #align(center, stack(dir: ltr,
      image("diagrams/preprocessing.svg"),
      image("diagrams/online.svg"),
    ))
    #h(1em)
    #uncover(3)[
      - MTs are computed and stored in a file
      - Online: read on-demand in batches from the file
    ]
    #only((1,2), make-opaque)
  ]
]

#set footnote.entry(clearance: 0em, gap: 0em)

#slide(notes: ```md
- Why did we choose these frameworks?

- explain net settings
- hardware: two simx servers 
- mention bench tool


- bench sub-circuit via AES CBC circuit
- bench SIMD via parallel AES and SHA-256 circuits

TODO make clear that we use 2-party semi-hones GMW
```)[Evaluation][
  #grid(columns: (40%, 1fr))[
    #grid(rows: (auto, auto), row-gutter: 1em)[
      === Frameworks

      - ABY #cite("aby")
      - MP-SPDZ #cite("kel20")
      - MOTION #cite("motion22")
      - SEEC (SL / FG / IS)
    ][
      #set list(marker: none)
      #set par(leading: 0.2em)
      === Environment
      
      - #icon-text("online.svg", height-inc: 0.1em)[LAN-0.25ms / LAN-1.25ms \ WAN-100ms]
      - #icon-text("cpu.svg")[$1, 2, dots, 32$ Threads]
      - #icon-text("kde.svg", folder: "logos")[
        Heaptrack#super[1]
      ]
    ]
  ][
    #show: only.with(2)
    === Circuits
    #grid(rows: (56%, auto, 1fr), gutter: 0.5em)[
      // #show: uncover.with((2, 3))
      #grid(columns: (10%, 1fr), gutter: 1em)[
        // hacky hack
        #let t = box([Sub-Circuit], width: 300%)
        #place(center + horizon,rotate(360deg - 90deg, t))
      ][
        #image("diagrams/aes-cbc.svg")
      ]
    ][
      #dline(length: 100%)
    ][
      // #show: uncover.with(3)
      #grid(columns: (10%, auto, 1fr), gutter: 1em)[
        #set align(horizon)
        #rotate(360deg - 90deg)[SIMD]
      ][
        #set align(horizon)
        - AES-128
        - SHA-256
      ][
        #image("diagrams/seec-simd-Page-2.svg", fit: "contain")
      ]
    ]
  ]
  #show: align.with(bottom)
  #set text(size: 0.6em)
  #line(length: 30%, stroke: (paint: gray))
  #super[1] https://github.com/KDE/heaptrack
]

#let overwrite-legend(content, dx: 0em, dy: 0em) = {
  set text(size: 0.66em, fill: black.lighten(20%))
  place(top, dx: 22.7cm + dx, dy: +0.83cm + dy,
    box(fill: white, align(start, content)))
}

#let bottom-legend(..content) = {
  set text(size: 0.6em, fill: black.lighten(20%))
  place(top, dx: 22.5cm, dy: 5cm, grid(columns: 2, gutter: 0.5em, align: (start + horizon, end), ..content))
}

#let note(dx: 0%, dy: 0%, content) = {
  set text(size: 0.9em, fill: black.lighten(20%))
  place(top, dx: dx, dy: dy, box(fill: white, align(start, content)))
}

#slide(notes: ```md
- 50 GB
- 2.2 GB
- 375 MB
```)[AES-CBC: Reduced Memory via Sub-Circuits][
    #image("plots/aes-cbc-seec-variants-max_heap.svg")
    #overwrite-legend(dy: 0.3em)[
      SEEC, DL\
      SEEC, DL/SC\
      SEEC, SL/SC\
    ]
    #bottom-legend[
      DL:
    ][Dynamic Layers][
      SL:
    ][Static Layers][
      SC:
    ][
      Sub-Circuits
    ]
    
    #note(dx: 70%, dy: 0%)[70 GB]
    #note(dx: 70%, dy: 20%)[2.2 GB]
    #note(dx: 70%, dy: 52%)[375 MB]
]

#slide(notes:```md
- at 10k:
  - 210 MB for MP-SPDZ
  - 375 MB for SEEC
- MOTION at 100:
  - ~73 GB
```)[AES-CBC: Reduced Memory via Sub-Circuits][
    #image("plots/aes-cbc-seec-best-max_heap.svg")
    #overwrite-legend[
      ABY #cite("aby")\
      MOTION #cite("motion22")\
      MP-SPDZ #cite("kel20")\
      SEEC, SL/SC
    ]
    #bottom-legend[
      DL:
    ][Dynamic Layers][
      SL:
    ][Static Layers][
      SC:
    ][
      Sub-Circuits
    ]

    #note(dx: 37%, dy: 0%)[73 GB]
    #note(dx: 70%, dy: 0%)[74 GB]
    #note(dx: 70%, dy: 36%)[375 MB]
    #note(dx: 70%, dy: 55%)[210 MB]
]

#slide(notes: ```md
- just SL: No opts: 7.5 GB
- FG: 3.1 GB
- SEEC: ~ 700 MB
```)[AES: Reduced SIMD Memory Usage][
  #image("plots/aes-ctr-seec-variants-max_heap_mb.svg")
  #overwrite-legend[
    SEEC, DL/ED\
    SEEC, DL/SMT/ED\
    SEEC, SL
  ]
  #bottom-legend[
      DL:
    ][Dynamic Layers][
      SL:
    ][Static Layers][
      SC:
    ][Sub-Circuits][
      SMT:
    ][
      Streaming MTs
    ][
      ED:
    ][Early Deallocation]

    #note(dx: 70%, dy: 0%)[7.5 GB]
    #note(dx: 70%, dy: 40%)[700 MB]
]

#slide(notes: ```md
- at 1M:
  - MOTION: 10 GB
  - SEEC: ~ 700 MB
```)[AES: Reduced SIMD Memory Usage][
  #image("plots/aes-ctr-seec-best-max_heap_mb.svg")
    #overwrite-legend[
      ABY #cite("aby")\
      MOTION #cite("motion22")\
      MP-SPDZ #cite("kel20")\
      SEEC, DL/SMT/ED
  ]
  #bottom-legend[
      DL:
    ][Dynamic Layers][
      SL:
    ][Static Layers][
      SC:
    ][Sub-Circuits][
      SMT:
    ][
      Streaming MTs
    ][
      ED:
    ][Early Deallocation]

    #note(dx: 70%, dy: 0%)[10 GB]
    #note(dx: 70%, dy: 40%)[700 MB]
]

#let net-note(dx: 0%, dy: 0%, content) = {
  set text(size: 0.9em, fill: black.lighten(20%))
  place(top, dx: dx, dy: dy, box(fill: white, align(start, content)))
}

#slide(notes: ```md
100 chained AES blocks
- WAN: MOTION 423 s and MP-SPDZ 616 s
```)[AES-CBC Runtime: Effect of Latency][
  #image("plots/aes-cbc-net_comparison.svg")
  #overwrite-legend(dx: 3.8em)[
      LAN-0.25ms\
      LAN-1.25ms\
      WAN-100ms
  ]
  #net-note(dx: 10%, dy: 66%)[1.5]
  #net-note(dx: 16.5%, dy: 51%)[6]
  #net-note(dx: 21%, dy: 6%)[313]

  #net-note(dx: 31%, dy: 25%)[62]
  #net-note(dx: 36.5%, dy: 25%)[64]
  #net-note(dx: 41%, dy: 3%)[424]

  #net-note(dx: 51%, dy: 77%)[0.6]
  #net-note(dx: 56.2%, dy: 48%)[8.5]
  #net-note(dx: 61.5%, dy: 0%)[616]

  #net-note(dx: 71%, dy: 61%)[2.7]
  #net-note(dx: 76.7%, dy: 51%)[6.8]
  #net-note(dx: 81.7%, dy: 6%)[305]
]

#slide(notes: ```md
Mem. Reduction via Sub-Circuits
- support for loops and register allocation of gate outputs can lead to better memory efficiency in some cases (MP-SPDZ)
- however sub-circuits are more versatile, as they can reduce memory consumption of sub-circuit calls at unrelated places of the main circuit
SIMD
- Significantly better SIMD memory consumption
  - largely due to FG and IS optimizations
- Async. Eval. of MOTION has bad perf. for scalar circs but good for massively parallel circs (high SIMD size)
- LBL execution of ABY, MP-SPDZ and SEEC is better for scalar circs
- Network setting can have non-obvious impacts on online perf.
- Predicatbility
- Realiability
```)[Summary][
  #show heading: set align(center)
  #show regex(`sub_circuit`.text): set text(fill: orange.darken(10%))
  #let check = align(center, scale(150%, image("logos/check.svg", height: 1em)))
  #let cross = align(center, scale(150%, image("logos/cross.svg", height: 1em)))
  #let rarrow = sym.arrow.r

  #grid(columns: (1fr,) * 2, rows: (40%, 1fr), row-gutter: 1em)[
    == Sub-Circuits
    #set align(horizon)
    #stack(dir: ltr, spacing: 2cm)[
      #rotate(90deg, image("diagrams/memory.svg", height: 50%))
    ][
      ```rust
      #[sub_circuit]
      fn process(...)
      ```
    ]
  ][
  ][
    == SIMD
    #set align(horizon)
    Up to 15× - 1,983× less memory than MOTION #cite("motion22").
  ][
    #grid(columns: (auto, 1fr, 1fr), rows: (auto,) * 4, row-gutter: 0.8em)[][
      == Predictability
    ][
      == Reliability
    ][
      ABY
    ][ #check ][ #cross ][
      MP-SPDZ
    ][ #cross ][ #check ][
      MOTION
    ][ #cross ][ #check ][
      SEEC
    ][ #check ][ #check ]
  ]
]

// #slide[Discussion][
//   #set text(size: 12pt)
//   #show: columns.with(2)
//   - Sub-Circuits significantly reduce memory consumption in benchmarked use case
//     - achieve memory consumption close to MP-SPDZ with loops
//       - Sequential AES benchmark is ideal for loops, as the function calls *can* be evaluated sequentially
//       - the benefit of concurrent execution of SCs -- not present for MP-SPDZ function calls -- is not evaluated (TODO don't say this... :D)
//       - we argue that SEEC SC calls are more versatile, due to their concurrent and partial evaluation
//   - Our optimizations for the SIMD benchmark significantly reduce memory consummption
//   - using them, we are able to execute large parallel circuits *not possible* in the other frameworks
//   - evaluated frameworks have differing levels of reliability and predictability 
//   - ABY offers very predictable performance metrics, but has bad reliability and is unable to execute large circuits
//   - MP-SPDZ has unpredictable performance (see mem and net comp) and is also unable to execute very large circuits
//   - MOTION has unpredictable performance but is generally reliable and can execute very large circuits, given enough RAM
//   - SEEC generally has predictable but supoptimal perfornamce, but is very reliable
//   - generally: support for higher-level concepts such as function calls or SIMD can reduce memory consumption and lead to better runtime efficiency
//   - for this to work, concepts must be present in some form in all stages of the mpc pipeline
//     - if you can use function calls at the high-level description, but they are completely inlined at the in-memory level, you don't have a memory benefit (e.g. current HyCC backend)
// ]

// #slide[Contributions][
//   - make contributions clear
//   - thesis provides overview of design choices in MPC frameworks that impact memory consumption
//   - design and implementation of SEEC (SEEC Executes Enormous Circuits)
//     - including support for Sub-Circuits and SIMD Sub-Circuits
//     - abstractions for function-independent and depedent preprocessing
//     - impl of (A/B) GMW and B ABY2.0 (partial)
//     - designed with extensibility in mind, new protocols can be implemented *without forking* SEEC, but use it as a library
//     - in the future: simply `cargo add seec`
//   - extensive benchmarks of ABY, MP-SPDZ, MOTION and SEEC
// ]


#slide(alignment: center + horizon)[Questions?][
  
  #image(width: 25%, "logos/qr-code.png")
  
  Made with
  #set image(height: 1.3cm)
  #stack(dir: ltr, spacing: 2cm,
    image("logos/typst.svg"),
    image("logos/draw-io.svg"),
    image("logos/svg-repo.svg")
  )
]

#slide[References][
  #set text(size: 14pt)
  #grid(columns: (auto, 1fr),row-gutter: 0.5em, ..{
    refs.pairs().map(p => {
      let (k, v) = p
      let key = [[#v.display]#h(1em)] 
      let title = [
        #v.title #label(k)\
      ]
      (key, title)
    }).flatten()
  })
]

#section-slide[Appendix]

#slide[Future Work][
  #let r(s, content) = rect(width: 100%, stroke: (paint: s, dash: "dashed"), radius: 20%, content, outset: 1.8mm)
  #set image(height: 2cm)
  #set stack(spacing: 1em)
  #show regex(`sub_circuit`.text): set text(fill: orange.darken(10%))
  #show: columns.with(2)
  #set stack(dir: ltr)
  #set align(horizon)
  #box(height: 100%, stack(dir: ttb)[
    #show: r.with(blue-st)
    #stack[
      #image("diagrams/code.svg")
    ][
      - Expanding `Secret` API
      - SIMD `#[sub_circuit]` macro
      - Usability improvements
    ]
  ][
    #show: r.with(green-st)
    #stack[
      #image("diagrams/graph.svg")
    ][
      - Protocol composability
      - Optional register storage
      - Sub-Circuit SIMD-vectorization
    ]
  ][
    #show: r.with(orange-st)
    #stack[
      #image("diagrams/memory.svg")
    ][
      - Sub-Circuit output deallocation
    ]
  ])
  
  #colbreak()
  
  #box(height: 100%, stack(dir: ttb)[
  #show: r.with(yellow-st)
  #stack(dir: ltr)[
    #image("diagrams/preprocessing.svg")
    ][
      - OT-based interleaved setup
      - Interleaved function dependent preprocessing
    ]
  ][
    #show: r.with(red-st)
    #stack[
      #image("diagrams/online.svg")
    ][
      - Asynchronous Evaluation
      - QUIC Channels
      - Multi-Party + Malicious \ Protocols
    ]
  ])
]


#slide[Benchmarking Tool][
#show: columns.with(2)
  #raw(read("code/bench-config.toml"), lang: "toml")
  #icon-text("github-mark.svg", folder: "logos")[#link("https://github.com/encryptogroup/mpc-bench")[encryptogroup/mpc-bench]]
]

#slide[SHA-256: Effect of Nagle's Algorithm][
  #image("plots/sha256-wan-runtime.svg")
]

#slide[AES-CBC: Async. Communication Overhead][
  #image("plots/aes-cbc-btyes-sent.svg")
]

#slide[SIMD AES: Peak Bits per Gate][
  #image("plots/aes-ctr-bits-per-op.svg")
]

#slide[SIMD AES: Impact of Setup][
  #image("plots/aes-ctr-setup-max-heap.svg")
]

#slide[SHA-256: Reduced SIMD Memory Usage][
  #image("plots/sha256-max-heap.svg")
]

#slide[SEEC: System Architecture][
  #image("diagrams/architecture.svg")
]