# Defines `XExpr` the type representing every document and `xexpr`, a
# helper used to create `XExpr`s.

struct XExpr
    tag::Symbol
    attributes::Dict{Symbol, <:Any}
    children
end

Base.show(io::IO, x::XExpr) = print_tree(io, x, 2)

function AbstractTrees.printnode(io::IO, x::XExpr)
    print(io, x.tag)
    if !isempty(x.attributes)
        print(io, " [")
        for (i, (key, value)) in enumerate(x.attributes)
            if i != 1
                print(io, ", ")
            end
            print(io, key, " = ", value)
        end
        print(io, "]")
    end
end



AbstractTrees.children(x::XExpr) = x.children


"""
    xexpr(str)
    xexpr(tag, children...)
    xexpr(tag, attributes::Dict, children...)

Create an `XExpr`.
"""
xexpr(s::String) = s
xexpr(x::XExpr) = x

xexpr(t::Tuple) = xexpr(t...)

function xexpr(tag::Symbol, children...)
    return XExpr(tag, Dict{Symbol, Any}(), xexpr.(children))
end

function xexpr(tag::Symbol, attributes::Dict{Symbol, <:Any}, children...)
    return XExpr(tag, attributes, xexpr.(children))
end


function xexpr(tag::Symbol, attributes::Dict{Symbol, <:Any}, children::Vector{<:Union{XExpr, T}}) where T
    return XExpr(tag, attributes, children)
end
