include("network.jl")
using .QuantumNetwork

N = 4; Q = 1024
function p(n_c=0.9, l0=5, l_att=20)
    return rand() < (1/2) * n_c^2 * exp(-l0 / l_att)
end


fullData::Vector{Vector{Int}} = []

function simulateOnce()
    data::Vector{Int} = []

    net = QuantumNetwork.Network(N, Q)
    QuantumNetwork.initialize!(net)
    QuantumNetwork.entangle!(net, p)
    push!(data, length(net.ent_list)/2)

    QuantumNetwork.ent_swap!(net, 1)
    QuantumNetwork.ent_swap!(net, 3)
    push!(data, length(net.ent_list)/2)

    QuantumNetwork.ent_swap!(net, 2)
    push!(data, length(net.ent_list)/2)


    # QuantumNetwork.netplot(net)
    push!(fullData, data)
end

for i in 1:10000
    simulateOnce()
end

println(fullData)
using CSV
CSV.write("data.csv", fullData)


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