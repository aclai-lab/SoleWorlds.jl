module SoleWorlds

    abstract type AbstractWorld end

    struct UndefWorld       <: AbstractWorld
        value::Union{Number,Array{<:Number}}
    end

    struct Point            <: AbstractWorld
        value::Number
    end

    struct Intervall        <: AbstractWorld
        values::Array{<:Number,1}
    end

    struct Rectangle        <: AbstractWorld
        values::Array{<:Number,2}
    end

    struct Parallelepiped   <: AbstractWorld
        values::Array{<:Number,3}
    end

    struct HyperRectangle   <: AbstractWorld
        values::Array{<:Number}

        function HyperRectangle(values::Array{<:Number})
            @assert ndims(values) >= 4 "HyperRectangle is not defined for less than
                                        4 dimensions\n"
        end
    end

    show(io::IO,x::UndefWorld)      = println(io,typeof(x)," with value ", x.value);
    show(io::IO,x::Point)           = println(io,typeof(x)," with value ", x.value);
    show(io::IO,x::Intervall)       = println(io,typeof(x)," with values ", x.values);
    show(io::IO,x::Rectangle)       = println(io,typeof(x)," with values ", x.values);
    show(io::IO,x::Parallelepiped)  = println(io,typeof(x)," with values ", x.values);
    show(io::IO,x::HyperRectangle)  = println(io,typeof(x), " with values ",x.values,
                                                " on ", ndims(x), " dimensions");

end
