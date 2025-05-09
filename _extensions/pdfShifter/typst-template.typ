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
  companies: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "a5",
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
  toc_color: none,
  doc,
  company_logo: "logo.png",
  sidebar_color: none,
  sidebar_position: "bottom",
  enable-back-page: true,
  enable-front-cover: true
) = {
  let sidebar_color = if sidebar_color != none {sidebar_color.replace("\#", "")} else {"14142a"}
  let toc_color = if sidebar_color != none {toc_color.replace("\#", "")} else {"black"}
  set page(
    paper: paper,
    margin: (left: if sidebar_position=="bottom" {1cm}else{2.4cm}, right: 1cm, top: 2cm, bottom: 1.1cm),
    // numbering: "1",
    // number-align: right,
    footer: context {
      if counter(page).get().at(0) > 0 {
        place(
          right + bottom,
          dx: page.margin.at("right") - 0.6cm,
          dy: -0.6cm,
          box(width: 1.15cm, height: 0.15cm, align(center + horizon, text(fill: white, size: 14pt, weight: "bold", counter(page).display())))
        )
      }
    },
    background: place(if sidebar_position == "bottom" {bottom} else {left + top}, rect(
      fill: rgb(sidebar_color),
      height: if sidebar_position == "bottom" {1.3cm} else {100%},
      width: if sidebar_position == "bottom" {100%} else {2.2cm},
      block(
        spacing: 20pt,
        place(
          if sidebar_position == "bottom" {bottom} else {left + top},
          dy: if sidebar_position == "bottom" {25pt} else {440pt},
          dx: if sidebar_position == "bottom" {2cm} else {-0.08cm},
          if sidebar_position == "bottom" {
            grid(
              columns: (auto, auto),  // Two columns: one for image, one for company info
              gutter: 2em,            // Space between columns
              // First column: image
              align(center + horizon)[
                #image(company_logo.path, width: 1cm)
              ],
              // Second column: company name
              align(left + horizon)[  // Align text vertically centered with image
                #if companies != none {
                  block(width: 3.2cm, spacing: 0.1em)[
                    #text(fill: black, size: 0.8em, weight: "bold")[
                      // #link(companies.url, companies.name)\
                      #text(size: 0.9em)[#link("mailto:" + to-string(companies.email), "email: " + companies.email)]\
                      #text(size: 1em)[mobile: #companies.mobile]
                    ]
                  ]
                }
              ]
            )
          } else {
            stack(
              block(width: 2cm, spacing: 0.1em)[
                #image(company_logo.path)
                #if companies != none {
                    align(center)[
                      #text(fill: black, size: 0.5em, weight: "bold")[
                        #link(companies.url, companies.name)\
                        #v(1.5pt)
                        #text(size: 0.9em)[email: #link("mailto:" + to-string(companies.email), companies.email)]\
                        #v(1.5pt)
                        #text(size: 1em)[mobile: #companies.mobile]\
                        #v(1.5pt)
                        phone: #companies.phone\
                        #v(1.5pt)
                        insta: #link("https://www.instagram.com/" + to-string(companies.instagram), companies.instagram)\
                        #v(1.5pt)
                        linkedin: #link("https://www.linkedin.com/in/" + to-string(companies.linkedin), companies.linkedin)\
                      ]
                    ]
                }
              ]
            )
          }
        )
      )
    ))
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  let back-page
  back-page = page(footer: none, header: none, margin: 0cm, image("_extensions/pdfShifter/cover/"+"/back_cover.png", width: 101%))
  show heading: set text(fill: rgb(toc_color))
  set heading(numbering: sectionnumbering)
  show outline.entry: it => {
    link(
      it.element.location(),
      [
        #text(fill: rgb(toc_color))[#it.body]
        #box(width: 1fr, text(fill: rgb(toc_color))[#it.fill])
        #text(fill: rgb(toc_color))[#it.page]
      ]
    )
  }
  if enable-front-cover {
    page(footer: none, header: none, margin: 0cm, image("_extensions/pdfShifter/cover/"+"/front_cover.png", width: 101%))
  }
  if title != none and not enable-front-cover {
    counter(page).update(0)
    place(
      left + bottom,
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
          if authors != none {
            pad(
              top: 2em,
              for i in range(calc.ceil(authors.len() / 2)) {
                let end = calc.min((i + 1) * 2, authors.len())
                let is-last = authors.len() == end
                let slice = authors.slice(i * 2, end)
                grid(
                  columns: slice.len() * (1fr,),
                  gutter: 12pt,
                  ..slice.map(author => align(center, {
                    text(12pt, strong(author.name))
                    if "orcid" in author [
                      \ #author.orcid
                    ]
                    if "affiliation" in author [
                      \ #author.affiliation
                    ]
                    // if "department" in author [
                    //   \ #author.department
                    // ]
                    if "email" in author [
                      \ #link("mailto:" + to-string(author.email))
                    ]
                  }))
                )
            
                if not is-last {
                  v(16pt, weak: true)
                }
              }
            )
          }
        } else {
          text(weight: "bold", size: title-size)[#upper(title)]
          if subtitle != none {
            parbreak()
            text(weight: "bold", size: subtitle-size)[#subtitle]

          }
        }
      ]]
    )
  } else {
    counter(page).update(0)
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

    if enable-back-page {
      back-page
    }
}

#set table(
  inset: 6pt,
  stroke: none
)