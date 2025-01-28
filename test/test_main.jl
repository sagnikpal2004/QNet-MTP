# import Random
# Random.seed!(22)

using Logging
global_logger(ConsoleLogger(stdout, Logging.Info))
# global_logger(NullLogger())

import QuantumNetwork

n = 512   # Number of segments
q = 1024    # Number of qubits

T2 = 1.0   # T2 dephasing time in seconds

n_c = 0.3
L = 10^4 * 1000        
l0 = L / n         # Internode distance in metres
l_att = 20000     # Attenuation length in metres
p_ent = 0.5 * n_c^2 * exp(-l0/l_att)   # Entanglement generation probability

ϵ_g = 0.0001          # Gate error rate
ξ = 0.25ϵ_g          # Measurement error rate
F = 1 - 1.25ϵ_g   # Initial bellpair fidelity

c = 2e8     # Speed of light in m/s
t_comms = fill(l0 / c, n)  # Inter-node communication times

# net = QuantumNetwork.Network(n-1, q; T2, F, p_ent, ϵ_g, ξ, t_comms)
# y, fidelity = QuantumNetwork.simulate!(net)
# println(QuantumNetwork.getFidelity(net))

PLOT = false
PURIFY = true

net_param = QuantumNetwork.NetworkParam(n-1, q; T2, F, p_ent, ϵ_g, ξ, t_comms)
# @time begin
    E_Y, SKR = QuantumNetwork.simulate(net_param, 1)
# end
println("SKR: $SKR")
