# Overview



## XTrees

At the core of Pollen.jl is a tree-like document format with attribute support, similar to XML.

- Types and data: `XTree`, `XNode`, `XLeaf`
- getters/setters: `tag`, `attributes`, `children`, `withtag`, `withattributes`, `withchildren`
- transformations: `catafold`, `cata`, `fold`, `foldleaves`
- selectors: `Selector`, `matches`, `SelectCond`, `SelectAll`, `SelectNode`, `SelectLeaf`, `SelectTag`, `SelectOr`, `SelectAnd`, `SelectNot`, `SelectAttrEq`, `SelectHasAttr`, `select`, `selectfirst`
- catamorphisms: `catafirst`, `replace`, `replacefirst`, `replacemany`, `filter`, `insert`, `insertfirst`

## Formats

`XTree`s can be parsed from and serialized to different formats:

- `Markdown`, `HTML`, `Jupyter`, `JSON`

## Rewriters

Rewriters transform `XTree`s.

## Projects

A `Project` combines source documents, rewriters and a builder to produce a buildable collection of output documents.