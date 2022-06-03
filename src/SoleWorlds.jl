module SoleWorlds

# imports/usings
using Base.Cartesian

import Base: show
import IterTools

# exports
export IntervalWorld, RectangleWorld, CubeWorld

# abstract types
abstract type AbstractWorld end
abstract type ShapeWorld    <: AbstractWorld end

# concrete types
struct Worlds <: AbstractArray{AbstractWorld, 1}
    worlds::AbstractArray{AbstractWorld, 1}
end

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

# aliases
const IntervalWorld  = HyperRectangleWorld{1}
const RectangleWorld = HyperRectangleWorld{2}
const CubeWorld      = HyperRectangleWorld{3}

#shows
show(io::IO, w::PointWorld)                         = print(io, typeof(w), ": ", w.coord)
show(io::IO, w::T) where T<:HyperRectangleWorld     = print(io, typeof(w), ": ", w.coords)

# Note: this monolitic comment will be shrinked up
#
# The following is used to generate a code similar to this
#
# return [
#   HyperRectangleWorld{N}( [x_1, x_2, x_3 ... x_N] )
#   for x_N in IterTools.subsets( [1:d[N]...], Val(2))
#   ...
#   for x_1 in IterTools.subsets( [1:d[1]...], Val(2))
# ]
#
# where d is a NTuple collection of dimension N.
#
# https://docs.julialang.org/en/v1/devdocs/cartesian/#Anonymous-function-expressions-as-macro-arguments

function dimensional_permutations(A::NTuple{N,Int}) where {N}
    # This is the only way i have found to generate new variable names
    # in the same row while also grouping them in a vector.
    # [i_1 , i_2 , i_3 , ... , i_N]
    function variables(kwargs...)
        return [ kwargs[i] for i in 1:length(kwargs) ]
    end

    # Collecting all the possible permutations here is computationally expensive.
    # TODO: a generator could be returned instead.
    collection = HyperRectangleWorld{N}[];

    # Generates N loop; a loop "shape" is as following
    # " for i_d = IterTools.subsets( [1:A[d]...] , Val(2) ) ... "
    # meaning that variable i_1, i_2, i_3 ... contains a new interesting permutation
    #
    # After the loop generation, a new HyperRectangleWorld is pushed into collection
    # in order to do so we need to generalize this syntax
    # ... HyperRectangleWorld{N}( [i_1, i_2, i_3 ... i_N ] )
    # since there is no macro for this exact purpose,
    # and we cannot exploit some string notation like [ "$(i_d)," for d in 1:N ]
    # see "variables" function and @ncall in Base.Cartesian documentation

    # Please use "@show @macroexpand" to see more details
    exp = quote
            @nloops $N i d -> IterTools.subsets( [1:$A[d]...], Val(2) ) begin
                push!($collection, HyperRectangleWorld{$N}( @ncall $N $variables i ) )
            end
        return $collection;
    end

    eval(exp)
end

# worlds generators
function world_gen(d::Int)
    return [PointWorld(i) for i in 1:d]
end

function world_gen(npoints::NTuple{N,Int}) where N
    return dimensional_permutations(npoints)
end

# TESTS

# Different types of world coexist
# w = Worlds( vcat( world_gen((5)), world_gen((6,9)) , world_gen((4,2,4)) ) )
# @show w.worlds

# w = Worlds( world_gen((3,3)) )
# @show w.worlds

w = world_gen((3,3))
@show w

end

# Notes
# Maybe some Int type could be changed in Int16 or UInt;
# all in all the default Int64 is a waste of memory
