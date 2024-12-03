import Random
Random.seed!(22)

include("../src/network.jl")
import .QuantumNetwork

T2 = 1.0
F = 0.949
p_ent = ((n_c=0.9, l0=5, l_att=20) -> (1/2) * n_c^2 * exp(-l0 / l_att))()
ϵ_g = 0.1
ξ = 0.0
t_comms = fill(0.01, 1)     # Not implemented


net = QuantumNetwork.Network(3, 1024; T2, F, p_ent, ϵ_g, ξ, t_comms)

QuantumNetwork.simulate!(net)

println(QuantumNetwork.getFidelity(net))

# display(QuantumNetwork.netplot(net))