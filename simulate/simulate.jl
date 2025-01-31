if length(ARGS) != 4
    println("Usage: julia simulate/simulate.jl <L> <n> <η_c> <ϵ_g>")
    exit(1)
end

L = parse(Float64, ARGS[1])
n = parse(Int64, ARGS[2])
η_c = parse(Float64, ARGS[3])
ϵ_g = parse(Float64, ARGS[4])

using SQLite
db = SQLite.DB("./simulate/results/results3.db")

result = SQLite.Stmt(db, "SELECT COUNT(*) FROM \"QNet-MTP\" WHERE L = $L AND n = $n AND η_c = $η_c AND ϵ_g = $ϵ_g")
println(result)