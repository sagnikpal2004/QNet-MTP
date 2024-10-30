"""Returns a random state in the given basis"""
function noiseState(b::Basis)
    return normalize(QuantumOptics.Ket(b, randn(Complex{Float64}, length(b))))
end

"""
Apply a given operation on the given set of register slots.

`apply!([regA, regB], [slot1, slot2], Gates.CNOT; ϵ_g::Float64)` would apply a CNOT gate
on the content of the given registers at the given slots, or a random state is assigned 
with probability ϵ_g. 
The appropriate representation of the gate is used,
depending on the formalism under which a quantum state is stored in the given registers.
The Hilbert spaces of the registers are automatically joined if necessary.
"""
function apply_withnoise!(regs::Vector{Register}, indices::Base.AbstractVecOrTuple{Int}, operation; time=nothing, ϵ_g::Float64)
    regs, max_time = QuantumSavory.apply!(regs, indices, operation; time)

    if rand() < ϵ_g
        basis = regs[1].staterefs[1].state[].basis
        regs[1].staterefs[1].state[] = noiseState(basis)
    end

    return regs, max_time
end
apply_withnoise!(refs::Vector{RegRef}, operation; time=nothing, ϵ_g::Float64) = apply_withnoise!([r.reg for r in refs], [r.idx for r in refs], operation; time, ϵ_g)
apply_withnoise!(refs::NTuple{N,RegRef}, operation; time=nothing, ϵ_g::Float64) where {N} = apply_withnoise!([r.reg for r in refs], [r.idx for r in refs], operation; time, ϵ_g)
apply_withnoise!(ref::RegRef, operation; time=nothing, ϵ_g::Float64) = apply_withnoise!([ref.reg], [ref.idx], operation; time, ϵ_g)
