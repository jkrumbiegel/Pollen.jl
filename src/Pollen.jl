module Pollen

using ANSIColoredPrinters
using AbstractTrees
using Base.Docs
import Crayons: @crayon_str
import CommonMark as CM
import Base64: Base64EncodePipe
import JuliaSyntax
using CSTParser
using DataFrames
using FilePathsBase
using DataStructures: DefaultDict, OrderedDict
import Gumbo
using InlineTest
using JuliaFormatter
using Graphs
using MetaGraphs
using Mustache
using LiveServer
import LiveServer
using HTTP
using TOML
using IOCapture
using ModuleInfo
using InlineTest
using JSON3
using ThreadSafeDicts
import Random
using Revise
import Git
using PkgTemplates
using PkgTemplates: @plugin, @with_kw_noshow, Plugin, hook, getplugin, with_project,
    render_file, gen_file
using Pkg



# We first define [`Node`](#)s and [`Leaf`](#)s, the data structure that underpins
# the rest of the library. We also define selectors to find parts of a tree.
# Additionally, catamorphisms can be used to functionally transform these trees.

include("xtree/xtree.jl")
include("xtree/selectors.jl")
include("xtree/catamorphisms.jl")
include("xtree/folds.jl")

include("files.jl")

# So that we can represent data from different formats as a tree, we define
# [`Format`](#)s that allow reading and/or writing from and to different
# file formats.

include("formats/format.jl")
include("formats/_ijulia_display.jl")
include("formats/markdown.jl")
include("formats/json.jl")
include("formats/juliasyntax.jl")
include("formats/html.jl")
include("formats/jupyter.jl")

export MarkdownFormat, JSONFormat, HTMLFormat, JuliaSyntaxFormat, JupyterFormat

include("rewriters.jl")
include("project.jl")
include("builders.jl")

include("serve/events.jl")
include("serve/server.jl")
include("serve/servefiles.jl")

include("rewriters/documentfolder.jl")
include("rewriters/documenttree.jl")
include("rewriters/basic.jl")
include("rewriters/assets.jl")
include("rewriters/templater.jl")
include("rewriters/coderunner.jl")
include("rewriters/inserter.jl")
include("rewriters/toc.jl")
include("rewriters/packagewatcher.jl")
include("rewriters/parsecode.jl")
include("rewriters/parseansi.jl")

include("frontend/references.jl")
include("frontend/documentgraph.jl")
include("frontend/searchindex.jl")
include("frontend/saveattributes.jl")
include("frontend/loadfrontendconfig.jl")
include("frontend/staticresources.jl")

include("pkgtemplate.jl")

export select, selectfirst,
    XTree, Node, Leaf,
    cata, catafirst, replace, replacefirst, fold, catafold,
    SelectNode,
    Replacer, Inserter, HTMLTemplater, ExecuteCode,
    NthChild, FirstChild, Before, After,
    Project, build, FileBuilder,
    SelectTag, SelectOr, XExpr, ChangeTag, htmlify, AddSlugID, AddTableOfContents, SelectAttrEq,
    Selector, resolveidentifier, serve,
    # rewriters
    AddID, HTMLify, ChangeLinkExtension, FormatCode, AddTableOfContents, Referencer, DocumentFolder,
    documentationproject, Server, runserver, ServeFiles, ServeFilesLazy,
    PackageWatcher, StaticResources, ParseCode, PackageDocumentation,
    RelativeLinks, DocumentGraph, SearchIndex, SaveAttributes, LoadFrontendConfig

end
