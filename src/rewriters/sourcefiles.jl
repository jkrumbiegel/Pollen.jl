
function SourceFiles(ms::Vector{Module})
    pkgdirs = pkgdir.(ms)
    if any(isnothing, pkgdirs)
        i::Int = findfirst(isnothing, pkgdirs)
        throw(ArgumentError("Could not find a package directory for module '$(ms[i])'"))
    end
    pkgids = ["$m@$(ModuleInfo.packageversion(m))" for m in ms]
    return DocumentFolder(["$pkgid/src/" => joinpath(dir, "src")
                           for (pkgid, dir) in zip(pkgids, pkgdirs)];
                          filterfn = hasextension("jl"), loadfn = __load_source_file)
end

function __load_source_file(file::String, id)
    title = joinpath(splitpath(file)[2:end]...)
    doc = Pollen.parse(String(read(file)), JuliaSyntaxFormat())
    doc = preparesourcefile(doc)
    return Node(:sourcefile,
                [doc],
                Dict{Symbol, Any}(:path => file, :title => title,
                                  :module => split(id, "/")[1]))
end

# Some helpers for loading source files, ensuring
# 1. inline comments are pased as Markdown
# 2. docstrings are stripped

preparesourcefile(tree) = tree |> __stripdocstrings |> __splitoncomments

function __stripdocstrings(tree)
    Pollen.cata(tree, SelectTag(:MACROCALL)) do node
        isempty(children(node)) && return node
        if tag(first(children(node))) == :CORE_DOC_MACRO_NAME
            return children(node)[end]
        else
            return node
        end
    end
end

# TODO: fix parsing for consecutive comments separated by non-comment whitespace
# TODO: fix parsing inside module definitions
function __splitoncomments(node)
    chs = Node[]

    in_comment = false

    comment = String[]
    code = Node[]

    for ch in children(node)
        if tag(ch) === :COMMENT
            if !isempty(code)
                push!(chs, Node(:codeblock, code...; lang = "julia"))
                code = Node[]
            end
            in_comment = true
            push!(comment, _strip_comment(Pollen.gettext(ch)))
            push!(comment, " ")
        elseif in_comment & (tag(ch) == :NEWLINE_WS || tag(ch) == :WHITESPACE)
            continue
        else
            if !isempty(comment)
                push!(chs, Pollen.parse(join(comment), MarkdownFormat()))
                comment = String[]
            end
            in_comment = false
            push!(code, ch)
        end
    end
    isempty(code) || push!(chs, Node(:codeblock, code...; lang = "julia"))
    isempty(comment) || push!(chs, Pollen.parse(join(comment), MarkdownFormat()))

    return Pollen.withchildren(node, chs)
end

function _strip_comment(str)
    if startswith(str, "#=")
        return strip(str[3:(end - 2)])
    else
        return strip(str[2:end])
    end
end
