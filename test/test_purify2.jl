function experimental1(s1::BellState, s2::BellState; leaveout)
    ρ₁ = s1.a * Φ⁺ + s1.b * Φ⁻ + s1.c * Ψ⁺ + s1.d * Ψ⁻
    ρ₂ = s2.a * Φ⁺ + s2.b * Φ⁻ + s2.c * Ψ⁺ + s2.d * Ψ⁻

    circuit = QuantumSavory.CircuitZoo.Purify2to1(leaveout)

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

function experimental2(s1::BellState, s2::BellState; leaveout)
    ρ₁ = s1.a * Φ⁺ + s1.b * Φ⁻ + s1.c * Ψ⁺ + s1.d * Ψ⁻
    ρ₂ = s2.a * Φ⁺ + s2.b * Φ⁻ + s2.c * Ψ⁺ + s2.d * Ψ⁻

    circuit = Purify2to1(leaveout, 0.0, 0.0)

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
s1 = noisystate(0.82)
s2 = noisystate(0.9)

leaveout = :X

p_exp1, s_exp1 = experimental1(s1, s2; leaveout)
p_exp2, s_exp2 = experimental2(s1, s2; leaveout)

println("Experimental1: ", s_exp1, "   ", p_exp1)
println("Experimental2: ", s_exp2, "   ", p_exp2)