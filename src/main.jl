include("network_resumable.jl")
using .QuantumNetwork

N = 4; Q = 1024
function p(n_c=0.9, n=N) #Revert to previous formula
    return rand() < (1/2) * n_c^2 * exp(-1 / (n+1))
end

net = QuantumNetwork.Network(N, Q)
QuantumNetwork.simulate!(net)