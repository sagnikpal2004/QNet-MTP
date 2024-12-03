import QuantumSavory
import Printf
include("../src/utils/bellstates.jl")
include("../src/noisyops/CircuitZoo.jl")


function prediction(s1::BellState, s2::BellState; ϵ_g::Float64=0.0, ξ::Float64=0.0)
    a1, b1, c1, d1 = s1.a, s1.b, s1.c, s1.d
    a2, b2, c2, d2 = s2.a, s2.b, s2.c, s2.d

    p_succ = ((1 - ϵ_g)^2) * ((ξ^2 + (1 - ξ)^2) * (((a1 + d1) * (a2 + d2)) + ((b1 + c1) * (b2 + c2)))) + 2 * ξ * (1 - ξ) * (((a1 + d1) * (b2 + c2)) + ((b1 + c1) * (a2 + d2))) + ((1 - (1 - ϵ_g)^2) / 2)
    p1_new = ((1 / p_succ) * (((1 - ϵ_g)^2) * (((ξ^2 + (1 - ξ)^2) * ((a1 * a2) + (d1 * d2)))) + 2 * ξ * (1 - ξ) * ((a1 * c2) + (d1 * b2)))) + ((1 - (1 - ϵ_g)^2) / 8)
    p2_new = ((1 / p_succ) * (((1 - ϵ_g)^2) * (((ξ^2 + (1 - ξ)^2) * ((a1 * d2) + (d1 * a2)))) + 2 * ξ * (1 - ξ) * ((a1 * b2) + (d1 * c2)))) + ((1 - (1 - ϵ_g)^2) / 8)
    p3_new = ((1 / p_succ) * (((1 - ϵ_g)^2) * (((ξ^2 + (1 - ξ)^2) * ((b1 * b2) + (c1 * c2)))) + 2 * ξ * (1 - ξ) * ((b1 * d2) + (c1 * a2)))) + ((1 - (1 - ϵ_g)^2) / 8)
    p4_new = ((1 / p_succ) * (((1 - ϵ_g)^2) * (((ξ^2 + (1 - ξ)^2) * ((b1 * c2) + (c1 * b2)))) + 2 * ξ * (1 - ξ) * ((b1 * a2) + (c1 * d2)))) + ((1 - (1 - ϵ_g)^2) / 8)
    p_succ_new = ((1 - ϵ_g)^2) * ((ξ^2 + (1 - ξ)^2) * (((a1 + d1) * (a2 + d2)) + ((b1 + c1) * (b2 + c2)))) + 2 * ξ * (1 - ξ) * (((a1 + d1) * (b2 + c2)) + ((b1 + c1) * (a2 + d2))) + ((1 - (1 - ϵ_g)^2) / 2)
    
    return p_succ_new, BellState(p1_new, p2_new, p3_new, p4_new)
end


function experimental(s1::BellState, s2::BellState; leaveout, ϵ_g::Float64=0.0, ξ=0.0)
    ρ₁ = s1.a * Φ⁺ + s1.b * Φ⁻ + s1.c * Ψ⁺ + s1.d * Ψ⁻
    ρ₂ = s2.a * Φ⁺ + s2.b * Φ⁻ + s2.c * Ψ⁺ + s2.d * Ψ⁻

    circuit = Purify2to1(leaveout, ϵ_g, ξ)

    success_count = 0
    final_bellstate = nothing
    shots = 1000

    for i in 1:shots
        regA = QuantumSavory.Register(2)
        regB = QuantumSavory.Register(2)
        QuantumSavory.initialize!([regA[1], regB[1]], ρ₁)
        QuantumSavory.initialize!([regA[2], regB[2]], ρ₂)

        success = circuit(regA[1], regB[1], regA[2], regB[2])

        if success
            success_count += 1
            if isnothing(final_bellstate)
                final_bellstate = BellState(regA[1])
            end
        end
    end

    return success_count / shots, final_bellstate
end


function noisystate(F::Float64)
    return BellState(F, (1-F)/3, (1-F)/3, (1-F)/3)
end
s1 = noisystate(0.94)
s2 = noisystate(0.94)

leaveout = :Z
ϵ_g = 0.5e-3
ξ = 2e-3

p_pred, s_pred = prediction(s1, s2; ϵ_g=ϵ_g, ξ=ξ)
p_exp, s_exp = experimental(s1, s2; leaveout, ϵ_g=ϵ_g, ξ=ξ)

println("   Predicted: ", s_pred, "   ",  p_pred)
println("Experimental: ", s_exp, "   ", p_exp)
