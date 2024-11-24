import QuantumSavory
import Printf
include("../src/utils/bellstates.jl")
include("../src/noisyops/CircuitZoo.jl")


function prediction(s1::BellState, s2::BellState; ϵ_g::Float64=0.0, ξ=0.0)
    a₁, b₁, c₁, d₁ = s1.a, s1.b, s1.c, s1.d
    a₂, b₂, c₂, d₂ = s2.a, s2.b, s2.c, s2.d
    
    p = (1-ϵ_g)^2 * ((ξ^2 + (1-ξ)^2) * ((a₁+d₁)*(a₂+d₂) + (b₁+c₁)*(b₂+c₂)) + 2ξ*(1-ξ) * ((a₁+d₁)*(b₂+c₂) + (b₁+c₁)*(a₂+d₂))) + 0.5*(1-(1-ϵ_g)^2)
    
    a = (1/p) * ((1-ϵ_g)^2 * (ξ^2 + (1-ξ)^2) * (a₁*a₂ + d₁*d₂) + 2ξ*(1-ξ)*(a₁*c₂ + d₁*b₂)) + 0.125*(1-(1-ϵ_g)^2)
    b = (1/p) * ((1-ϵ_g)^2 * (ξ^2 + (1-ξ)^2) * (a₁*d₂ + d₁*a₂) + 2ξ*(1-ξ)*(a₁*b₂ + d₁*c₂)) + 0.125*(1-(1-ϵ_g)^2)
    c = (1/p) * ((1-ϵ_g)^2 * (ξ^2 + (1-ξ)^2) * (b₁*b₂ + c₁*c₂) + 2ξ*(1-ξ)*(b₁*d₂ + c₁*a₂)) + 0.125*(1-(1-ϵ_g)^2)
    d = (1/p) * ((1-ϵ_g)^2 * (ξ^2 + (1-ξ)^2) * (b₁*c₂ + c₁*b₂) + 2ξ*(1-ξ)*(b₁*a₂ + c₁*d₂)) + 0.125*(1-(1-ϵ_g)^2)
    
    return p, BellState(a, b, c, d)
end


function experimental(s1::BellState, s2::BellState; leaveout, ϵ_g::Float64=0.0, ξ=0.0)
    ρ₁ = s1.a * Φ⁺ + s1.b * Φ⁻ + s1.c * Ψ⁺ + s1.d * Ψ⁻
    ρ₂ = s2.a * Φ⁺ + s2.b * Φ⁻ + s2.c * Ψ⁺ + s2.d * Ψ⁻

    regA = QuantumSavory.Register(2)
    regB = QuantumSavory.Register(2)

    QuantumSavory.initialize!([regA[1], regB[1]], ρ₁)
    QuantumSavory.initialize!([regA[2], regB[2]], ρ₂)

    circuit = Purify2to1(leaveout, ϵ_g, ξ)
    success = circuit(regA[1], regB[1], regA[2], regB[2])

    if success
        println("Success")
        return 1, BellState(regA[1])
    else
        println("Purification failed")
        return -1, -1
    end
end

# function noisystate(F::Float64)
#     remaining = 1.0 - F
#     r = rand(3); r /= sum(r)
#     b, c, d = (1-F)*r
#     return BellState(F, b, c, d)
# end
function noisystate(F::Float64)
    return BellState(F, (1-F)/3, (1-F)/3, (1-F)/3)
end

s1 = noisystate(0.85)
s2 = noisystate(0.85)
leaveout = :Z
ϵ_g = 0.1
ξ = 0.1

p_pred, s_pred = prediction(s1, s2; ϵ_g=ϵ_g, ξ=ξ)
p_exp, s_exp = experimental(s1, s2; leaveout, ϵ_g=ϵ_g, ξ=ξ)

# println(p_pred)
# println(p_exp)

println("   Predicted: ", s_pred)
println("Experimental: ", s_exp)


# bell_states = [
#     BellState(1.0, 0.0, 0.0, 0.0),
#     BellState(0.5, 0.5, 0.0, 0.0),
#     BellState(0.25, 0.25, 0.25, 0.25),
#     BellState(0.1, 0.2, 0.3, 0.4)
# ]

# epsilon_g_values = [0.0, 0.1, 0.2, 0.3]
# xi_values = [0.0, 0.1, 0.2, 0.3]

# for s1 in bell_states
#     for s2 in bell_states
#         for ϵ_g in epsilon_g_values
#             for ξ in xi_values
#                 p_pred, s_pred = prediction(s1, s2; ϵ_g=ϵ_g, ξ=ξ)
#                 p_exp, s_exp = experimental(s1, s2; ϵ_g=ϵ_g, ξ=ξ)

#                 # Clear the previous line and print the current values
#                 @printf("\rTesting: s1=%s, s2=%s, ϵ_g=%.2f, ξ=%.2f", s1, s2, ϵ_g, ξ)

#                 if true #|| p_pred != p_exp
#                     println("\nDiscrepancy found!")
#                     println("Predicted: p_pred=$p_pred, s_pred=$s_pred")
#                     println("Experimental: p_exp=$p_exp, s_exp=$s_exp")
#                 end
#             end
#         end
#     end
# end