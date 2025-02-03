if length(ARGS) != 4
    println("Usage: julia simulate/simulate.jl <L> <n> <η_c> <ϵ_g>")
    exit(1)
end

L = parse(Float64, ARGS[1])
n = parse(Int64, ARGS[2])
η_c = parse(Float64, ARGS[3])
ϵ_g = parse(Float64, ARGS[4])


using Random
Random.seed!(22)

using QuantumNetwork

q = 1024
T2 = 1.0
c = 2e8
l0 = L / n
l_att = 20000
p_ent = 0.5 * η_c^2 * exp(-l0/l_att)
t_comms = fill(l0 / c, n)
ξ = ϵ_g/4        
F = 1-(5/4)*(ϵ_g)

PLOT = false
PURIFY = true

net_param = QuantumNetwork.NetworkParam(n-1, q; T2, F, p_ent, ϵ_g, ξ, t_comms)
E_Y, SKR = QuantumNetwork.simulate(net_param, 100)


using SQLite
db = SQLite.DB("./simulate/results/results3.db")

SQLite.execute(db, """
    INSERT INTO "QNet-MTP" (L, n, η_c, ϵ_g, E_Y, SKR) 
    VALUES ($L, $n, $η_c, $ϵ_g, $E_Y, $SKR)
""")

SQLite.close(db)