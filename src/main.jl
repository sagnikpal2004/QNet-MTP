using QuantumSavory.CircuitZoo: EntanglementSwap
include("network.jl")

Q = 1024
PLOT = "FINAL"    # "OFF", "ON", "VERBOSE", "FINAL"
savetofile = false

p = (n_c=0.9, l_0=5, l_aH=20) -> rand() < (1/2) * n_c^2 * exp(-l_0 / l_aH)


net = Network(3, Q)
if PLOT == "ON" || PLOT == "VERBOSE"
    netplot!(net, savetofile)
end

successQubitsS1::Vector{Bool} = []
successQubitsS2::Vector{Bool} = []
successQubitsS3::Vector{Bool} = []
successQubitsS4::Vector{Bool} = []


# Segment 1
for q in 1:Q
    if p()
        push!(successQubitsS1, true)
        apply!([net.Alice[q], net.Repeaters[1][1][q]], CNOT)

        if PLOT == "VERBOSE"
            netplot!(net, savetofile)
        end
    else
        push!(successQubitsS1, false)
    end
end

if PLOT == "ON"
    netplot!(net, savetofile)
end

# Segment 2
for q in 1:Q
    if p()
        push!(successQubitsS2, true)
        apply!([net.Repeaters[1][2][q], net.Repeaters[2][1][q]], CNOT) 

        if PLOT == "VERBOSE"
            netplot!(net, savetofile)
        end
    else
        push!(successQubitsS2, false)
    end
end

if PLOT == "ON"
    netplot!(net, savetofile)
end

# Segment 3
for q in 1:Q
    if p()
        push!(successQubitsS3, true)
        apply!([net.Repeaters[2][2][q], net.Repeaters[3][1][q]], CNOT) 
        
        if PLOT == "VERBOSE"
            netplot!(net, savetofile)
        end
    else
        push!(successQubitsS3, false)
    end
end

if PLOT == "ON"
    netplot!(net, savetofile)
end

# Segment 4
for q in 1:Q
    if p()
        push!(successQubitsS4, true)
        apply!([net.Repeaters[3][2][q], net.Bob[q]], CNOT) 
        
        if PLOT == "VERBOSE"
            netplot!(net, savetofile)
        end
    else
        push!(successQubitsS4, false)
    end
end

if PLOT == "ON"
    netplot!(net, savetofile)
end


swapcircuit = EntanglementSwap()

AliceR2_qubitPairs::Vector{Tuple{Int, Int}} = []
R2Bob_qubitPairs::Vector{Tuple{Int, Int}} = []

## TODO: Count the number of swaps test

# Repeater 1
qL = 1
qR = 1
while qL <= Q && qR <= Q
    if successQubitsS1[qL] && successQubitsS2[qR]
        swapcircuit(net.Repeaters[1][1][qL], net.Alice[qL], net.Repeaters[1][2][qR], net.Repeaters[2][1][qR])
        push!(AliceR2_qubitPairs, (qL, qR))

        if PLOT == "VERBOSE"
            # print("Swapping qubits $qL and $qR\n")
            netplot!(net, savetofile)
        end

        global qL += 1
        global qR += 1
    elseif !successQubitsS1[qL]
        global qL += 1
    elseif !successQubitsS2[qR]
        global qR += 1
    end
end

if PLOT == "ON"
    netplot!(net, savetofile)
end

# Repeater 3
qL = 1
qR = 1
while qL <= Q && qR <= Q
    if successQubitsS3[qL] && successQubitsS4[qR]
        swapcircuit(net.Repeaters[3][1][qL], net.Repeaters[2][2][qL], net.Repeaters[3][2][qR], net.Bob[qR])
        push!(R2Bob_qubitPairs, (qL, qR))

        if PLOT == "VERBOSE"
            # print("Swapping qubits $qL and $qR\n")
            netplot!(net, savetofile)
        end

        global qL += 1
        global qR += 1
    elseif !successQubitsS3[qL]
        global qL += 1
    elseif !successQubitsS4[qR]
        global qR += 1
    end
end

if PLOT == "ON"
    netplot!(net, savetofile)
end

# Repeater 2
while !isempty(AliceR2_qubitPairs) && !isempty(R2Bob_qubitPairs)
    qL_remote, qL = popfirst!(AliceR2_qubitPairs)
    qR, qR_remote = popfirst!(R2Bob_qubitPairs)

    swapcircuit(net.Repeaters[2][1][qL], net.Alice[qL_remote], net.Repeaters[2][2][qR], net.Bob[qR])

    if PLOT == "VERBOSE"
        # print("Swapping qubits $qL and $qR\n")
        netplot!(net, savetofile)
    end
end

if PLOT == "ON"
    netplot!(net, savetofile)
end

if PLOT == "FINAL"
    netplot!(net, savetofile)
end


## TODO:
# Make the code modular

# Do the same simulation many times: 10000 shots
# Metrics: Average fidelity
# Metrics: Average number of bell pairs that can be developed
# [Later] Metrics: Memory decoherence
# Look at secret key in paper: Appendix A

# Data to look at
# Timestep0 = Bell pairs
# Timestep1 = First class of making entanglement swaps
# Timestep2 = Second class of making entanglement swaps
# and so on


# Do distillation at Level 1 
# for a particular run of this, we will supply DEJMPS at different places
# Time table - 
# Fidelity table
# Number of bell pairs table in different levels and segments for different shots