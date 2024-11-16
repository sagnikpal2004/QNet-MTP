using QuantumInterface
using QuantumOptics

basis1 = QuantumInterface.SpinBasis(1//2)
basis2 = basis1 ⊗ basis1

Φ⁺ = QuantumOptics.Ket(basis2, [1.0 + 0.0im, 0.0 + 0.0im, 0.0 + 0.0im, 1.0 + 0.0im] / sqrt(2))
Φ⁻ = QuantumOptics.Ket(basis2, [1.0 + 0.0im, 0.0 + 0.0im, 0.0 + 0.0im, -1.0 + 0.0im] / sqrt(2))
Ψ⁺ = QuantumOptics.Ket(basis2, [0.0 + 0.0im, 1.0 + 0.0im, 1.0 + 0.0im, 0.0 + 0.0im] / sqrt(2))
Ψ⁻ = QuantumOptics.Ket(basis2, [0.0 + 0.0im, 1.0 + 0.0im, -1.0 + 0.0im, 0.0 + 0.0im] / sqrt(2))