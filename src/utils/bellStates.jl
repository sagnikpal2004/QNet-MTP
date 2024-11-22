import QuantumInterface
import QuantumOptics

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