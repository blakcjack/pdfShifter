// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: white, width: 100%, inset: 8pt, body))
      }
    )
}
#let to-string(content) = {
  if content.has("text") {
    if type(content.text) == "string" {
      content.text
    } else {
      to-string(content.text)
    }
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let pdfShifter(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "ID",
  font: "linux libertine",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "linux libertine",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 2.5em,
  doc,
  company_logo: "logo.png",
  sidebar_color: none
) = {
  let sidebar_color = if sidebar_color != none {sidebar_color.replace("\#", "")} else {"14142a"}
  set page(
    paper: paper,
    margin: (left: 2.4cm, right: 0.1cm, top: 2cm, bottom: 2cm),
    numbering: "1",
    number-align: right,
    background: place(left + top, rect(
      fill: rgb(sidebar_color),
      height: 100%,
      width: 2.2cm,
      block(
        spacing: 20pt,
        place(
          left + top,
          dy: 480pt,
          dx: -0.08cm,
          stack(
            // spacing: 1em,  // Adds space between image and text
            block(width: 2cm, spacing: 0.1em)[
              #image(company_logo.path)
              #if authors != none {
                  align(center)[
                    #text(fill: white)[
                      #authors.map(
                        author => [
<<<<<<< HEAD
                          #author.name\
                          #text(size: 0.75em, weight: "bold")[
=======
                          #text(size: 0.45em, weight: "bold")[
                            #author.name\
>>>>>>> f4ebf3d (Improve logo position and font size)
                            #author.affiliation\
                            #link("mailto:" + to-string(author.email), author.email)\
                            #link("https://orcid.org/" + to-string(author.orcid), author.orcid)\
                            #link("https://www.linkedin.com/in/" + to-string(author.linkedin), author.linkedin)
                          ]
                        ]
                      ).join("")
                      // Suberlin Sinaga\
                      // #text(size: 0.65em)[email: suberlinsinaga\@gmail.com]
                    ]
                  ]
              }
            ]
          )
        )
      )
    ))
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  if title != none {
    align(center)[#block(inset: 2em)[
      #set par(leading: heading-line-height)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black or heading-decoration == "underline"
           or heading-background-color != none) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
        text(size: title-size)[#upper(title)]
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#upper(title)]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    pagebreak(weak: true)
    block(inset: 2em)[
    #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    pagebreak(weak: true)
    block(above: 3em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  
    if cols == 1 {
      doc
    } else {
      columns(cols, doc)
    }
}

#set table(
  inset: 6pt,
  stroke: none
)

#show: pdfShifter.with(
      title: [Lorem #text(fill: rgb("#8d5524"))[Ipsum] Dolor #text(fill: rgb("#ffbf00"))[Sit Amet]],
        title-size: 2.5em,
        subtitle: [Consectetur Adipiscing #text(fill: red)[Elit]],
        authors: (
          ( name: [Suberlin Sinaga],
        affiliation: [Data Analyst],
        email: [suberlinsinaga\@gmail.com],
        orcid: [0009-0004-6330-0032],
        linkedin: [suberlin-sinaga-07] ),
          ),
                margin: (x: 2cm,y: 2cm,),
        paper: "a5",
        font: ("Times New Roman",),
                            toc: true,
        toc_title: [Table of contents],
        toc_depth: 3,
    cols: 1,
      company_logo: (
      path: "logo.png",
      caption: []
    ), 
        sidebar_color: "\#8787dc",
  )

#colbreak()

= Quarto
<quarto>
Quarto enables you to weave together content and executable code into a finished document. To learn more about Quarto see #link("https://quarto.org");.

= Quarto + Typst
<quarto-typst>
Even further, quarto now supports a brand new, popular and yet powerful typing framework, #strong[typst];. Make it even more powerful.

$ y = x beta + epsilon.alt $
