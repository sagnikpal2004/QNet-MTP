include("network.jl")
using .QuantumNetwork


T2 = 10.0   # Not implemented
p_ent = ((n_c=0.9, l0=5, l_att=20) -> (1/2) * n_c^2 * exp(-l0 / l_att))()
F = 0.97
ϵ_g = 0.1
ξ = 0.1

net = QuantumNetwork.Network(3, 1024; T2, p_ent, F, ϵ_g, ξ)

QuantumNetwork.simulate!(net)
QuantumNetwork.netplot(net)

println(QuantumNetwork.getFidelity(net))
println(QuantumNetwork.getSecretKeyRate(net))