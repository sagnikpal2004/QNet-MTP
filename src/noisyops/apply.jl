"""
Apply a given two-qubit operation on the given set of register slots.

`apply!([regA, regB], [slot1, slot2], Gates.CNOT; ϵ_g::Float64)` would apply a CNOT gate
on the content of the given registers at the given slots, or a random bell state is assigned 
with probability ϵ_g. 
The appropriate representation of the gate is used,
depending on the formalism under which a quantum state is stored in the given registers.
The Hilbert spaces of the registers are automatically joined if necessary.
"""
function apply_withnoise!(regs::Vector{Register}, indices::Base.AbstractVecOrTuple{Int}, operation; time=nothing, ϵ_g::Float64)
    regs, max_time = QuantumSavory.apply!(regs, indices, operation; time)

    r = rand()
    if r < 1 - ϵ_g
        nothing
    elseif r < 1 - 3*ϵ_g/4
        regs[1].staterefs[indices[1]].state[] = Φ⁺
    elseif r < 1 - 2*ϵ_g/4
        regs[1].staterefs[indices[1]].state[] = Φ⁻
    elseif r < 1 - ϵ_g/4
        regs[2].staterefs[indices[2]].state[] = Ψ⁺
    else
        regs[1].staterefs[indices[1]].state[] = Ψ⁻
    end

    return regs, max_time
end
apply_withnoise!(refs::Vector{RegRef}, operation; time=nothing, ϵ_g::Float64) = apply_withnoise!([r.reg for r in refs], [r.idx for r in refs], operation; time, ϵ_g)
apply_withnoise!(refs::NTuple{N,RegRef}, operation; time=nothing, ϵ_g::Float64) where {N} = apply_withnoise!([r.reg for r in refs], [r.idx for r in refs], operation; time, ϵ_g)
apply_withnoise!(ref::RegRef, operation; time=nothing, ϵ_g::Float64) = apply_withnoise!([ref.reg], [ref.idx], operation; time, ϵ_g)