import Random
Random.seed!(22)

using Logging
log_file = open("./logs/simulate.log", "w")
global_logger(SimpleLogger(log_file, Logging.Info))
redirect_stdout(log_file)
redirect_stderr(log_file)

include("../src/network.jl")
import .QuantumNetwork

using DataFrames
using CSV
import Dates
using Base.Threads

file_lock = ReentrantLock()

l0_values = [2^i * 1000 for i in 0:0.25:6]
n_values = [2^i for i in 0:1:10]

q = 256

T2 = 0.01

n_c = 0.9
l_att = 20000

ϵ_g = 1e-3
ξ = ϵ_g/4        
F = 1-(5/4)*(ϵ_g)

c = 2e8

PLOT = false
PURIFY = false


if isfile("./results/results2.csv")
    results_df = CSV.read("./results/results2.csv", DataFrame)
else
    results_df = DataFrame(l0 = Float64[], n = Int[], E_Y = Float64[], SKR = Float64[])
    CSV.write("./results/results2.csv", results_df)
end

function process_combination(l0, n)
    if any(row -> row.l0 == l0 && row.n == n, eachrow(results_df))
        return
    end

    p_ent = 0.5 * n_c^2 * exp(-l0/l_att)
    L = l0 * n
    t_comms = fill(l0 / c, n)

    net_param = QuantumNetwork.NetworkParam(n-1, q; T2, F, p_ent, ϵ_g, ξ, t_comms)
    E_Y, SKR = QuantumNetwork.simulate(net_param, 100)

    @info "l0: $l0, n: $n, E_Y: $E_Y, SKR: $SKR"

    lock(file_lock) do 
        push!(results_df, (l0, n, E_Y, SKR))
        sort!(results_df, [:l0, :n])
        CSV.write("./results/results2.csv", results_df)
    end
end

Threads.@threads for l0 in l0_values
    for n in n_values
        process_combination(l0, n)
    end
end

print(results_df)