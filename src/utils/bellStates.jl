import QuantumInterface
import QuantumOptics
import Printf

basis1 = QuantumInterface.SpinBasis(1//2)
basis2 = QuantumOptics.:⊗(basis1, basis1)

ϕ⁺ = QuantumOptics.Ket(basis2, [1.0+0.0im, 0.0+0.0im, 0.0+0.0im, 1.0+0.0im] / sqrt(2))
ϕ⁻ = QuantumOptics.Ket(basis2, [1.0+0.0im, 0.0+0.0im, 0.0+0.0im, -1.0+0.0im] / sqrt(2))
ψ⁺ = QuantumOptics.Ket(basis2, [0.0+0.0im, 1.0+0.0im, 1.0+0.0im, 0.0+0.0im] / sqrt(2))
ψ⁻ = QuantumOptics.Ket(basis2, [0.0+0.0im, 1.0+0.0im, -1.0+0.0im, 0.0+0.0im] / sqrt(2))

Φ⁺ = QuantumInterface.dm(ϕ⁺)
Φ⁻ = QuantumInterface.dm(ϕ⁻)
Ψ⁺ = QuantumInterface.dm(ψ⁺)
Ψ⁻ = QuantumInterface.dm(ψ⁻)

struct BellState
    a::Float64
    b::Float64
    c::Float64
    d::Float64

    function BellState(a::Float64, b::Float64, c::Float64, d::Float64)
        # @assert a + b + c + d ≈ 1.0 "State must be normalized"
        return new(a, b, c, d)
    end
end
function BellState(state::QuantumOptics.Operator)
    @assert QuantumOptics.basis(state) == basis2 "State must be in basis2"

    a = real(ϕ⁺' * state * ϕ⁺)
    b = real(ϕ⁻' * state * ϕ⁻)
    c = real(ψ⁺' * state * ψ⁺)
    d = real(ψ⁻' * state * ψ⁻)
    return BellState(a, b, c, d)
end
BellState(state::QuantumOptics.Ket) = BellState(QuantumInterface.dm(state))
BellState(ref::QuantumSavory.RegRef) = BellState(ref.reg.staterefs[ref.idx].state[])

Base.isapprox(s1::BellState, s2::BellState; atol=1e-8) = all(isapprox(getfield(s1, f), getfield(s2, f); atol=atol) for f in fieldnames(BellState))
Base.show(io::IO, bs::BellState) = Printf.@printf(io, "BellState(%.8f, %.8f, %.8f, %.8f)", bs.a, bs.b, bs.c, bs.d)
