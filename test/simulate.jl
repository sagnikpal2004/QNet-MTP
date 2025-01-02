import Random
Random.seed!(22)

import Logging
global_logger(NullLogger())

include("../src/network.jl")
import .QuantumNetwork

using DataFrames
using CSV

l0_values = [2^i * 1000 for i in 0:0.25:6]
n_values = [2^i for i in 0:1:10]

q = 128

T2 = 0.01

n_c = 0.9
l_att = 20000

ϵ_g = 1e-3
ξ = ϵ_g/4        
F = 1-(5/4)*(ϵ_g)

c = 2e8

PLOT = false
PURIFY = false

results_df = DataFrame(l0 = Int[], n = Int[], E_Y = Float64[], SKR = Float64[])

for l0 in l0_values
    p_ent = 0.5 * n_c^2 * exp(-l0/l_att)

    for n in n_values
        L = l0 * n
        t_comms = fill(l0 / c, n)

        net_param = QuantumNetwork.NetworkParam(n-1, q; T2, F, p_ent, ϵ_g, ξ, t_comms)
        E_Y, SKR = QuantumNetwork.simulate(net_param, 1000)

        println("l0: $l0, n: $n, E_Y: $E_Y, SKR: $SKR")
        push!(results_df, (l0, n, E_Y, SKR))
        CSV.write("results.csv", results_df)
    end
end

print(results_df)