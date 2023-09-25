module Attributes

import QUBOTools: PBO
import QUBOTools: AbstractArchitecture, GenericArchitecture

import MathOptInterface as MOI
const MOIU = MOI.Utilities
const VI   = MOI.VariableIndex
const CI   = MOI.ConstraintIndex

import ..ToQUBO: VirtualModel
import ..ToQUBO: Encoding, Unary, Binary, Arithmetic, OneHot, DomainWall, Bounded

export Warnings,
    Architecture,
    Discretize,
    Quadratize,
    QuadratizationMethod,
    StableQuadratization,
    DefaultVariableEncodingATol,
    DefaultVariableEncodingBits,
    DefaultVariableEncodingMethod,
    VariableEncodingATol,
    VariableEncodingBits,
    VariableEncodingMethod,
    VariableEncodingPenalty,
    ConstraintEncodingPenalty,
    QUBONormalForm

abstract type CompilerAttribute <: MOI.AbstractOptimizerAttribute end

@doc raw"""
    Warnings()
"""
struct Warnings <: CompilerAttribute end

function MOI.get(model::VirtualModel, ::Warnings)::Bool
    return get(model.compiler_settings, :warnings, true)
end

function MOI.set(model::VirtualModel, ::Warnings, flag::Bool)
    model.compiler_settings[:warnings] = flag

    return nothing
end

function MOI.set(model::VirtualModel, ::Warnings, ::Nothing)
    delete!(model.compiler_settings, :warnings)

    return nothing
end

@doc raw"""
    Optimization()
"""
struct Optimization <: CompilerAttribute end

function MOI.get(model::VirtualModel, ::Optimization)::Integer
    return get(model.compiler_settings, :optimization, 0)
end

function MOI.set(model::VirtualModel, ::Optimization, level::Integer)
    @assert level >= 0

    model.compiler_settings[:optimization] = level

    return nothing
end

function MOI.set(model::VirtualModel, ::Optimization, ::Nothing)
    delete!(model.compiler_settings, :optimization)

    return nothing
end

@doc raw"""
    Architecture()

Selects which solver architecture to use.
Defaults to [`GenericArchitecture`](@ref).
"""
struct Architecture <: CompilerAttribute end

function MOI.get(model::VirtualModel, ::Architecture)::AbstractArchitecture
    return get(model.compiler_settings, :architecture, GenericArchitecture())
end

function MOI.set(model::VirtualModel, ::Architecture, arch::AbstractArchitecture)
    model.compiler_settings[:architecture] = arch

    return nothing
end

function MOI.set(model::VirtualModel, ::Architecture, ::Nothing)
    delete!(model.compiler_settings, :architecture)

    return nothing
end

@doc raw"""
    Discretize()

When set, this boolean flag guarantees that every coefficient in the final formulation is an integer.
"""
struct Discretize <: CompilerAttribute end

function MOI.get(model::VirtualModel, ::Discretize)::Bool
    return get(model.compiler_settings, :discretize, false)
end

function MOI.set(model::VirtualModel, ::Discretize, flag::Bool)
    model.compiler_settings[:discretize] = flag

    return nothing
end

function MOI.set(model::VirtualModel, ::Discretize, ::Nothing)
    delete!(model.compiler_settings, :discretize)

    return nothing
end

@doc raw"""
    Quadratize()

Boolean flag to conditionally perform the quadratization step.
Is automatically set by the compiler when high-order functions are generated.
"""
struct Quadratize <: CompilerAttribute end

function MOI.get(model::VirtualModel, ::Quadratize)::Bool
    return get(model.compiler_settings, :quadratize, false)
end

function MOI.set(model::VirtualModel, ::Quadratize, flag::Bool)
    model.compiler_settings[:quadratize] = flag

    return nothing
end

@doc raw"""
    QuadratizationMethod()

Defines which quadratization method to use.
Available options are defined in the `PBO` submodule.
"""
struct QuadratizationMethod <: CompilerAttribute end

function MOI.get(model::VirtualModel, ::QuadratizationMethod)
    return get(model.compiler_settings, :quadratization_method, PBO.DEFAULT)
end

function MOI.set(
    model::VirtualModel,
    ::QuadratizationMethod,
    ::Type{method},
) where {method<:PBO.QuadratizationMethod}
    model.compiler_settings[:quadratization_method] = method

    return nothing
end

function MOI.set(model::VirtualModel, ::QuadratizationMethod, ::Nothing)
    delete!(model.compiler_settings, :quadratization_method)

    return nothing
end

@doc raw"""
    StableQuadratization()

When set, this boolean flag enables stable quadratization methods, thus yielding predictable results.
This is intended to be used during tests or other situations where deterministic output is desired.
On the other hand, usage in production is not recommended since it requires increased memory and processing resources.
"""
struct StableQuadratization <: CompilerAttribute end

function MOI.get(model::VirtualModel, ::StableQuadratization)::Bool
    return get(model.compiler_settings, :stable_quadratization, false)
end

function MOI.set(model::VirtualModel, ::StableQuadratization, flag::Bool)
    model.compiler_settings[:stable_quadratization] = flag

    return nothing
end

function MOI.set(model::VirtualModel, ::StableQuadratization, ::Nothing)
    delete!(model.compiler_settings, :stable_quadratization)

    return nothing
end

@doc raw"""
    DefaultVariableEncodingMethod()

Fallback value for [`VariableEncodingMethod`](@ref).
"""
struct DefaultVariableEncodingMethod <: CompilerAttribute end

function MOI.get(model::VirtualModel, ::DefaultVariableEncodingMethod)::Encoding
    return get(model.compiler_settings, :default_variable_encoding_method, Binary())
end

function MOI.set(model::VirtualModel, ::DefaultVariableEncodingMethod, e::Encoding)
    model.compiler_settings[:default_variable_encoding_method] = e

    return nothing
end

function MOI.set(model::VirtualModel, ::DefaultVariableEncodingMethod, ::Nothing)
    delete!(model.compiler_settings, :default_variable_encoding_method)

    return nothing
end

@doc raw"""
    DefaultVariableEncodingATol()

Fallback value for [`VariableEncodingATol`](@ref).
"""
struct DefaultVariableEncodingATol <: CompilerAttribute end

function MOI.get(model::VirtualModel{T}, ::DefaultVariableEncodingATol)::T where {T}
    return get(model.compiler_settings, :default_variable_encoding_atol, T(1 / 4))
end

function MOI.set(model::VirtualModel{T}, ::DefaultVariableEncodingATol, τ::T) where {T}
    model.compiler_settings[:default_variable_encoding_atol] = τ

    return nothing
end

function MOI.set(model::VirtualModel, ::DefaultVariableEncodingATol, ::Nothing)
    delete!(model.compiler_settings, :default_variable_encoding_atol)

    return nothing
end

@doc raw"""
    DefaultVariableEncodingBits()
"""
struct DefaultVariableEncodingBits <: CompilerAttribute end

function MOI.get(model::VirtualModel, ::DefaultVariableEncodingBits)::Union{Integer,Nothing}
    return get(model.compiler_settings, :default_variable_encoding_bits, nothing)
end

function MOI.set(model::VirtualModel, ::DefaultVariableEncodingBits, n::Integer)
    model.compiler_settings[:default_variable_encoding_bits] = n

    return nothing
end

function MOI.set(model::VirtualModel, ::DefaultVariableEncodingBits, ::Nothing)
    delete!(model.compiler_settings, :default_variable_encoding_bits)

    return nothing
end


@doc raw"""
    QUBONormalForm()
"""
struct QUBONormalForm <: CompilerAttribute end

function MOI.get(model::VirtualModel{T}, ::QUBONormalForm)::QUBO_NORMAL_FORM{T} where {T}
    target_model = model.target_model

    n = MOI.get(target_model, MOI.NumberOfVariables())
    F = MOI.get(target_model, MOI.ObjectiveFunctionType())
    f = MOI.get(target_model, MOI.ObjectiveFunction{F}())

    linear_terms    = sizehint!(Dict{Int,T}(), length(f.affine_terms))
    quadratic_terms = sizehint!(Dict{Tuple{Int,Int},T}(), length(f.quadratic_terms))

    for a in f.affine_terms
        c = a.coefficient
        i = a.variable.value

        linear_terms[i] = get(linear_terms, i, zero(T)) + c
    end

    for q in f.quadratic_terms
        c = q.coefficient
        i = q.variable_1.value
        j = q.variable_2.value

        if i == j
            linear_terms[i] = get(linear_terms, i, zero(T)) + c / 2
        elseif i > j
            quadratic_terms[(j, i)] = get(quadratic_terms, (j, i), zero(T)) + c
        else
            quadratic_terms[(i, j)] = get(quadratic_terms, (i, j), zero(T)) + c
        end
    end

    scale  = one(T)
    offset = f.constant

    return (n, linear_terms, quadratic_terms, scale, offset)
end

abstract type CompilerVariableAttribute <: MOI.AbstractVariableAttribute end

@doc raw"""
    VariableEncodingATol()
"""
struct VariableEncodingATol <: CompilerVariableAttribute end

function variable_encoding_atol(model::VirtualModel{T}, vi::VI)::T where {T}
    τ = MOI.get(model, VariableEncodingATol(), vi)

    if τ === nothing
        return MOI.get(model, DefaultVariableEncodingATol())
    else
        return τ
    end
end

function MOI.get(model::VirtualModel{T}, ::VariableEncodingATol, vi::VI)::T where {T}
    attr = :variable_encoding_atol

    if haskey(model.variable_settings, attr)
        return get(model.variable_settings[attr], vi, nothing)
    else
        return nothing
    end
end

function MOI.set(model::VirtualModel{T}, ::VariableEncodingATol, vi::VI, τ::T) where {T}
    attr = :variable_encoding_atol

    if !haskey(model.variable_settings, attr)
        model.variable_settings[attr] = Dict{VI,Any}()
    end

    model.variable_settings[attr][vi] = τ

    return nothing
end

function MOI.set(model::VirtualModel, ::VariableEncodingATol, vi::VI, ::Nothing)
    attr = :variable_encoding_atol

    if haskey(model.variable_settings, attr)
        delete!(model.variable_settings[attr], vi)
    end

    return nothing
end

@doc raw"""
    VariableEncodingBits()
"""
struct VariableEncodingBits <: CompilerVariableAttribute end

function variable_encoding_bits(model::VirtualModel, vi::VI)::Union{Integer,Nothing}
    n = MOI.get(model, VariableEncodingBits(), vi)

    if isnothing(n)
        return MOI.get(model, DefaultVariableEncodingBits())
    else
        return n
    end
end

function MOI.get(
    model::VirtualModel,
    ::VariableEncodingBits,
    vi::VI,
)::Union{Integer,Nothing}
    attr = :variable_encoding_bits

    if haskey(model.variable_settings, attr)
        return get(model.variable_settings[attr], vi, nothing)
    else
        return MOI.get(model, DefaultVariableEncodingBits())
    end
end

function MOI.set(model::VirtualModel, ::VariableEncodingBits, vi::VI, n::Integer)
    attr = :variable_encoding_bits

    if !haskey(model.variable_settings, attr)
        model.variable_settings[attr] = Dict{VI,Any}(vi => n)
    else
        model.variable_settings[attr][vi] = n
    end

    return nothing
end


function MOI.set(model::VirtualModel, ::VariableEncodingBits, vi::VI, ::Nothing)
    attr = :variable_encoding_bits

    if haskey(model.variable_settings, attr)
        delete!(model.variable_settings[attr], vi)

        if isempty(model.variable_settings[attr])
            delete!(model.variable_settings, attr)
        end
    end

    return nothing
end

@doc raw"""
    VariableEncodingMethod()

Available methods are:
- [`Binary`](@ref) (default)
- [`Unary`](@ref)
- [`Arithmetic`](@ref)
- [`OneHot`](@ref)
- [`DomainWall`](@ref)
- [`Bounded`](@ref)

The [`Binary`](@ref), [`Unary`](@ref) and [`Arithmetic`](@ref) encodings can have their
expansion coefficients bounded by parametrizing the [`Bounded`](@ref) encoding.
"""
struct VariableEncodingMethod <: CompilerVariableAttribute end

function variable_encoding_method(model::VirtualModel, vi::VI)::Encoding
    e = MOI.get(model, VariableEncodingMethod(), vi)

    if isnothing(e)
        return MOI.get(model, DefaultVariableEncodingMethod())
    else
        return e
    end
end

function MOI.get(model::VirtualModel, ::VariableEncodingMethod, vi::VI)::Union{Encoding,Nothing}
    attr = :variable_encoding_method

    if !haskey(model.variable_settings, attr) || !haskey(model.variable_settings[attr], vi)
        return nothing
    else
        return model.variable_settings[attr][vi]
    end
end

function MOI.set(model::VirtualModel, ::VariableEncodingMethod, vi::VI, e::Encoding)
    attr = :variable_encoding_method

    if !haskey(model.variable_settings, attr)
        model.variable_settings[attr] = Dict{VI,Any}(vi => e)
    else
        model.variable_settings[attr][vi] = e
    end

    return nothing
end

function MOI.set(model::VirtualModel, ::VariableEncodingMethod, vi::VI, ::Nothing)
    attr = :variable_encoding_method

    if haskey(model.variable_settings, attr)
        delete!(model.variable_settings[attr], vi)

        if isempty(model.variable_settings[attr])
            delete!(model.variable_settings, attr)
        end
    end

    return nothing
end

@doc raw"""
    VariableEncodingPenalty()

Allows the user to set and retrieve the coefficients used for encoding variables when additional
constraints are involved.
"""
struct VariableEncodingPenalty <: CompilerVariableAttribute end

function variable_encoding_penalty(model::VirtualModel, vi::VI)
    return MOI.get(model, VariableEncodingPenalty(), vi)
end

function MOI.get(model::VirtualModel{T}, ::VariableEncodingPenalty, vi::VI) where {T}
    return get(model.θ, vi, nothing)
end

function MOI.set(model::VirtualModel{T}, ::VariableEncodingPenalty, vi::VI, θ::T) where {T}
    model.θ[vi] = θ

    return nothing
end

function MOI.set(
    model::VirtualModel{T},
    ::VariableEncodingPenalty,
    vi::VI,
    ::Nothing,
) where {T}
    delete!(model.θ, vi)

    return nothing
end

abstract type CompilerConstraintAttribute <: MOI.AbstractConstraintAttribute end

MOI.supports(::VirtualModel, ::CompilerConstraintAttribute, ::CI) = true

MOIU.map_indices(::Any, ::CompilerConstraintAttribute, x) = x

@doc raw"""
    ConstraintEncodingPenalty()

Allows the user to set and retrieve the coefficients used for encoding constraints.
"""
struct ConstraintEncodingPenalty <: CompilerConstraintAttribute end

function constraint_encoding_penalty(model::VirtualModel, ci::CI)
    return MOI.get(model, ConstraintEncodingPenalty(), ci)
end

function MOI.get(model::VirtualModel{T}, ::ConstraintEncodingPenalty, ci::CI) where {T}
    return get(model.ρ, ci, nothing)
end

function MOI.set(
    model::VirtualModel{T},
    ::ConstraintEncodingPenalty,
    ci::CI,
    ρ::T,
) where {T}
    model.ρ[ci] = ρ

    return nothing
end

function MOI.set(
    model::VirtualModel{T},
    ::ConstraintEncodingPenalty,
    ci::CI,
    ::Nothing,
) where {T}
    delete!(model.ρ, ci)

    return nothing
end

end # module Attributes
