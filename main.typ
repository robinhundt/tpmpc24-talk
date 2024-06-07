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

#let split-code(file, lines, lang: "rust") = {
  let text = read("code/"+file).split("\n").slice(..lines).join("\n")
  raw(text, lang: lang, block: true)
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
- The currently implemented protocols are GMW with multiplication triples in the boolean and arithmetic domain, and also a mixed domain implementation
- We also provide a partial implementation of the ASTRA and ABY2.0 protocols for the Boolean domain.
- Notably, we have also implemented an OT library which uses Chou Orlandis Simples OT, and the ALSZ13 and  Silent OT extension protocols
- As part of this work, we also developed a benchmarking tool which supports ABY, MOTION, MP-SPDZ, and SEEC.
- You can use it to declaratively specify benchmarks with varying input sizes
- And then it handles the compilation, local or remote execution of parties, and parsing of the results into a common format.
```)[[#underline[S]EEC #underline[E]xecutes #underline[E]normous #underline[C]ircuits (SEEC)]][
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
      #link("https://github.com/encryptogroup/mpc-bench")[encryptogroup/mpc-bench]
    ]
  ]
  #place(left + bottom, text(size: 0.5em)[#sym.ast.basic Partial Implementation])
]

#slide(alignment: horizon, notes:```md
- Okay now on to some of the implementation details of SEEC, specifically those related to memory efficiency.
- Here, on the left side we have some simple Rust code with a function that takes two Booleans and returns a Boolean, which is called twice where the result of the first call is one input for the second call.
- In traditional programs, we use functions as an important tool for building abstractions and organizing code
- they also reduce the size of the binary, 
- Imagine if we would inline every function of a large program. The result would be an enormous binary.
  - and yet, this is exactly what we often do in secret-sharing based MPC, resulting in huge circuits
```)[Functions in Traditional Programs][
  #code("normal-code.txt")
]

#slide(alignment: horizon, notes: ```md
- Okay, so now on the right side we see what we want secure programs to roughly look like
- Crucially, we want to have a high-level way of specifying a functionality to evaluate securely
- With our framework SEEC, we've tried to tackle the problem of memory and communication round efficient functions or in our case sub-circuits.
- Ideally, we can declare functions in our high-level functionality and use them as normal functions within our secure functionality to ease the development of MPC applications.
- some slight differences such as the changed types here, are okay; and likely necessary
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

#slide(notes: ```md
- Okay, so what is the challenge for functions in MPC, specifically for linear secret-sharing based protocols which execute in multiple rounds?
- Let's say we have our high-level functionality with two function calls.
- In this case, these two function calls are independent of each other
[NEXT SLIDE]
- If we go a level lower and look at intermediate or in-memory representation which the source code of our secure functionality is compiled to, we have two options:
- We can represent the functionality as Bytecode for an MPC-specific virtual machine, for example this is how MP-SPDZ does it.
- Or, we can represent the functionality as a circuit or directed acyclic graph, which more closely resembles descriptions of protocols in the literature and is the approach taken by ABY, MOTION and others.
- In the bytecode representation, we have the bytecode for the function once in memory and then two sequential call instructions to this function.
- Whereas in the graph based approach, we repeat the sub-graph corresponding to the function within the larger circuit for our two calls.
[NEXT SLIDE]
- Both approaches have some advantages and disadvantages.
- With the bytecode executed by VM, the sequential function calls result in an increased number of communication rounds.
- However, the definition of the function itself is only stored once in memory and we can more easily reuse memory for the output of gates or instructions in this case.
- If we choose a graph approach, we naturally get concurrent evaluation of these two functions when we iterate over the layers of the circuit.
- However, this comes at the cost of increased memory, as the sub-circuit for the function is repeated in memory.

- What we've looked at is: Can we have memory efficient functions or sub-circuits which do not increase the number of rounds?
- As a side note: With garbled circuits, functions are much easier to support, as there, the sequential evaluation does not matter, because of the constant round evaluation.
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
      `a` and `b` are independent
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


#slide(notes:```md
- With SEEC, we provide a memory and round-efficient way of using sub-circuits in secret-sharing based protocols.
- With our high-level API, you can annotate a normal Rust function, which operates on data of type Secret, with our sub_circuit macro
- In this case, the function simply computes the pairwise AND of two vectors
[NEXT SLIDE]
- Then we can use this function as a normal function in the rest of our code.
- Okay, so for an MPC application developer this is a nice experience, but how does it work?
```, [SEEC: eDSL Enables Efficient Circuit Reuse])[
  #set align(center)

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
]

#slide(notes: ```md
- In SEEC, we also use a graph based representation of the functionality to execute.
- However, in contrast to previous works, repeated calls to a functionality will not inline them for each call.
- Instead, for the first call to a sub-circuit, we build the sub-graph corresponding to this function and cache it.
- Subsequent calls to the function will not recompute the sub-circuit, but instead connect the argument gates of the calling circuit to the input gates of the called sub-circuit.
- For these connections between called circuits, we optimized the memory required to store them, specifically we compress gates with consecutive Ids into ranges of gates.
- Okay, so the first part is done, we have a memory efficient way of declaring sub-circuits, but what about the round complexity?
[NEXT SLIDE]
- For an efficient online phase, it is important that using sub-circuits does not increase the number of communication rounds.
- In our framework, we achieve this via lazy iteration over the topologically sorted layers for each **use** of a subcircuit.
- We refer to this lazy iteration of sub-circuit layers as dynamic layers or DL for short.
- The crucial property of this approach, is that the execution of each sub-circuit is **as if it was inlined**, meaning we have no increase in the depth or round complexity of the overall circuit.
- Also, this graph-based lazy iteration approach enables us to have partial and concurrent evaluation of multiple uses of the same sub-circuit or different sub-circuits.
- This notion and our implementation of sub-circuits enables us to have memory- and round-efficient functions for secret-sharing based MPC protocols.
```)[SEEC: Sub-Circuits Are Not Inlined][
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
  ]
]


#slide(notes: ```md
- Okay, so we just saw that with SEEC we can have efficient sub-circuits.
- But there also a different technique, namely SIMD, which stands for single instruction, multiple data, and has been used to reduce memory consumption and increase efficiency of MPC implementations.
- For example in the MOTION framework, we can have SIMD gates, which perform the same operation on vectors of data instead of individual values.
  - A nice benefit of these MPC SIMD gates, is that these gates internally can use hardware SIMD instructions to speed up the computation
[NEXT SLIDE]
- In SEEC, we also support SIMD, but instead of at the gate level, we support SIMD sub-circuits.
- So instead of an individual gate that operates on vectors, we have sub-circuits that operate on vectors of data.
- We do this because supporting SIMD at the gate level can very easily increase the memory consumption of circuits which **don't use SIMD**.
```)[Single Instruction, Multiple Data (SIMD)][
  #set align(bottom + center)
  #grid(columns: (1fr, 1fr))[
    #box({
      image("diagrams/seec-simd-Page-1.svg")
      [Traditional SIMD, e.g., in\ MOTION #cite("motion22").]
    })
  ][
    #pause
    #box({
      image("diagrams/seec-simd-Page-2.svg")
      [SIMD Sub-Circuits in SEEC.\ #hide("a")]
    })
  ]
  #v(1.5cm)
]

#slide(notes: ```md
- Alongside sub-circuits and SIMD, we also implement several optimizations to increase performance and memory efficiency
- The first one of those, we call static layers
- Layers here refers to the layers of **uses of a sub-circuit** which are dynamically computed in the dynamic layer representation
- With the static layer representation, we precompute those layers of each use of a sub-circuit
- To not blow up the required memory, we however only store unique layer configurations of a sub-circuit.
- As a result, if two calls to sub-circuit result in the configuration of sub-circuit layers, we only store these once.
- The benefit of this optimization is twofold:
  - increased perfomance of the online phase, because we don't need to dynamically compute the layers on the fly
  - And, depending on the circuit topology, a reduced memory consumption because we don't need a general graph representation with forward and backward references between gates anymore.
[NEXT SLIDE]
- The next optimization is early deallocation of gate outputs in SIMD circuits
- Because in SIMD circuits, the outputs of gates are heap allocated vectors,
we can free them once they're not needed for further evaluation. 
[NEXT SLIDE]
- And lastly, with our generic APIs for preprocessing, we have the option to precompute multiplication triples and store them on the filesystem.
- In the online phase, we can read the triples on-demand in batches from a file.
- This reduces memory consumption, as we don't need hold all required triples in memory at once.
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
      - Multiplication Triples (MTs) are precomputed and stored in a file
      - Online: read on-demand in batches from the file
    ]
    #only((1,2), make-opaque)
  ]
]

#set footnote.entry(clearance: 0em, gap: 0em)

#slide(notes: ```md
- Okay, so what impact do sub-circuits and our optimizations have on the memory efficiency?
- To evaluate this, we have run extensive benchmarks with our dedicated benchmarking tool which I mentioned in the beginning.
- We compare with the ABY, MP-SPDZ, and MOTION frameworks
- In all frameworks, we use the semi-honest two-party Boolean GMW protocol with multiplication triples and only benchmark the online phase and not the setup.
- We perform the evaluation in different environments, with differing simluated network settings and a varying number of threads.
- To measure the maximum memory consumption, we use the heaptrack tool.
- We ran each party on one of our servers with 32 logical cores and 128 Gigs of RAM.
[NEXT SLIDE]
- We benchmark two kinds of functionalities.
- In the first one, we repeatedly execute AES-128 chained after one another.
  - So this is essentially AES in CBC mode in MPC.
  - We chose this functionality as it has this structure of a sub-functionality which is repeatedly used, it can not exploit SIMD, the size of the circuit can easily be scaled, and it was straightforward to implement in the different frameworks.
- And then also, we benchmark SIMD evaluations of AES and SHA-256 with different SIMD vector sizes to see the impact of our SIMD specific optimizations.
```)[Evaluation][
  #grid(columns: (40%, 1fr))[
    #grid(rows: (auto, auto), row-gutter: 1em)[
      === Frameworks

      - ABY #cite("aby")
      - MP-SPDZ #cite("kel20")
      - MOTION #cite("motion22")
      - SEEC
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
  set par(leading: 0.56em)
  set text(size: 0.66em, fill: black.lighten(20%), )
  place(top, dx: 22.7cm + dx, dy: +0.83cm + dy,
    box(fill: white, outset: (bottom: 3pt), align(start, content)))
}

#let bottom-legend(dx: 0%, dy: 0%, ..content) = {
  set text(size: 0.6em, fill: black.lighten(20%))
  place(top, dx: 22.5cm + dx, dy: 5cm + dy, grid(columns: 2, gutter: 0.5em, align: (start + horizon, end), ..content))
}

#let note(dx: 0%, dy: 0%, content) = {
  set text(size: 0.9em, fill: black.lighten(20%))
  place(top, dx: dx, dy: dy, box(fill: white, align(start, content)))
}

#slide(notes: ```md
- First, we examine the peak memory of SEEC on the AES-CBC circuit.
- Note that both the x and y axis are logarithmically scaled.
- SEEC with dynamic layers but without sub-circuits, so each AES circuit is inlined, has the highest peak memory consumption with 50 GB at the largest circuit size.
- If we then use the dynamic layer representation with sub-circuits, the memory consumption is reduced to 2.2 GB.
- And if we further use the static layer optimization, we can further reduce this to just 375 MB. So this is roughly a factor 135 improvement when comparing no sub-circuits to sub-circuits with static layers.
- But how does this stack up against the other frameworks?
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
    
    #note(dx: 70%, dy: 0%)[50 GB]
    #note(dx: 70%, dy: 20%)[2.2 GB]
    #note(dx: 70%, dy: 52%)[375 MB]
]

#slide(notes:```md
- When comparing with the other frameworks, we see that especially MOTION has tremendous memory overhead, especially for Boolean circuits not using SIMD.
- Only at 100 chained AES circuits, the peak memory consumption of the online phase is already 73 GB and we could not evaluate larger sizes as we rant out of RAM.
- ABY fares better with 74 GB at 10K chained circuits, but this is still more than the 50 GB of SEEC without sub-circuits.
- For MP-SPDZ and SEEC, the difference is quite small. While SEEC fares better for very small circuits, with increasing size the memory consumption of MP-SPDZ is better than SEEC.
- One reason for MP-SPDZ low memory consumption in this benchmark is its support of loops, which for this circuit don't increase the number of rounds, but significantly reduce the size of the bytecode.
- So we confirmed our earlier claims that the bytecode representation of MP-SPDZ results in low memory consumption for circuits such as the evaluated, whereas graph-based approaches tend to require several orders of magnitude more memory.
- We also see that, with our implementation of sub-circuits we achieve memory efficiency that is close to the bytecode approach.
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
- Alright, so now let us focus on SIMD circuitss, where we operate on vectors of values instead of individual ones.
- So here, we evaluate the AES-128 circuit with varying SIMD sizes in parallel and again look at the peak memory consumption.
- For SEEC, we have the highest peak memory consumption of 7.5 GB at 1 million parallel AES calls for the variant where we only use static layers but no early deallocation or triples streaming.
- This is already improved by using early deallocation of SIMD gate outputs and further improved by triples streaming to just 700 MB.
- However, if we look at left side of the graph, we see that the variant with streaming triples requires the most memory.
- The reason for this is, that we read the triples in a pre-defined batch size.
- This batch size was quite high for this benchmark, so the majority of the memory for small circuits is due to unneeded triples being loaded into memory.
- So we get more than a factor of 10 reduction in peak memory for this high SIMD use case when using our optimizations and SEEC.
- So now, lets again compare the most efficient variant with the other frameworks. 
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
- For ABY and MP-SPDZ, we were unable to go up to the largest SIMD size as these frameworks crashed for this size.
- MOTION managed to evaluate 1 million parallel calls, but required 10 GB of peak memory for this, compared to SEECs 700 MB we saw earlier.
- And again, on the left side of the graph, SEEC performs worse for smaller circuits due to the triple batch size.
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
- Now, on to the last benchmark, where we look at the runtime of the AES-CBC benchmark with 100 chained circuits in our three network settings.
- In general, ABY performs really well runtime wise for this circuit and tends to be a little bit faster than SEEC, except in the WAN setting.
- Interestingly, MP-SPDZ has a very good runtime in the lowest latency network setting
- But then, the runtime curiously increases over-proportional with the latency, with MP-SPDZ being the slowest in the WAN setting with 616 seconds, twice as much as SEEC.
- For MOTION, we see that it can't really make use of low-latency networks and has the highest runtime in the LAN settings.
- In general, SEEC has good online runtime performance in all network settings, with room for improvement in the low latency network.
- Most importantly, using sub-circuits does not increase the number of communication rounds!
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

   #bottom-legend(dx: 6%)[
      SL:
    ][Static Layers][
      SC:
    ][Sub-Circuits]

  #set text(size: 0.8em)
  #net-note(dx: 12%, dy: 90%)[ABY #cite("aby")]
  #net-note(dx: 29.2%, dy: 90%)[MOTION #cite("motion22")]
  #net-note(dx: 50.5%, dy: 90%)[MP-SPDZ #cite("kel20")]
  #net-note(dx: 72%, dy: 90%)[SEEC - SL/SC]
]

#slide(notes: ```
- With SEEC, we achieve a memory-safe and efficient two party secure computation framework
- We provide a memory and communication round efficient implementation of sub-circuits with enable the use of functions in the functionalities for secret-sharing bases MPC
- support for loops and register allocation of gate outputs can lead to better memory efficiency in some cases (MP-SPDZ)
- however sub-circuits are more versatile, as they can reduce memory consumption of sub-circuit calls at unrelated places of the main circuit
SIMD
- Significantly better SIMD memory consumption
  - largely due to FG and IS optimizations
- Predicatbility
- Realiability
```)[Summary][
  #show heading: set align(center)
  #show regex(`sub_circuit`.text): set text(fill: orange.darken(10%))
  #let check = align(center, scale(150%, image("logos/check.svg", height: 1em)))
  #let check-yellow = align(center, scale(150%, image("logos/check-yellow.svg", height: 1em)))
  #let cross = align(center, scale(150%, image("logos/cross.svg", height: 1em)))
  #let rarrow = sym.arrow.r

  #grid(columns: (1fr,) *2)[
    #grid(columns: (1fr,) * 2, rows: (40%, 1fr), row-gutter: 1em)[
        #set align(horizon + center)
        #stack(dir: ltr)[
          #image("logos/rust-logo.svg", height: 50%)
          #h(5cm)
        ][
          Memory-Safety\
          #text(size: 2em, "&")\
          Memory-Efficiency
        ]
      ][
      ][
        #stack(dir: ltr, spacing: 2em)[
        == Sub-Circuits
          #v(1cm)
          ```rust
          #[sub_circuit]
          fn process(...)
          ```
        ][
          == SIMD
          #set align(horizon)
          Up to 15× - 1,983× less memory than MOTION #cite("motion22").
        ]
      ]
  ][
    #set align(horizon)
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
    ][ #check-yellow ][ #check ]
  ]
]

#slide(alignment: center + horizon)[Questions?][
  
  #image(width: 25%, "logos/qr-code.png")
  #link("https://github.com/encryptogroup/SEEC")[github.com/encryptogroup/SEEC] \
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

#slide[Sub-Circuit Iteration][
  #set text(size: 13pt)
  #grid(columns: 2)[
    #split-code("sub-circ-iter.py", (0, 22), lang: "python")
  ]
]

#slide[Sub-Circuit Iteration][
  #set text(size: 13pt)
  #grid(columns: 2)[
    #split-code("sub-circ-iter.py", (22, 40), lang: "python")
  ][
    #split-code("sub-circ-iter.py", (40, 52), lang: "python")
  ]
]

#slide[SHA-256: Effect of Nagle's Algorithm][
  #image("plots/sha256-wan-runtime.svg")
   #overwrite-legend[
      ABY #cite("aby")\
      MOTION #cite("motion22")\
      SEEC, SL
  ]
]

#slide[AES-CBC: Async. Communication Overhead][
  #image("plots/aes-cbc-btyes-sent.svg")
   #overwrite-legend[
      ABY #cite("aby")\
      MOTION #cite("motion22")\
      MP-SPDZ #cite("kel20")\
      SEEC, SL/SC
  ]
]

#slide[SIMD AES: Peak Bits per Gate][
  #image("plots/aes-ctr-bits-per-op.svg")
   #overwrite-legend[
      ABY #cite("aby")\
      MOTION #cite("motion22")\
      MP-SPDZ #cite("kel20")\
      SEEC, DL/ED\
      SEEC, DL/SMT/ED\
      SEEC, SL
  ]
]

#slide[SIMD AES: Impact of Setup][
  #image("plots/aes-ctr-setup-max-heap.svg")
  #overwrite-legend[
      ABY #cite("aby")\
      MOTION #cite("motion22")\
      MOTION, IS #cite("motion22")\
      MP-SPDZ #cite("kel20")\
      SEEC, DL/SMT/ED\
      SEEC, SL
  ]
]

#slide[SHA-256: Reduced SIMD Memory Usage][
  #image("plots/sha256-max-heap.svg")
  #overwrite-legend[
      ABY #cite("aby")\
      MOTION #cite("motion22")\
      SEEC, DL/ED\
      SEEC, DL/SMT/ED\
      SEEC, SL
  ]
]

#slide[SEEC: System Architecture (slightly outdated)][
  #image("diagrams/architecture.svg")
]