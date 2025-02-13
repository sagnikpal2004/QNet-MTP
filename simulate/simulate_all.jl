using SQLite, DataFrames
db = SQLite.DB("./simulate/results/results4.db")

DBInterface.execute(db, """
    CREATE TABLE IF NOT EXISTS "QNet-MTP" (
        L REAL,
        n INTEGER,
        η_c REAL,
        ϵ_g REAL,
        E_Y REAL,
        SKR REAL
    )
""")

L_values = vcat(
    [10^i * 1000 for i in 1:0.125:2],
    [10^i * 1000 for i in 2:0.0625:3],
    [10^i * 1000 for i in 3:0.03125:4]
)
n_values = [2^i for i in 1:1:9]
η_c_values = [1.0, 0.9, 0.5, 0.3]
ϵ_g_values = [0.0001, 0.001]

for η_c in η_c_values
    for ϵ_g in ϵ_g_values
        for n in n_values
            for L in L_values
                if ϵ_g == 0.001 && n > 129
                    continue
                end

                result = DBInterface.execute(db, "SELECT COUNT(*) FROM \"QNet-MTP\" WHERE L = $L AND n = $n AND η_c = $η_c AND ϵ_g = $ϵ_g") |> DataFrame
                if result[1, 1] > 0
                    continue
                end

                run(`sbatch -c 4 --mem 16G -t 23:59:59 --mail-type FAIL --wrap="julia --project=simulate --threads=auto simulate/simulate.jl $L $n $η_c $ϵ_g"`)
                println("Started worker for L = $L, n = $n, η_c = $η_c, ϵ_g = $ϵ_g")
            end
        end
    end
end