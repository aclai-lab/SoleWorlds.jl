module SoleWorlds

# imports/usings
import Base: show

# exports
export IntervalWorld, RectangleWorld, CubeWorld

#abstract types
abstract type AbstractWorld end
abstract type ShapeWorld    <: AbstractWorld end

#concrete types
struct PointWorld           <: AbstractWorld
    coord::Real
end

struct HyperRectangleWorld{N}    <: ShapeWorld
    coords::Vector{<:NTuple{2,<:Real}}

    function HyperRectangleWorld{N}(coords::Vector{<:NTuple{2,<:Real}}) where N
        @assert N == length(coords) "N=$N is not equal to length(coords)=$(length(coords))"
        return new{N}(coords)
    end

    function HyperRectangleWorld(coords::Vector{<:NTuple{2,<:Real}})
        return HyperRectangleWorld{length(coords)}(coords)
    end
end

#aliases
const IntervalWorld  = HyperRectangleWorld{1}
const RectangleWorld = HyperRectangleWorld{2}
const CubeWorld      = HyperRectangleWorld{3}

#shows
show(io::IO, w::PointWorld)                         = print(io, typeof(w), ": ", w.coord)
show(io::IO, w::T) where T<:HyperRectangleWorld     = print(io, typeof(w), ": ", w.coords)

end
