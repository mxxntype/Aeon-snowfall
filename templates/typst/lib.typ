#let FONT_SIZE = 14pt
#let FONT_SIZE_MONOSPACE = FONT_SIZE - 4pt
#let GOST_MARGIN = (left: 30mm, right: 15mm, y: 20mm)

#set document(
    title: "{{project-name}}",
    keywords: (),
    date: none,
)

#set page(margin: GOST_MARGIN, numbering: "1")
#set par(justify: true)
#set text(
    lang: "{{language}}",
    font: "Times New Roman",
    size: FONT_SIZE,
)

// INFO: Make level 1 headings slightly bigger.
#show heading.where(level: 1): heading => [
    #set text(size: FONT_SIZE + 2pt)
    #heading
]

// INFO: Code blocks' settings.
#set raw(theme: "assets/catppuccin-latte.tmTheme")
#show raw: code => [
    #set text(font: "IosevkaTerm NF", size: FONT_SIZE_MONOSPACE)
    #code
]
