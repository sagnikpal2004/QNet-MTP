using SQLite
db = SQLite.DB("./simulate/results/results3.db")

L_values = [10^i * 1000 for i in 1:0.25:4]
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

                run("sbatch -c 2 --mem 16G -t 05:00:00 --wrap=\"julia --project=simulate --threads=auto simulate/simulate.jl $L $n $η_c $ϵ_g\"")
            end
        end
    end
end