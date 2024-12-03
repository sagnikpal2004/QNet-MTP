import QuantumSavory
include("../src/utils/bellstates.jl")
include("../src/noisyops/CircuitZoo.jl")

function prediction(s1::BellState, s2::BellState; ϵ_g::Float64=0.0, ξ=0.0)
    a₁, b₁, c₁, d₁ = s1.a, s1.b, s1.c, s1.d
    a₂, b₂, c₂, d₂ = s2.a, s2.b, s2.c, s2.d

    a = (1-ϵ_g) * ((1-ϵ_g)^2 * (a₁*a₂ + b₁*b₂ + c₁*c₂ + d₁*d₂) + ξ*(1-ξ)*((a₁+d₁)*(b₂+c₂) + (b₁+c₁)*(a₂+d₂)) + ξ^2*(a₁*d₂ + d₁*a₂ + b₁*c₂ + c₁*b₂)) + ϵ_g/4
    b = (1-ϵ_g) * ((1-ϵ_g)^2 * (a₁*b₂ + b₁*a₂ + c₁*d₂ + d₁*c₂) + ξ*(1-ξ)*((a₁+d₁)*(a₂+d₂) + (b₁+c₁)*(b₂+c₂)) + ξ^2*(a₁*c₂ + c₁*a₂ + b₁*d₂ + d₁*b₂)) + ϵ_g/4
    c = (1-ϵ_g) * ((1-ϵ_g)^2 * (a₁*c₂ + c₁*a₂ + b₁*d₂ + d₁*b₂) + ξ*(1-ξ)*((a₁+d₁)*(a₂+d₂) + (b₁+c₁)*(b₂+c₂)) + ξ^2*(a₁*b₂ + b₁*a₂ + c₁*d₂ + d₁*c₂)) + ϵ_g/4
    d = (1-ϵ_g) * ((1-ϵ_g)^2 * (a₁*d₂ + d₁*a₂ + c₁*b₂ + b₁*c₂) + ξ*(1-ξ)*((a₁+d₁)*(b₂+c₂) + (b₁+c₁)*(a₂+d₂)) + ξ^2*(a₁*a₂ + b₁*b₂ + c₁*c₂ + d₁*d₂)) + ϵ_g/4
    
    return BellState(a, b, c, d)
end

function experimental(s1::BellState, s2::BellState; ϵ_g::Float64=0.0, ξ=0.0)
    ρ₁ = s1.a * Φ⁺ + s1.b * Φ⁻ + s1.c * Ψ⁺ + s1.d * Ψ⁻
    ρ₂ = s2.a * Φ⁺ + s2.b * Φ⁻ + s2.c * Ψ⁺ + s2.d * Ψ⁻

    regA = QuantumSavory.Register(1)
    regB = QuantumSavory.Register(2)
    regC = QuantumSavory.Register(1)

    QuantumSavory.initialize!([regA[1], regB[1]], ρ₁)
    QuantumSavory.initialize!([regB[2], regC[1]], ρ₂)

    circuit = EntanglementSwap(ϵ_g, ξ)
    circuit(regB[1], regA[1], regB[2], regC[1])

    state = regA.staterefs[1].state[]
    return BellState(state)
end

function noisystate(F::Float64)
    return BellState(F, (1-F)/3, (1-F)/3, (1-F)/3)
end

s1 = noisystate(0.93)
s2 = noisystate(0.94)
ϵ_g = 1.1e-3
ξ = 1e-3

p_pred = prediction(s1, s2; ϵ_g, ξ)
p_exp = experimental(s1, s2; ϵ_g, ξ)

println("Testing ent_swap with:   ϵ_g=", ϵ_g, ",   ξ=", ξ)
println("Predicted state:    ", p_pred)
println("Experimental state: ", p_exp)
# println(p_pred ≈ p_exp)