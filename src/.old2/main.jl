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