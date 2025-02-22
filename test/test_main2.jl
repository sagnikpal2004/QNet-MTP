using Random
using Logging
global_logger(ConsoleLogger(stdout, Logging.Info))
# global_logger(NullLogger())

include("../src/QuantumNetwork.jl")
import .QuantumNetwork

n = 128   # Number of segments
q = 1024    # Number of qubits

T2 = 1.0   # T2 dephasing time in seconds

η_c = 0.3
L = 10^2 * 1000    # Total network distance in metres    
l0 = L / n         # Internode distance in metres
l_att = 20000     # Attenuation length in metres
p_ent = 0.5 * η_c^2 * exp(-l0/l_att)   # Entanglement generation probability

ϵ_g = 0.001          # Gate error rate
ξ = 0.25ϵ_g          # Measurement error rate
F = 1 - 1.25ϵ_g   # Initial bellpair fidelity

c = 2e8     # Speed of light in m/s
t_comms = fill(l0 / c, n)  # Inter-node communication times

PLOT = false
PURIFY = true

net_param = QuantumNetwork.NetworkParam(n-1, q; T2, F, p_ent, ϵ_g, ξ, t_comms)
network = QuantumNetwork.Network(net_param; rng=Xoshiro(1))
y, (Q_x, Q_z) = QuantumNetwork.simulate!(network)

println("y: $y")
println("Q_x: $Q_x")
println("Q_z: $Q_z")
