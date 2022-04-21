module SoleWorlds

#abstract types
abstract type AbstractWorld end
abstract type ShapeWorld    <: AbstractWorld end

#concrete types
struct PointWorld           <: AbstractWorld
    coord::Real
end

struct HyperRectangle{N}    <: ShapeWorld
    coords::Vector{<:NTuple{2,<:Real}}

    function HyperRectangle{N}(coords::Vector{<:NTuple{2,<:Real}}) where N
        @assert N == length(coords)
        return new{N}(coords)
    end

    function HyperRectangle(coords::Vector{<:NTuple{2,<:Real}})
        return HyperRectangle{length(coords)}(coords)
    end
end

#alias
const Intervall         = HyperRectangle{1}
const Rectangle         = HyperRectangle{2}
const Parallelepiped    = HyperRectangle{3}

#shows
show(world::PointWorld)      = println(typeof(World)," with values ",world.coord)
show(world::HyperRectangle)  = println(typeof(world)," with values ",world.coords)
show(world::Intervall)       = println(typeof(world)," with values ",world.coords)
show(world::Rectangle)       = println(typeof(world)," with values ",world.coords)
show(world::Intervall)       = println(typeof(world)," with values ",world.coords)

end
