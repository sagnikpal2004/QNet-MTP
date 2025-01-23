import Random
Random.seed!(22)

using Logging
global_logger(ConsoleLogger(stdout, Logging.Info))

include("../src/network.jl")
import .QuantumNetwork

n = 1   # Number of segments
q = 256    # Number of qubits

T2 = 0.01   # T2 dephasing time in seconds

n_c = 0.9
l0 = 1000         # Internode distance in metres
L = l0 * n        # Fibre transmission efficiency
l_att = 20000     # Attenuation length in metres
p_ent = 0.5 * n_c^2 * exp(-l0/l_att)   # Entanglement generation probability

ϵ_g = 1e-3          # Gate error rate
ξ = ϵ_g/4           # Measurement error rate
F = 1-(5/4)*(ϵ_g)   # Initial bellpair fidelity

c = 2e8     # Speed of light in m/s
t_comms = fill(l0 / c, n)  # Inter-node communication times

# net = QuantumNetwork.Network(n-1, q; T2, F, p_ent, ϵ_g, ξ, t_comms)
# y, fidelity = QuantumNetwork.simulate!(net)
# println(QuantumNetwork.getFidelity(net))

PLOT = true
PURIFY = false

net_param = QuantumNetwork.NetworkParam(n-1, q; T2, F, p_ent, ϵ_g, ξ, t_comms)
E_Y, SKR = QuantumNetwork.simulate(net_param, 1)
println(E_Y)
