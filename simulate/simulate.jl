using Distributed
using ClusterManagers
addprocs(SlurmManager(1024), time="1:00:00", mem="16G")


@everywhere function run_simulation(L::Float64, n::Int64, η_c::Float64, ϵ_g::Float64)
    using QuantumNetwork

    using Random
    Random.seed!(22)
    
    l0 = L / n
    p_ent = 0.5 * η_c^2 * exp(-l0/l_att)
    t_comms = fill(l0 / c, n)
    ξ = ϵ_g/4        
    F = 1-(5/4)*(ϵ_g)
    
    net_param = QuantumNetwork.NetworkParam(n-1, q; T2, F, p_ent, ϵ_g, ξ, t_comms)
    E_Y, SKR = QuantumNetwork.simulate(net_param, 100)
    

    using SQLite
    db = SQLite.DB("./simulate/results/results3.db")

    SQLite.execute(db, """
        INSERT INTO results (L, n, η_c, ϵ_g, E_Y, SKR) 
        VALUES ($L, $n, $η_c, $ϵ_g, $E_Y, $SKR)
    """)

    SQLite.close(db)
end


using SQLite
db = SQLite.DB("./simulate/results/results3.db")

SQLite.execute(db, """
    CREATE TABLE IF NOT EXISTS results (
        L REAL,
        n INTEGER,
        η_c REAL,
        ϵ_g REAL,
        E_Y REAL,
        SKR REAL
    )
""")


L_values = [10^i * 1000 for i in 1:0.25:4]
n_values = [2^i for i in 1:1:9]
η_c_values = [1.0, 0.9, 0.5, 0.3]
ϵ_g_values = [0.0001, 0.001]

for η_c in η_c_values
    for ϵ_g in ϵ_g_values
        for n in n_values
            for L in L_values
                if SQLite.query(db, "SELECT COUNT(*) FROM results WHERE L = $L AND n = $n AND η_c = $η_c AND ϵ_g = $ϵ_g")[1][1] > 0
                    continue
                end

                if ϵ_g == 0.001 && n > 129
                    continue
                end

                w = workers()[rand(1:end)]
                @spawnat w run_simulation(L, n, η_c, ϵ_g)                
            end
        end
    end
end

SQLite.close(db)