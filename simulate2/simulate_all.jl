using SQLite, DataFrames
db = SQLite.DB("./simulate/results/results5.db")

DBInterface.execute(db, """
    CREATE TABLE IF NOT EXISTS "QNet-MTP" (
        L REAL,
        n INTEGER,
        η_c REAL,
        ϵ_g REAL,
        shot INTEGER,
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