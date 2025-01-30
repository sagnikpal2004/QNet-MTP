import Random
Random.seed!(22)

using Logging
global_logger(NullLogger())
# global_logger(ConsoleLogger(stdout, Logging.Info))

import QuantumNetwork

using DataFrames
using CSV


L_values = [10^i * 1000 for i in 1:0.25:4]
n_values = [2^i for i in 1:1:9]
η_c_values = [1.0, 0.9, 0.5, 0.3]
ϵ_g_values = [0.0001, 0.001]

q = 1024
T2 = 1.0

l_att = 20000
c = 2e8

PLOT = false
PURIFY = true

# Check if the file exists
if isfile("./results/results3.csv")
    results_df = CSV.read("./results/results3.csv", DataFrame)
else
    # Create a new DataFrame if the file does not exist
    results_df = DataFrame(L = Float64[], n = Int[], η_c = Float64[], ϵ_g = Float64[], E_Y = Float64[], SKR = Float64[])
    CSV.write("./results/results3.csv", results_df)
end

for η_c in η_c_values
    for ϵ_g in ϵ_g_values
        for n in n_values
            for L in L_values
                if any(row -> row.L == L && row.n == n && row.η_c == η_c && row.ϵ_g == ϵ_g, eachrow(results_df))
                    continue
                end

                if ϵ_g == 0.001 && n > 129
                    continue
                end
                
                l0 = L / n
                p_ent = 0.5 * η_c^2 * exp(-l0/l_att)
                t_comms = fill(l0 / c, n)
                ξ = ϵ_g/4        
                F = 1-(5/4)*(ϵ_g)

                net_param = QuantumNetwork.NetworkParam(n-1, q; T2, F, p_ent, ϵ_g, ξ, t_comms)
                E_Y, SKR = QuantumNetwork.simulate(net_param, 100)

                println("L: $L, n: $n, η_c: $η_c, ϵ_g: $ϵ_g, E_Y: $E_Y, SKR: $SKR")
                push!(results_df, (L, n, η_c, ϵ_g, E_Y, SKR))
                sort!(results_df, [:L, :n, :η_c, :ϵ_g])
                CSV.write("./simulate/results/results3.csv", results_df)
            end
        end
    end
end

print(results_df)