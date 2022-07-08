module SoleWorlds

using Base.Cartesian
import Base: show
import IterTools

export HyperRectangleWorld, IntervalWorld, RectangleWorld, CubeWorld
export world_gen

include("worlds.jl")

end
