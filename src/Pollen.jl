module Pollen

using ANSIColoredPrinters
using AbstractTrees
using Base.Docs
using CommonMark
using CommonMark: Document, Item, Text, Paragraph, List, Heading,
    Emph, SoftBreak, Link, Code, Node, AbstractContainer, CodeBlock, ThematicBreak,
    BlockQuote, Admonition, Attributes, Image, Citation
using FilePathsBase
using DataStructures: DefaultDict, OrderedDict
import Gumbo
using JuliaFormatter
using Mustache
using LiveServer
using IJulia
import LiveServer
using HTTP
using TOML
using IOCapture
using JSON3
using Revise


# XTree
include("xtree/xtree.jl")
include("xtree/selectors.jl")
include("xtree/catas.jl")
include("xtree/folds.jl")


# Input and output formats
include("formats/format.jl")
include("formats/markdown.jl")
include("formats/html.jl")
include("formats/jupyter.jl")
include("formats/json.jl")


# utils
include("rewriters/documenttree.jl")
include("files.jl")
include("reflectionutils.jl")
include("references.jl")


# ## Project
include("rewriters.jl")
include("project.jl")
include("builders.jl")


# ## Rewriters
include("rewriters/basic.jl")
include("rewriters/inserter.jl")

## for html
include("rewriters/html/basic.jl")
include("rewriters/html/assets.jl")
include("rewriters/html/templater.jl")

## for loading source documents
include("rewriters/documentfolder.jl")

## semantic transformations
include("rewriters/referencer.jl")
include("rewriters/coderunner.jl")
include("rewriters/toc.jl")


# ## Serving
include("serve/events.jl")
include("serve/server.jl")
include("serve/servefiles.jl")
include("rewriters/packagewatcher.jl")

include("projects.jl")



export select,
    XTree, XNode, XLeaf,
    cata, catafirst, replace, replacefirst, fold, catafold,
    SelectNode,
    Replacer, Inserter, HTMLTemplater, ExecuteCode,
    NthChild, FirstChild, Before, After,
    Project, build,
    SelectTag, SelectOr, XExpr, ChangeTag, htmlify, AddSlugID, AddTableOfContents, SelectAttrEq,
    Selector, parse, HTML, Markdown, resolveidentifier, serve,
    AddID, HTMLify, ChangeLinkExtension, FormatCode, AddTableOfContents, Referencer, DocumentFolder,
    documentationproject, Server, runserver, ServeFiles, ServeFilesLazy,
    PackageWatcher,
    RelativeLinks

end
