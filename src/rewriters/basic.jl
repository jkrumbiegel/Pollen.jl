# AddIDs

const SEL_H1234 = SelectOr(SelectTag.((:h1, :h2, :h3, :h4)))
const SEL_H234 = SelectOr(SelectTag.((:h2, :h3, :h4)))

"""
    AddID(selector = sel"h2, h3, h4"; idfn)

`Replacer` that adds an `id` attribute to every x-expression
selected by `selector`. It assumes that its first child is a `String`.
The id is created by applying `idfn` to that string. `idfn` defaults
to `CommonMark.slugify`.
"""
AddID(sel=SEL_H234; idfn=CommonMark.slugify) =
    Replacer(x -> addid(x; idfn=idfn), sel)


function addid(x; idfn=CommonMark.slugify)
    #(!isempty(children(x)) && children(x)[1] isa String) || error(
    #    "To add an ID, first child must be a `String`. Got xexpr\n$doc")
    text = gettext(x)
    #text = children(x)[1]
    id = idfn(text)
    return withattributes(x, Dict(:id => id))
end


# HTMLify

function HTMLify(sel=SelectNode(), htmltag=:div)
    return Replacer(sel) do x
        htmlify(x, htmltag)
    end
end


# ChangeTag

function ChangeTag(t, sel)
    return Replacer(x -> withtag(x, t), sel)
end


# FormatCode

function FormatCode(codesel = SelectTag(:pre))
    return Replacer(x -> formatcodeblock(x), codesel)
end


function formatcodeblock(doc)
    if get(attributes(doc), :lang, "") == "julia"
        code = gettext(doc)
        try
            code = format_text(code)
        catch
            @info "Parsing error when formatting code snippet: \n\n$code"
        end
        return withchildren(doc, [XNode(:code, XLeaf(code))])
    else
        return doc
    end
end
