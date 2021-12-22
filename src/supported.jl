# Objective Support
function supported_objective(model::MOI.ModelLike)
    F = MOI.get(model, MOI.ObjectiveFunctionType())
    if !__supported_objective(F)
        error("Objective functions of type ", F, " are not implemented")
    end
    return
end

__supported_objective(::Type) = false
__supported_objective(::Type{<: VI}) = true
__supported_objective(::Type{<: SAF{T}}) where {T} = true
__supported_objective(::Type{<: SQF{T}}) where {T} = true

# Constraint Support
function supported_constraints(model::MOIU.Model{T}) where T
    for (F, S) in MOI.get(model, MOI.ListOfConstraints())
        if !__supported_constraint(F, S)
            error(
                "Constraints of function ",
                F,
                " in the Set ",
                S,
                " are not implemented",
            )
        end
    end
    return
end

__supported_constraint(::Type, ::Type) = false
__supported_constraint(::Type{<: VI}, ::Type{<: ZO}) = true
__supported_constraint(::Type{<: SAF{T}}, ::Type{<: EQ{T}}) where T = true
__supported_constraint(::Type{<: SAF{T}}, ::Type{<: LT{T}}) where T = true
__supported_constraint(::Type{<: SAF{T}}, ::Type{<: GT{T}}) where T = true