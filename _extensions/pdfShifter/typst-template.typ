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
    margin: (left: 4cm, right: 1cm, top: 2cm, bottom: 2cm),
    numbering: "1",
    number-align: right,
    background: place(left + top, rect(
      fill: rgb(sidebar_color),
      height: 100%,
      width: 3.8cm,
      block(
        spacing: 200pt,
        place(
          top,
          dy: 300pt,
          // dx: 0.1pt,
          stack(
            spacing: 1em,  // Adds space between image and text
            block(width: 3.4cm)[
              #image(company_logo.path)
              #if authors != none {
                  align(center)[
                    #text(fill: white)[
                      #authors.map(
                        author => [
                          #author.name\
                          #text(size: 0.75em, weight: "bold")[
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
    pagebreak()
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
    pagebreak()
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