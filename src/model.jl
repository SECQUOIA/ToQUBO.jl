# -*- Model: PreQUBOModel -*- #
MOIU.@model(PreQUBOModel,       # Name of model
    (MOI.Integer, MOI.ZeroOne), # untyped scalar sets
    (EQ, LT, GT),               #   typed scalar sets
    (),                         # untyped vector sets
    (),                         #   typed vector sets
    (VI,),                      # untyped scalar functions
    (SAF, SQF),                 #   typed scalar functions
    (),                         # untyped vector functions
    (),                         #   typed vector functions
    false,                      # is optimizer?
)

# :: Drop Automatic Constraint Support :: #
MOI.supports_constraint(
    ::PreQUBOModel{T},
    ::Type{<:Union{SAF, SQF}},
    ::Type{<:Union{MOI.Integer, MOI.ZeroOne, GT}},
) where {T} = false

# -*- Model: QUBOModel -*-
MOIU.@model(QUBOModel,
    (MOI.ZeroOne,),             # untyped scalar sets
    (),                         #   typed scalar sets
    (),                         # untyped vector sets
    (),                         #   typed vector sets
    (VI,),                         # untyped scalar functions
    (SQF,),                     #   typed scalar functions
    (),                         # untyped vector functions
    (),                         #   typed vector functions
    false,                      # is optimizer?
)

# :: Reset Constraint Support :: #
MOI.supports_constraint(
    ::QUBOModel{T},
    ::Type{<:SQF},
    ::Type{<:MOI.ZeroOne},
) where {T} = false

mutable struct VirtualQUBOModelMOI{T}
    objective_value::T
    solve_time_sec::Float64
    termination_status::MOI.TerminationStatusCode
    primal_status::MOI.ResultStatusCode
    dual_status::MOI.ResultStatusCode
    raw_status_string::String

    function VirtualQUBOModelMOI{T}(;
            objective_value::T = zero(T),
            solve_time_sec::Float64 = NaN,
            termination_status::MOI.TerminationStatusCode = MOI.OPTIMIZE_NOT_CALLED,
            primal_status::MOI.ResultStatusCode = MOI.NO_SOLUTION,
            dual_status::MOI.ResultStatusCode = MOI.NO_SOLUTION,
            raw_status_string::String = "",
        ) where {T}

        return new{T}(
            objective_value,
            solve_time_sec,
            termination_status,
            primal_status,
            dual_status,
            raw_status_string,
        )
    end
end

mutable struct VirtualQUBOModelSettings{T}
    Tol::T

    function VirtualQUBOModelSettings{T}(;
        Tol::T = T(1e-6),
        ) where {T}

        return new{T}(
            Tol,
        )
    end
end

function Base.empty!(moi::VirtualQUBOModelMOI{T}) where {T}
    moi.objective_value    = zero(T)
    moi.solve_time_sec     = NaN
    moi.termination_status = MOI.OPTIMIZE_NOT_CALLED
    moi.primal_status      = MOI.NO_SOLUTION
    moi.dual_status        = MOI.NO_SOLUTION
    moi.raw_status_string  = ""

    nothing
end

@doc raw"""
    VirtualQUBOModel{T}(optimizer::Union{Nothing, Type{<:MOI.AbstractOptimizer}} = nothing) where {T}

This QUBO Virtual Model links the final QUBO formulation to the original one, allowing variable value retrieving and other features.
"""
mutable struct VirtualQUBOModel{T} <: AbstractVirtualModel{T}

    # -*- Virtual Model Interface -*-
    source_model::PreQUBOModel{T}
    target_model::QUBOModel{T}
    
    varvec::Vector{VirtualMOIVariable{T}}
    source::Dict{VI, VirtualMOIVariable{T}}
    target::Dict{VI, VirtualMOIVariable{T}}

    # - Underlying Optimizer
    optimizer::Union{Nothing, MOI.AbstractOptimizer}
    
    ℍ::ℱ{T}          # Total Energy
    ℍ₀::ℱ{T}         # Objective
    ℍᵢ::Vector{ℱ{T}} # Constraints

    # -*- MathOptInterface -*-
    moi::VirtualQUBOModelMOI{T}

    # -*- Settings -*-
    settings::VirtualQUBOModelSettings{T}

    function VirtualQUBOModel{T}(optimizer::Union{Nothing, Type{<:MOI.AbstractOptimizer}} = nothing) where {T}

        return new{T}(
            PreQUBOModel{T}(),
            QUBOModel{T}(),

            VirtualMOIVariable{T}[],
            Dict{VI, VirtualMOIVariable{T}}(),
            Dict{VI, VirtualMOIVariable{T}}(),
            
            isnothing(optimizer) ? nothing : optimizer(),

            ℱ{T}(),
            ℱ{T}(),
            ℱ{T}[],
            
            VirtualQUBOModelMOI{T}(),
            VirtualQUBOModelSettings{T}(),
        )
    end

    function VirtualQUBOModel(optimizer::Union{Nothing, Type{<:MOI.AbstractOptimizer}} = nothing)
        return VirtualQUBOModel{Float64}(optimizer)
    end
end

struct Tol <: MOI.AbstractOptimizerAttribute end

function MOI.get(model::VirtualQUBOModel{T}, ::Tol) where {T}
    return model.settings.Tol::T
end

function MOI.set(model::VirtualQUBOModel{T}, ::Tol, Tol::T) where {T}
    if Tol <= zero(T)
        throw(DomainError(Tol, "Tolerance value `tol` must be positive."))
    end

    model.settings.Tol = Tol

    nothing
end