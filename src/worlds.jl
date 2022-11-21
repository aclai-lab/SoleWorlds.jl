abstract type AbstractWorld end
abstract type ShapeWorld <: AbstractWorld end

struct PointWorld <: AbstractWorld
    coord::Real
end
show(io::IO, w::PointWorld) = print(io, typeof(w), ": ", w.coord)

struct HyperRectangleWorld{N} <: ShapeWorld
    coords::NTuple{N, NTuple{2, Int64}}

    function HyperRectangleWorld{N}(coords::NTuple{N, NTuple{2, Int64}}) where N
        @assert N == length(coords) "N=$N is not equal to length(coords)=$(length(coords))"
        return new{N}(coords)
    end
end
show(io::IO, w::T) where T<:HyperRectangleWorld = print(io, typeof(w), ": ", w.coords)

const IntervalWorld  = HyperRectangleWorld{1} # w = IntervalWorld ( ((x1,x2), ) )
const RectangleWorld = HyperRectangleWorld{2} # w = RectangleWorld( ((x1,x2), (x3,x4)) )
const CubeWorld      = HyperRectangleWorld{3} # w = ..

#################################
#           Wrappers            #
#################################

struct Worlds{T<:AbstractWorld} <: AbstractArray{T,1}
    worlds::Array{T,1}
end
Base.size(w::Worlds) = size(w.worlds)
Base.axes(w::Worlds) = (1:length(w.worlds),)
Base.IndexStyle(::Type{<:Worlds}) = IndexLinear()
Base.getindex(w::Worlds, i::Int) = w.worlds[i]
Base.setindex!(w::Worlds, aw::AbstractWorld, i::Int) = w.worlds[i] = aw
Base.push!(w::Worlds, aw::AbstractWorld) = push!(w.worlds, aw)

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
# https://docs.julialang.org/en/v1/devdocs/cartesian/#Anonymous-function-expressions-as-macro-arguments

function _dimensional_permutations(A::NTuple{N,Int}) where {N}
    # This is the only way i have found to generate new variable names
    # in the same row while also grouping them in a vector.
    # [i_1 , i_2 , i_3 , ... , i_N]
    function variables(kwargs...)
        return NTuple{N, NTuple{2, Int64}}(kwargs)
        #return [ kwargs[i] for i in eachindex(kwargs) ]
    end

    collection = HyperRectangleWorld{N}[]

    # Generate N loop with the following structure
    # " for i_d = IterTools.subsets( [1:A[d]...] , Val(2) ) ... "
    # meaning that variable i_1, i_2, i_3 ... contains a new interesting permutation
    #
    # After the loop generation, a new HyperRectangleWorld is pushed into collection
    # in order to do so we need to generalize this syntax
    # ... HyperRectangleWorld{N}( [i_1, i_2, i_3 ... i_N ] )
    # since there is no macro for this exact purpose,
    # and we cannot exploit some string notation like [ "$(i_d)," for d in 1:N ]
    # see "variables" function and @ncall in Base.Cartesian documentation

    # Use "@show @macroexpand" to see more details
    exp = quote
            @nloops $N i d -> IterTools.subsets( [1:$A[d]...], Val(2) ) begin
                push!($collection, HyperRectangleWorld{$N}( @ncall $N $variables i ) )
            end
        return $collection;
    end

    eval(exp)
end

# Generate all the subspaces of a N-dimensional space.
function world_gen(d::Int)
    return [PointWorld(i) for i in 1:d]
end

function world_gen(npoints::NTuple{N,Int}) where N
    return _dimensional_permutations(npoints)
end
