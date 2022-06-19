import Base: isiterable

@doc raw"""
    PseudoBooleanFunction{S, T}(c::T)
    PseudoBooleanFunction{S, T}(ps::Pair{Vector{S}, T}...)

A Pseudo-Boolean Function ``f \in \mathscr{F}`` over some field ``\mathbb{T}`` takes the form

```math
f(\mathbf{x}) = \sum_{\omega \in \Omega\left[f\right]} c_\omega \prod_{j \in \omega} \mathbb{x}_j
```

where each ``\Omega\left[{f}\right]`` is the multi-linear representation of ``f`` as a set of terms. Each term is given by a unique set of indices ``\omega \subseteq \mathbb{S}`` related to some coefficient ``c_\omega \in \mathbb{T}``. We say that ``\omega \in \Omega\left[{f}\right] \iff c_\omega \neq 0``.
Variables ``\mathbf{x}_i`` are indeed boolean, thus ``f : \mathbb{B}^{n} \to \mathbb{T}``.

## References
 * [1] Endre Boros, Peter L. Hammer, Pseudo-Boolean optimization, Discrete Applied Mathematics, 2002 [{doi}](https://doi.org/10.1016/S0166-218X(01)00341-9)
"""
struct PseudoBooleanFunction{S <: Any, T <: Number}
    Ω::Dict{Set{S}, T}

    function PseudoBooleanFunction{S, T}(kv::Any) where {S, T}
        @assert isiterable(typeof(kv))

        Ω = Dict{Set{S}, T}()

        for (η, a) in kv
            ω = isnothing(η) ? Set{S}() : Set{S}(η)
            c = get(Ω, ω, zero(T)) + convert(T, a)
            if iszero(c)
                delete!(Ω, ω)
            else
                Ω[ω] = c
            end
        end
        
        new{S, T}(Ω)
    end

    function PseudoBooleanFunction{S, T}(Ω::Dict{Union{Set{S}, Nothing}, T}) where {S, T}
        new{S, T}(Dict{Set{S}, T}(isnothing(ω) ? Set{S}() : ω => c for (ω, c) in Ω if c != zero(T)))
    end

    # -*- Empty -*-
    function PseudoBooleanFunction{S, T}() where {S, T}
        new{S, T}(Dict{Set{S}, T}())
    end

    function PseudoBooleanFunction{S, T}(::Nothing) where {S, T}
        new{S, T}(Dict{Set{S}, T}())
    end

    # -*- Constant -*-
    function PseudoBooleanFunction{S, T}(c::T) where {S, T}
        if c === zero(T)
            new{S, T}(Dict{Set{S}, T}())
        else
            new{S, T}(Dict{Set{S}, T}(Set{S}() => c))
        end
    end

    # -*- Terms -*-
    function PseudoBooleanFunction{S, T}(ω::Set{S}) where {S, T}
        new{S, T}(Dict{Set{S}, T}(ω => one(T)))
    end

    function PseudoBooleanFunction{S, T}(ω::Vararg{S}) where {S, T}
        new{S, T}(Dict{Set{S}, T}(Set{S}(ω) => one(T)))
    end

    # -*- Pairs (Vectors) -*-
    function PseudoBooleanFunction{S, T}(
            ps::Vararg{Union{Pair{Vector{S}, T}, Pair{Set{S}, T}, Pair{Nothing, T}}}
        ) where {S, T}
        Ω = Dict{Set{S}, T}()

        for (η, a) in ps
            ω = isnothing(η) ? Set{S}() : Set{S}(η)
            c = get(Ω, ω, zero(T)) + a

            if c == zero(T)
                delete!(Ω, ω)
            else
                Ω[ω] = c
            end
        end

        new{S, T}(Ω)
    end

    # -*- Default -*-
    function PseudoBooleanFunction(args...)
        PseudoBooleanFunction{Int, Float64}(args...)
    end
end

# -*- Alias -*-
const PBF{S, T} = PseudoBooleanFunction{S, T}

#-*- Copy -*-
Base.copy(f::PBF{S, T}) where {S, T} = PBF{S, T}(copy(f.Ω))

# -*- Iterator & Length -*-
Base.length(f::PBF) = length(f.Ω)
Base.empty!(f::PBF) = empty!(f.Ω)
Base.isempty(f::PBF) = isempty(f.Ω)
Base.iterate(f::PBF) = iterate(f.Ω)
Base.iterate(f::PBF, i::Int) = iterate(f.Ω, i)

# -*- Indexing: Get -*-
Base.getindex(f::PBF{S, T}, ω::Set{S}) where {S, T} = get(f.Ω, ω, zero(T))
Base.getindex(f::PBF{S, <:Any}, η::Vector{S}) where {S} = getindex(f, Set{S}(η))
Base.getindex(f::PBF{S, <:Any}, ξ::S...) where {S} = getindex(f, Set{S}(ξ))
Base.getindex(f::PBF{S, <:Any}, ::Nothing) where {S} = getindex(f, Set{S}())

# -*- Indexing: Set -*-
function Base.setindex!(f::PBF{S, T}, c::T, ω::Set{S}) where {S, T}
    if iszero(c) && haskey(f.Ω, ω)
        delete!(f.Ω, ω)
        c
    else
        setindex!(f.Ω, c, ω)
    end
end

Base.setindex!(f::PBF{S, T}, c::T, η::Vector{S}) where {S, T} = setindex!(f, c, Set{S}(η))
Base.setindex!(f::PBF{S, T}, c::T, ξ::S...) where {S, T} = setindex!(f, c, Set{S}(ξ))
Base.setindex!(f::PBF{S, T}, c::T, ::Nothing) where {S, T} = setindex!(f, c, Set{S}())

# -*- Properties -*-
Base.size(f::PBF{S, T}) where {S, T} = length(f) - haskey(f.Ω, Set{S}())

# -*- Comparison: (==, !=, ===, !==)
Base.:(==)(f::PBF{S, T}, g::PBF{S, T}) where {S, T} = f.Ω == g.Ω
Base.:(!=)(f::PBF{S, T}, g::PBF{S, T}) where {S, T} = f.Ω != g.Ω


# -*- Arithmetic: (+) -*-
function Base.:(+)(f::PBF{S, T}, g::PBF{S, T}) where {S, T}
    h = copy(f)
    for (ω, c) in g.Ω
        h[ω] += c
    end
    return h
end

function Base.:(+)(f::PBF{S, T}, c::T) where {S, T}
    g = copy(f)
    g[nothing] += c
    return g
end

function Base.:(+)(c::T, f::PBF{S, T}) where {S, T}
    return +(f, c)
end

# -*- Arithmetic: (-) -*-
function Base.:(-)(f::PBF{S, T}) where {S, T}
    return PBF{S, T}(Dict{Set{S}, T}(ω => -c for (ω, c) in f.Ω))
end

function Base.:(-)(f::PBF{S, T}, g::PBF{S, T})::PBF{S, T} where {S, T}
    h = copy(f)
    for (ω, c) in g.Ω
        h[ω] -= c
    end
    return h
end

function Base.:(-)(f::PBF{S, T}, c::T)::PBF{S, T} where {S, T}
    g = copy(f)
    g[nothing] -= c
    return g
end

function Base.:(-)(c::T, f::PBF{S, T})::PBF{S, T} where {S, T}
    g = -(f)
    g[nothing] += c
    return g
end

# -*- Arithmetic: (*) -*-
function Base.:(*)(f::PBF{S, T}, g::PBF{S, T}) where {S, T}
    if isempty(f) || isempty(g)
        PBF{S, T}()
    end

    h = PBF{S, T}()

    for (ωᵢ, cᵢ) in f.Ω, (ωⱼ, cⱼ) in g.Ω
        h[union(ωᵢ, ωⱼ)] += cᵢ * cⱼ
    end

    h
end

function Base.:(*)(f::PBF{S, T}, c::T) where {S, T}
    if iszero(c)
        PBF{S, T}()
    else
        PBF{S, T}(ω => a * c for (ω, a) ∈ f.Ω)
    end
end

function Base.:(*)(c::T, f::PBF{<:Any, T}) where T
    *(f, c)
end

# -*- Arithmetic: (/) -*-
function Base.:(/)(f::PBF{S, T}, c::T) where {S, T}
    if iszero(c)
        error(DivideError, ": division by zero") 
    else
        PBF{S, T}(Dict(ω => a / c for (ω, a) ∈ f.Ω))
    end
end

# -*- Arithmetic: (^) -*-
function Base.:(^)(f::PBF{S, T}, n::Int) where {S, T}
    if n < 0
        error(DivideError, ": Can't raise Pseudo-boolean function to a negative power")
    elseif n == 0
        return one(PBF{S, T})
    elseif n == 1
        return copy(f)
    else 
        g = PBF{S, T}(one(T))
        for _ = 1:n
            g *= f
        end
        return g
    end
end

# -*- Arithmetic: Evaluation -*-
function (f::PBF{S, T})(x::Dict{S, <:Integer}) where {S, T}
    g = PBF{S, T}()
    
    for (ω, c) in f
        η = Set{S}()
        for j in ω
            if haskey(x, j)
                if !(x[j] > 0)
                    c = zero(T)
                    break
                end
            else
                push!(η, j)
            end
        end
        g[η] += c
    end

    return g
end

function (f::PBF{S, T})(x::Pair{S, <:Integer}...) where {S, T}
    return f(Dict{S, <:Integer}(x...))
end

# -*- Type conversion -*-
function Base.convert(U::Type{<:T}, f::PBF{S, T}) where {S, T}
    if isempty(f)
        return zero(U)
    elseif degree(f) == 0
        return convert(U, f[nothing])
    else
        error("Can't convert non-constant Pseudo-boolean Function to scalar type $U")
    end
end

function Base.zero(::Type{<:PBF{S, T}}) where {S, T}
    PBF{S, T}()
end

function Base.one(::Type{<:PBF{S, T}}) where {S, T}
    PBF{S, T}(one(T))
end

function Base.round(f::PBF{S, T}; digits::Integer = 0) where {S, T}
    PBF{S, T}(ω => round(c; digits=digits) for (ω, c) ∈ f)
end