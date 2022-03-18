# -*- Annealers -*-
abstract type AbstractAnnealer{T <: Any} <: AbstractSampler{T} end
abstract type AbstractAnnealerSettings{T} <: AbstractSamplerSettings{T} end

const AnnealingResults = SamplingResults

sample(annealer::AbstractAnnealer) = anneal(annealer)

const AnnealerMOI{T} = SamplerMOI{T}

macro anew_annealer(expr)
    return __anew(:Annealer, expr)
end