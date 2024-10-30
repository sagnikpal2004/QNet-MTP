include("network.jl")
using .QuantumNetwork

function p_ent(n_c=0.9, l0=5, l_att=20)
    return rand() < (1/2) * n_c^2 * exp(-l0 / l_att)
end
init_fidelity = 0.97

net = QuantumNetwork.Network(3, 1024)
QuantumNetwork.simulate!(net; F=init_fidelity, p_ent=p_ent)


QuantumNetwork.netplot(net)

println(QuantumNetwork.getFidelity(net))
println(QuantumNetwork.getSecretKeyRate(net))