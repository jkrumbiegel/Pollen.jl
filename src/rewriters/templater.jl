

mutable struct HTMLTemplater <: Rewriter
    assets::Assets
    template::Node
    templatepath::AbstractPath
    inlineincludes::Bool
    insertpos::Position
end

Base.show(io::IO, templater::HTMLTemplater) = print(io, "HTMLTemplater($(templater.assets)), $(templater.templatepath)")

function HTMLTemplater(
        templatepath::AbstractPath,
        includes::Vector{<:AbstractPath}=Path[];
        assetdir = Path("."),
        inlineincludes=false,
        insertpos=FirstChild(SelectTag(:body)),
    )
    template = Pollen.parse(templatepath)
    assets = Assets(Dict(joinpath(p"template/", p) => absolute(joinpath(assetdir, p)) for p in includes))
    if inlineincludes
        template = inlineintemplate(
            template,
            [absolute(joinpath(assetdir, p)) for p in includes])
    else
        template = includeintemplate(template,  [joinpath(p"template/", p) for p in includes])
    end

    return HTMLTemplater(assets, template, templatepath, inlineincludes, insertpos)
end


function rewritedoc(templater::HTMLTemplater, p, doc)
    # Include the document in the template
    doc = insertfirst(templater.template, doc, templater.insertpos)
    return doc
end


function includeintemplate(template::Node, includes)
    for p in includes
        ext = extension(p)
        if ext == "css"
            x = Node(:link, Dict(:rel => "stylesheet", :href => "/" * string(p)))
        elseif ext == "js"
            x = Node(:script, Dict(:src => "/" * string(p)))
        else
            continue
        end
        template = insertfirst(template, x, FirstChild(SelectTag(:head)))
    end

    return template
end


function inlineintemplate(template::Node, includes)
    for p in includes
        ext = extension(p)
        if ext == "css"
            x = Node(:style, [Leaf(read(p, String))])
        elseif ext == "js"
            x = Node(:script, [Leaf(read(p, String))])
        end
        template = insertfirst(template, x, FirstChild(SelectTag(:head)))
    end
    return template
end


function getfilehandlers(templater::HTMLTemplater, project, dir, builder)
    handlers =  [
        # When template changes, reload it and rebuild every file
        (
            absolute(templater.templatepath),
            () -> onupdatetemplate(templater, project, builder)
        ),
    ]

    if templater.inlineincludes
        handlers = vcat(handlers, [
            (p, () -> onupdatetemplate(templater, project, builder)) for p in values(templater.assets.assets)
        ])
    else
        handlers = vcat(handlers, getfilehandlers(templater.assets, project, dir, builder))
    end
    return handlers
end


function onupdatetemplate(templater, project, builder)
    template = Pollen.parse(templater.templatepath)
    if templater.inlineincludes
        templater.template = inlineintemplate(template, collect(values(templater.assets.assets)))
    else
        templater.template = includeintemplate(template, collect(keys(templater.assets.assets)))
    end
    rebuild(builder, project)
end


function postbuild(templater::HTMLTemplater, project, builder)
    postbuild(templater.assets, project, builder)
end


reset!(templater::HTMLTemplater) = reset!(templater.assets)
