include("network.jl")
using .QuantumNetwork
using CairoMakie

function p_ent(n_c, l0, l_att=20)
    return () -> rand() < (1/2) * n_c^2 * exp(-l0 / l_att)
end

net = QuantumNetwork.Network(3, 1024, 100.0)
secretKeyRate = QuantumNetwork.simulate!(net, p_ent(0.9, 5))
println("Secret Key Rate: ", secretKeyRate)