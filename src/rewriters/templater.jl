

mutable struct HTMLTemplater <: Rewriter
    assets::Assets
    template::XNode
    templatepath::AbstractPath
    inlineincludes::Bool
    insertpos::Position
end

Base.show(io::IO, templater::HTMLTemplater) = print(io, "HTMLTemplater($(templater.assets)), $(templater.templatepath)")

function HTMLTemplater(
        templatepath::AbstractPath,
        includes::Vector{<:AbstractPath}=Path[];
        inlineincludes=false,
        insertpos=FirstChild(SelectTag(:body)),
    )
    # TODO
    template = Pollen.parse(templatepath)
    assets = Assets(includes)
    if inlineincludes
        template = inlineintemplate(template, assets.srcpaths)
    else
        template = includeintemplate(template, assets.dstpaths)
    end

    return HTMLTemplater(assets, template, templatepath, inlineincludes, insertpos)
end


function updatefile(templater::HTMLTemplater, p, doc)
    # Include the document in the template
    doc = insertfirst(templater.template, doc, templater.insertpos)
    return doc
end


function includeintemplate(template::XNode, includes)
    for p in includes
        ext = extension(p)
        if ext == "css"
            x = XNode(:link, Dict(:rel => "stylesheet", :href => "/" * string(p)))
        elseif ext == "js"
            x = XNode(:script, Dict(:src => "/" * string(p)))
        else
            continue
        end
        template = insertfirst(template, x, FirstChild(SelectTag(:head)))
    end

    return template
end


function inlineintemplate(template::XNode, includes)
    for p in includes
        ext = extension(p)
        if ext == "css"
            x = XNode(:style, [XLeaf(read(p, String))])
        elseif ext == "js"
            x = XNode(:script, [XLeaf(read(p, String))])
        end
        template = insertfirst(template, x, FirstChild(SelectTag(:head)))
    end
    return template
end


function getfilehandlers(templater::HTMLTemplater, project, srcdir, dst, format)
    handlers =  [
        # When template changes, reload it and rebuild every file
        (
            absolute(templater.templatepath),
            () -> onupdatetemplate(templater, project, dst, format)
        ),
    ]

    if templater.inlineincludes
        handlers = vcat(handlers, [
            (p, () -> onupdatetemplate(templater, project, dst, format)) for p in templater.assets.srcpaths
        ])
    else
        handlers = vcat(handlers, getfilehandlers(templater.assets, project, dst, format))
    end
    return handlers
end


function onupdatetemplate(templater, project, dst, format)
    template = Pollen.parse(templater.templatepath)
    if templater.inlineincludes
        templater.template = inlineintemplate(template, templater.assets.srcpaths)
    else
        templater.template = includeintemplate(template, templater.assets.dstpaths)
    end
    build(project, dst, format)
end

function onupdateinclude(templater, project, dst, format)
    build(project, dst, format)
end


function postbuild(templater::HTMLTemplater, project, dst, format)
    postbuild(templater.assets, project, dst, format)
end
