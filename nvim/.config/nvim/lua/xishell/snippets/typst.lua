local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

-- Helper: visual selection or placeholder
local get_visual = function(args, parent)
  if #parent.snippet.env.LS_SELECT_RAW > 0 then
    return sn(nil, t(parent.snippet.env.LS_SELECT_RAW))
  else
    return sn(nil, i(1))
  end
end

return {

  -- =====================
  -- Document templates
  -- =====================

  s({ trig = "report", desc = "Report template" }, fmt([[
#set document(title: "{}", author: "{}")
#set page(paper: "us-letter", margin: 1in, numbering: "1")
#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.1")
#set par(justify: true, leading: 0.65em)
#set math.equation(numbering: "(1)")

// Useful packages:
// #import "@preview/ctheorems:1.1.3": *
// #show: thmrules.with(qed-symbol: $square$)

#align(center)[
  #text(size: 18pt, weight: "bold")[{}]
  #v(0.5em)
  #text(size: 12pt)[{}]
  #v(0.3em)
  #text(size: 10pt)[#datetime.today().display()]
]

{}
]], {
    i(1, "Title"),
    i(2, "Author"),
    rep(1),
    rep(2),
    i(0),
  })),

  s({ trig = "notes", desc = "Course notes template" }, fmt([[
#set document(title: "{}: {}", author: "{}")
#set page(paper: "us-letter", margin: 1in, numbering: "1", header: [
  #set text(size: 9pt)
  {} --- {} #h(1fr) #counter(page).display()
])
#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.1")
#set par(justify: true, leading: 0.65em)
#set math.equation(numbering: "(1)")

#import "@preview/ctheorems:1.1.3": *
#show: thmrules.with(qed-symbol: $square$)

#let theorem = thmbox("theorem", "Theorem", fill: rgb("#e8f0fe"))
#let lemma = thmbox("lemma", "Lemma", fill: rgb("#e8f0fe"))
#let corollary = thmbox("corollary", "Corollary", fill: rgb("#e8f0fe"))
#let definition = thmbox("definition", "Definition", fill: rgb("#f0fae8"))
#let example = thmbox("example", "Example", fill: rgb("#fef7e0")).with(numbering: none)
#let remark = thmbox("remark", "Remark", fill: rgb("#f5f5f5")).with(numbering: none)
#let proof = thmproof("proof", "Proof")

#align(center)[
  #text(size: 18pt, weight: "bold")[{}: {}]
  #v(0.3em)
  #text(size: 12pt)[{}]
  #v(0.3em)
  #text(size: 10pt)[#datetime.today().display()]
]

= {}

{}
]], {
    i(1, "COURSE 101"),
    i(2, "Lecture Title"),
    i(3, "Author"),
    rep(1),
    rep(2),
    rep(1),
    rep(2),
    rep(3),
    i(4, "Introduction"),
    i(0),
  })),

  s({ trig = "hw", desc = "Homework/assignment template" }, fmt([[
#set document(title: "{} - {}", author: "{}")
#set page(paper: "us-letter", margin: 1in, numbering: "1")
#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.")
#set par(justify: true, leading: 0.65em)
#set math.equation(numbering: "(1)")
#set enum(numbering: "(a)")

#align(center)[
  #text(size: 16pt, weight: "bold")[{} - {}]
  #v(0.3em)
  #text(size: 12pt)[{}]
  #v(0.2em)
  #text(size: 10pt)[#datetime.today().display()]
]

= Problem 1

{}
]], {
    i(1, "COURSE 101"),
    i(2, "Homework 1"),
    i(3, "Author"),
    rep(1),
    rep(2),
    rep(3),
    i(0),
  })),

  -- =====================
  -- Headings
  -- =====================

  s({ trig = "h1", desc = "Heading 1" }, fmt("= {}\n{}", { i(1), i(0) })),
  s({ trig = "h2", desc = "Heading 2" }, fmt("== {}\n{}", { i(1), i(0) })),
  s({ trig = "h3", desc = "Heading 3" }, fmt("=== {}\n{}", { i(1), i(0) })),

  -- =====================
  -- Math
  -- =====================

  s({ trig = "mk", desc = "Inline math" }, fmt("${}<>", { i(1), i(0) }, { delimiters = "<>" })),
  s({ trig = "dm", desc = "Display math" }, fmt("$ {} $\n<>", { i(1), i(0) }, { delimiters = "<>" })),

  -- Fractions
  s({ trig = "//", desc = "Fraction", wordTrig = false }, fmt("frac({}, {})<>", { i(1), i(2), i(0) }, { delimiters = "<>" })),

  -- Sub/superscript
  s({ trig = "td", desc = "Superscript", wordTrig = false }, fmt("^({})<>", { i(1), i(0) }, { delimiters = "<>" })),
  s({ trig = "__", desc = "Subscript", wordTrig = false }, fmt("_({})<>", { i(1), i(0) }, { delimiters = "<>" })),

  -- Common math constructs
  s({ trig = "sq", desc = "Square root" }, fmt("sqrt({})<>", { i(1), i(0) }, { delimiters = "<>" })),
  s({ trig = "nrt", desc = "Nth root" }, fmt("root({}, {})<>", { i(1, "n"), i(2), i(0) }, { delimiters = "<>" })),
  s({ trig = "sum", desc = "Summation" }, fmt("sum_({})^({}) {}<>", { i(1, "i=0"), i(2, "n"), i(3), i(0) }, { delimiters = "<>" })),
  s({ trig = "prod", desc = "Product" }, fmt("product_({})^({}) {}<>", { i(1, "i=0"), i(2, "n"), i(3), i(0) }, { delimiters = "<>" })),
  s({ trig = "lim", desc = "Limit" }, fmt("lim_({}) {}<>", { i(1, "n -> oo"), i(2), i(0) }, { delimiters = "<>" })),
  s({ trig = "int", desc = "Integral" }, fmt("integral_({})^({}) {} dif {}<>", { i(1), i(2), i(3), i(4, "x"), i(0) }, { delimiters = "<>" })),
  s({ trig = "dint", desc = "Definite integral" }, fmt("integral_({})^({}) {} dif {}<>", { i(1, "a"), i(2, "b"), i(3), i(4, "x"), i(0) }, { delimiters = "<>" })),

  -- Delimiters
  s({ trig = "lr(", desc = "Auto-sized parens" }, fmt("lr(({}))<>", { i(1), i(0) }, { delimiters = "<>" })),
  s({ trig = "lr[", desc = "Auto-sized brackets" }, fmt("lr([{}])<>", { i(1), i(0) }, { delimiters = "<>" })),
  s({ trig = "lr|", desc = "Auto-sized abs value" }, fmt("lr(|{}|)<>", { i(1), i(0) }, { delimiters = "<>" })),
  s({ trig = "norm", desc = "Norm" }, fmt("norm({})<>", { i(1), i(0) }, { delimiters = "<>" })),

  -- Matrices and vectors
  s({ trig = "mat2", desc = "2x2 matrix" }, fmt("mat(\n  {}, {};\n  {}, {};\n)<>", { i(1), i(2), i(3), i(4), i(0) }, { delimiters = "<>" })),
  s({ trig = "mat3", desc = "3x3 matrix" }, fmt("mat(\n  {}, {}, {};\n  {}, {}, {};\n  {}, {}, {};\n)<>", {
    i(1), i(2), i(3), i(4), i(5), i(6), i(7), i(8), i(9), i(0),
  }, { delimiters = "<>" })),
  s({ trig = "vec2", desc = "2D column vector" }, fmt("vec({}, {})<>", { i(1), i(2), i(0) }, { delimiters = "<>" })),
  s({ trig = "vec3", desc = "3D column vector" }, fmt("vec({}, {}, {})<>", { i(1), i(2), i(3), i(0) }, { delimiters = "<>" })),
  s({ trig = "cvec", desc = "Column vector" }, fmt("vec({})<>", { i(1, "delim: \"[\", ..."), i(0) }, { delimiters = "<>" })),

  -- Common symbols/shortcuts
  s({ trig = "ooo", desc = "Infinity" }, t("oo")),
  s({ trig = "...", desc = "Dots" }, t("dots.c")),
  s({ trig = "!>", desc = "Maps to" }, t("arrow.r.long.bar")),
  s({ trig = "=>", desc = "Implies", wordTrig = false }, t("==> ")),
  s({ trig = "=<", desc = "Implied by", wordTrig = false }, t("<== ")),
  s({ trig = "<>", desc = "Iff", wordTrig = false }, t("<==> ")),
  s({ trig = "!=", desc = "Not equal", wordTrig = false }, t("eq.not ")),
  s({ trig = "<=", desc = "Leq", wordTrig = false }, t("lt.eq ")),
  s({ trig = ">=", desc = "Geq", wordTrig = false }, t("gt.eq ")),
  s({ trig = ">>", desc = "Much greater", wordTrig = false }, t("gt.gt ")),
  s({ trig = "<<", desc = "Much less", wordTrig = false }, t("lt.lt ")),
  s({ trig = "inn", desc = "Element of" }, t("in ")),
  s({ trig = "notin", desc = "Not element of" }, t("in.not ")),
  s({ trig = "sub", desc = "Subset" }, t("subset ")),
  s({ trig = "sube", desc = "Subset eq" }, t("subset.eq ")),
  s({ trig = "forall", desc = "For all" }, t("forall ")),
  s({ trig = "exists", desc = "Exists" }, t("exists ")),
  s({ trig = "aa", desc = "For all (short)" }, t("forall ")),
  s({ trig = "ee", desc = "Exists (short)" }, t("exists ")),
  s({ trig = "iff", desc = "If and only if" }, t("<==> ")),

  -- Greek letters (common ones not already easy in Typst)
  s({ trig = "eps", desc = "Epsilon" }, t("epsilon")),
  s({ trig = "lam", desc = "Lambda" }, t("lambda")),
  s({ trig = "alp", desc = "Alpha" }, t("alpha")),
  s({ trig = "sig", desc = "Sigma" }, t("sigma")),

  -- Accents and decorations
  s({ trig = "hat", desc = "Hat accent" }, fmt("hat({})<>", { i(1), i(0) }, { delimiters = "<>" })),
  s({ trig = "bar", desc = "Bar accent" }, fmt("overline({})<>", { i(1), i(0) }, { delimiters = "<>" })),
  s({ trig = "tld", desc = "Tilde accent" }, fmt("tilde({})<>", { i(1), i(0) }, { delimiters = "<>" })),
  s({ trig = "dot.", desc = "Dot accent" }, fmt("dot({})<>", { i(1), i(0) }, { delimiters = "<>" })),
  s({ trig = "ddot", desc = "Double dot" }, fmt("dot.double({})<>", { i(1), i(0) }, { delimiters = "<>" })),
  s({ trig = "vc", desc = "Bold vector" }, fmt("bold({})<>", { i(1), i(0) }, { delimiters = "<>" })),

  -- Calculus
  s({ trig = "pd", desc = "Partial derivative" }, fmt("frac(diff {}, diff {})<>", { i(1, "f"), i(2, "x"), i(0) }, { delimiters = "<>" })),
  s({ trig = "dd", desc = "Derivative" }, fmt("frac(dif {}, dif {})<>", { i(1, "f"), i(2, "x"), i(0) }, { delimiters = "<>" })),
  s({ trig = "grad", desc = "Gradient" }, t("nabla ")),

  -- Sets
  s({ trig = "NN", desc = "Naturals" }, t("NN")),
  s({ trig = "ZZ", desc = "Integers" }, t("ZZ")),
  s({ trig = "QQ", desc = "Rationals" }, t("QQ")),
  s({ trig = "RR", desc = "Reals" }, t("RR")),
  s({ trig = "CC", desc = "Complex" }, t("CC")),
  s({ trig = "set", desc = "Set notation" }, fmt("\\{{ {} | {} \\}}<>", { i(1, "x"), i(2, "x > 0"), i(0) }, { delimiters = "<>" })),

  -- =====================
  -- Environments (ctheorems)
  -- =====================

  s({ trig = "thm", desc = "Theorem" }, fmt("#theorem[{}][{}]\n<>", { i(1, "Title"), i(2), i(0) }, { delimiters = "<>" })),
  s({ trig = "lem", desc = "Lemma" }, fmt("#lemma[{}][{}]\n<>", { i(1, "Title"), i(2), i(0) }, { delimiters = "<>" })),
  s({ trig = "cor", desc = "Corollary" }, fmt("#corollary[{}][{}]\n<>", { i(1, "Title"), i(2), i(0) }, { delimiters = "<>" })),
  s({ trig = "def", desc = "Definition" }, fmt("#definition[{}][{}]\n<>", { i(1, "Title"), i(2), i(0) }, { delimiters = "<>" })),
  s({ trig = "exm", desc = "Example" }, fmt("#example[{}][{}]\n<>", { i(1, "Title"), i(2), i(0) }, { delimiters = "<>" })),
  s({ trig = "rmk", desc = "Remark" }, fmt("#remark[{}][{}]\n<>", { i(1, "Title"), i(2), i(0) }, { delimiters = "<>" })),
  s({ trig = "prf", desc = "Proof" }, fmt("#proof[{}]\n<>", { i(1), i(0) }, { delimiters = "<>" })),

  -- =====================
  -- Text formatting
  -- =====================

  s({ trig = "bf", desc = "Bold" }, fmt("*{}*<>", { d(1, get_visual), i(0) }, { delimiters = "<>" })),
  s({ trig = "it", desc = "Italic" }, fmt("_{}_<>", { d(1, get_visual), i(0) }, { delimiters = "<>" })),
  s({ trig = "sc", desc = "Smallcaps" }, fmt("#smallcaps[{}]<>", { i(1), i(0) }, { delimiters = "<>" })),
  s({ trig = "hl", desc = "Highlight" }, fmt("#highlight[{}]<>", { i(1), i(0) }, { delimiters = "<>" })),
  s({ trig = "ul", desc = "Underline" }, fmt("#underline[{}]<>", { i(1), i(0) }, { delimiters = "<>" })),

  -- =====================
  -- Blocks and structure
  -- =====================

  s({ trig = "fig", desc = "Figure" }, fmt([[
#figure(
  image("{}", width: {}%),
  caption: [{}],
) {}
{}]], { i(1, "path.png"), i(2, "80"), i(3, "Caption"), c(4, { fmt("<{}>", { i(1, "fig:label") }, { delimiters = "<>" }), t("") }), i(0) })),

  s({ trig = "tbl", desc = "Table" }, fmt([[
#figure(
  table(
    columns: {},
    align: {},
    table.header[*{}*][*{}*],
    [{}], [{}],
  ),
  caption: [{}],
) {}
{}]], {
    i(1, "2"),
    i(2, "center"),
    i(3, "Col 1"),
    i(4, "Col 2"),
    i(5),
    i(6),
    i(7, "Caption"),
    c(8, { fmt("<{}>", { i(1, "tbl:label") }, { delimiters = "<>" }), t("") }),
    i(0),
  })),

  s({ trig = "lst", desc = "Bullet list" }, fmt([[
- {}
- {}
{}]], { i(1), i(2), i(0) })),

  s({ trig = "enum", desc = "Numbered list" }, fmt([[
+ {}
+ {}
{}]], { i(1), i(2), i(0) })),

  s({ trig = "code", desc = "Code block" }, fmt([[
```{}
{}
```
{}]], { i(1, "lang"), i(2), i(0) })),

  s({ trig = "quote", desc = "Block quote" }, fmt("#quote(block: true, attribution: [{}])[{}]\n<>", { i(1), i(2), i(0) }, { delimiters = "<>" })),

  s({ trig = "box", desc = "Colored box" }, fmt([[
#block(
  fill: rgb("{}"),
  inset: 1em,
  radius: 4pt,
  width: 100%,
)[{}]
{}]], { i(1, "#e8f0fe"), i(2), i(0) })),

  s({ trig = "alert", desc = "Alert/callout box" }, fmt([[
#block(
  fill: rgb("{}").lighten(80%),
  stroke: rgb("{}"),
  inset: 1em,
  radius: 4pt,
  width: 100%,
)[
  *{}:* {}
]
{}]], { i(1, "red"), rep(1), i(2, "Note"), i(3), i(0) })),

  -- =====================
  -- References and labels
  -- =====================

  s({ trig = "ref", desc = "Reference" }, fmt("@{}<>", { i(1, "label"), i(0) }, { delimiters = "<>" })),
  s({ trig = "lab", desc = "Label" }, fmt("<{}>", { i(1, "label") }, { delimiters = "<>" })),
  s({ trig = "cite", desc = "Citation" }, fmt("@{}<>", { i(1, "citation-key"), i(0) }, { delimiters = "<>" })),

  -- =====================
  -- Page layout
  -- =====================

  s({ trig = "pb", desc = "Page break" }, t("#pagebreak()")),
  s({ trig = "cols", desc = "Two columns" }, fmt([[
#columns({})[
  {}
]
{}]], { i(1, "2"), i(2), i(0) })),

  -- =====================
  -- Imports
  -- =====================

  s({ trig = "imp", desc = "Import package" }, fmt('#import "@preview/{}": *\n<>', { i(1, "package:version"), i(0) }, { delimiters = "<>" })),
  s({ trig = "cthm", desc = "Import ctheorems" }, t({
    '#import "@preview/ctheorems:1.1.3": *',
    '#show: thmrules.with(qed-symbol: $square$)',
    '',
    '#let theorem = thmbox("theorem", "Theorem", fill: rgb("#e8f0fe"))',
    '#let lemma = thmbox("lemma", "Lemma", fill: rgb("#e8f0fe"))',
    '#let corollary = thmbox("corollary", "Corollary", fill: rgb("#e8f0fe"))',
    '#let definition = thmbox("definition", "Definition", fill: rgb("#f0fae8"))',
    '#let example = thmbox("example", "Example", fill: rgb("#fef7e0")).with(numbering: none)',
    '#let remark = thmbox("remark", "Remark", fill: rgb("#f5f5f5")).with(numbering: none)',
    '#let proof = thmproof("proof", "Proof")',
    '',
  })),
}
