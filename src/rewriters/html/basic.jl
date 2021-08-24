
"""
    htmlify(doc, htmltag = :div)

If `doc.tag` is not a valid HTML tag, changes it into a :div and adds the attribute
`:class => doc.tag`.
"""
function htmlify(doc, htmltag=:div)
    if tag(doc) in HTMLTAGS
        return doc
    else
        return XNode(
            htmltag,
            # TODO: add to classes if exist
            merge(attributes(doc), Dict(:class => string(tag(doc)))),
            children(doc),
        )
    end
end


# ChangeLinkExtensions

function ChangeLinkExtension(ext, sel::Selector = SelectTag(:a); linkattr = :href)
    return Replacer(x -> changelinkextension(x, ext; attr = linkattr), sel)
end


function changelinkextension(doc::XNode, ext; attr = :href)
    if haskey(attributes(doc), attr)
        href = doc.attributes[attr]
        if startswith(href, "http") || startswith(href, "www")
            return doc
        else
            return withattributes(
                doc,
                merge(doc.attributes, Dict(attr => changehrefextension(href, ext))),
            )
        end
    else
        return doc
    end
end


const CSSLINKSELECTOR = SelectTag(:link) & SelectHasAttr(:href)

Base.@kwdef struct RelativeLinks <: Rewriter
    linktag::Symbol = :a
    linkattr::Symbol = :href
end


function rewritedoc(rewriter::RelativeLinks, p, doc)
    sel = SelectTag(rewriter.linktag) & SelectHasAttr(rewriter.linkattr)
    cata(doc, sel) do x
        href = attributes(x)[rewriter.linkattr]
        if startswith(href, '/')
            newhref = relpath(href, "/" * string(parent(p)))
            return withattributes(x, merge(attributes(x), Dict(rewriter.linkattr => newhref)))
        else
            return x
        end
    end
end


#

function createtitle(p, x)
    h1 = selectfirst(x, SelectTag(:h1))
    title = if !isnothing(h1)
        gettext(h1)
    else
        string(filename(p))
    end
    return XNode(:title, [XLeaf(title)])
end


struct HTMLRedirect <: Rewriter
    p::AbstractPath
end


function postbuild(redirect::HTMLRedirect, project, builder)
    builder isa FileBuilder || error("`HTMLRedirect` does not work with $builder")
    redirectpath = withext(redirect.p, formatextension(builder.format))
    content = """
    <!DOCTYPE html>
    <html>
    <head>
    <meta http-equiv = "refresh" content = "0; url = $redirectpath" />
    </head>
    </html>
    """
    open(joinpath(builder.dir, "index.html"), "w") do f
        write(f, content)
    end
end
