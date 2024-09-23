include("network.jl")
using .QuantumNetwork

N = 3; Q = 1024
function p(n_c=0.9, n=N)
    return rand() < (1/2) * n_c^2 * exp(-1 / (n+1))
end

net = QuantumNetwork.Network(N, Q)
QuantumNetwork.initialize!(net)
QuantumNetwork.entangle!(net, p)

QuantumNetwork.netplot(net)

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