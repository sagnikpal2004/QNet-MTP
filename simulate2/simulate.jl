if length(ARGS) != 2
    println("Usage: julia simulate2/simulate.jl <η_c> <ϵ_g>")
    exit(1)
end

η_c = parse(Float64, ARGS[1])
ϵ_g = parse(Float64, ARGS[2])

using Random
using Logging
global_logger(NullLogger())

using QuantumNetwork

q = 1024
T2 = 1.0
c = 2e8
l_att = 20000

ξ = 0.25ϵ_g
F = 1 - 1.25ϵ_g

PLOT = false
PURIFY = true

L_values = vcat(
    10:10:90,
    100:50:1950,
    2000:100:10000
)
n_values = [2^i for i in 1:1:(ϵ_g == 0.001 ? 7 : 9)]

using SQLite, DataFrames
filepath = "./simulate2/results/gateerror_$(ϵ_g)_etac_$(η_c).db"

db = SQLite.DB(filepath)
DBInterface.execute(db, """
    CREATE TABLE IF NOT EXISTS results (
        L REAL,
        n INTEGER,
        shot INTEGER,
        y INTEGER,
        Q_x REAL,
        Q_z REAL
    )
""")

db_lock = ReentrantLock()

for L in L_values
    for n in n_values
        l0 = L / n
        p_ent = 0.5 * η_c^2 * exp(-l0/l_att)
        t_comms = fill(l0 / c, n)

        net_param = QuantumNetwork.NetworkParam(n-1, q; T2, F, p_ent, ϵ_g, ξ, t_comms)

        Threads.@threads for shot in 1:1024
            result = DBInterface.execute(db, "SELECT COUNT(*) FROM results WHERE L = $L AND n = $n AND shot = $shot") |> DataFrame
            if result[1, 1] > 0
                continue
            end

            network = QuantumNetwork.Network(net_param; rng=Xoshiro(shot))
            y, (Q_x, Q_z) = QuantumNetwork.simulate!(network)
            
            lock(db_lock) do
                DBInterface.execute(db, "INSERT INTO results (L, n, shot, y, Q_x, Q_z) VALUES ($L, $n, $shot, $y, $Q_x, $Q_z)")
            end
        end
    end
end


SQLite.close(db)