#import "@preview/polylux:0.3.1": *

#let encrypto-title = state("encrypto-title", [])
#let encrypto-authors = state("encrypto-author", [])
#let encrypto-note-slides = state("encrypto-note-slides", true)

#let encrypto-blue = rgb("#00679c")
#let encrypto-full-line = line.with(length: 100%)

#let encrypto-theme(
  aspect-ratio: "16-9",
  authors: [],
  title: [],
  seminar: none,
  footer-delim:"|",
  note-slides: true,
  body
) = {
  let slide-footer = {
    encrypto-full-line()
    show: pad.with(x: 1em, y: -8pt)
    set text(size: 11pt)
    if seminar != none {
      seminar + [ | ]
    }
    if type(authors) == "array" {
      authors.join(" and ")
    } else {
      authors
    }
    [ | ] + title + [ | ]
    "Slide " + logic.logical-slide.display()
    place(top + right, dy: -1em, image("logos/tud_logo.png", width: 9%))
  }

  
  set text(font: "Helvetica", size: 20pt)
  set page(
    paper: "presentation-" + aspect-ratio,
    footer: slide-footer,
    margin: (
      top: 0.5cm,
      x: 0.5cm
    )
  )
  
  encrypto-title.update(title)
  if type(authors) != "array" {
    encrypto-authors.update((authors,))
  } else {
    encrypto-authors.update(authors)
  }
  encrypto-note-slides.update(note-slides)
  
  body
}


#let title-slide(
  sub-title: none,
  body,
) = {
  let content = {
    
    encrypto-full-line(stroke: 10pt + encrypto-blue)
    v(-1em + 3pt)
    let blk-inset = 1.5em
    block(
      fill: encrypto-blue,
      width: 100%,height: 40%,
      inset: blk-inset,
      {
        place(
          top + right,
          dx: blk-inset + 1pt,
          dy: -blk-inset + 5pt,
          block(fill: white,width: 4cm,inset: 0.2em, {
            image("logos/encrypto-logo.svg")
          })
        )
        set text(fill: white)
        
        let rows = if sub-title == none { 2 } else { 3 }
        grid(rows: (auto,) * rows, row-gutter: 0.5em, {
          grid(columns: (1fr, 20%), {
            heading(encrypto-title.display())
          },{})
        },
        sub-title, {
          locate(loc => {
            let authors = encrypto-authors.at(loc)
            grid(columns: (auto,) * authors.len(),column-gutter: 1em, ..authors)
          })
        })
      })
    body
  }
  polylux-slide(content)
}

#let encrypto-header(title) = {
  encrypto-full-line(stroke: 10pt + encrypto-blue)
  v(-1em + 3pt)
  block(width: 100%, height: 100%, stroke: (top: black, bottom: black), { 
    place(
      top + right,dx: 1pt, dy: 5pt,
      block(width: 4cm,inset: 0.2em, image("logos/encrypto-logo.svg"))
    )
    if title != none {
      set align(bottom)
      show: pad.with(left:1em, bottom: 1em)
      heading(title) 
    }
  })
}

#let slide(
  title,
  alignment: none,
  notes: none,
  body
) = {
  let content = {
    box(height: 15%, encrypto-header(title))
    
    let alignment = if alignment != none {
      alignment
    } else {
      start + top
    }
    set align(alignment)
    show: pad.with(x: 1em)
    show: box.with(height: 77%)
    body
  }
  polylux-slide({
    content
    if notes != none {
      pdfpc.speaker-note(notes)
    }
  })
  locate(loc => {
    if notes != none and encrypto-note-slides.at(loc) {
      slide([Notes: #title], notes)
    }
  })
}

#let section-slide(title, sub-title: none) = {
  let content = {
    box(height: 15%, encrypto-header([]))
    set align(horizon)
    show: pad.with(left:3em)
    box(height: 30%, {
      heading(level: 1, title)
      if sub-title != none {
        set align(bottom)
        text(fill: black.lighten(30%), heading(level: 2, sub-title))
      }
    })
  }

  polylux-slide(content)
}