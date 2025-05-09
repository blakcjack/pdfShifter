# About The Repository

This repository is for templating your report build on top of Quarto + Typst.

## How to Use

## Using the Template

In order to apply the template, you just simply need to copy the _extensions folder from this repository and paste it in the root directory of your project.

## Using Your Own Custom Logo

Place your logo.png file in the root directory of your project. And that's it. 

## Applying the Format

In order to apply the style, you just simply need to create a quarto document `.qmd`. And then put the mandatory settings in the yaml header. The mandatory setting is as follow:

```
format:
  pdfShifter-typst:      # indicates that you are using my pdfShifter template which is a 'typst'. You can change the 'typst' into pdf too
    fig-format: svg      # tell the renderers about how to serve the image
company_logo:
    path: logo.png       # the logo you used in your document
```

And that's it, you can use the template in minimal requirement.

## Others `yaml` Header

Basically, most of quarto yaml header for pdf is supported.

## Extra Supported Arguments

This template supports two extra arguments:

* `sidebar_color: "#8787dc"`. By changing `"#8787dc"` to your preferred color, you can change the color of the sidebar

* You can set the size of the report's title by changing this argument `title-size: 2.5em` to whatever value you desired.

## Authoring For Better Publications

```
author:
  - name: Suberlin Sinaga
    orcid: 0009-0004-6330-0032
    url: suberlin-sinaga-07
    email: suberlinsinaga@gmail.com
    affiliations:
      - name: Data Analyst
```

You will have better author display on the sidebar by utilizing that parameters.

You can see the preview of the documents as follow: [Demo Template](https://github.com/blakcjack/pdfShifter/blob/main/template.pdf)
