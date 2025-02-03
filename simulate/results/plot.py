import pandas as pd
import sqlite3
import matplotlib.pyplot as plt

η_c_values = [1.0, 0.9, 0.5, 0.3]
ϵ_g_values = [0.0001, 0.001]

conn = sqlite3.connect("./simulate/results/results3.db")
df = pd.read_sql_query("SELECT * FROM \"QNet-MTP\"", conn).sort_values(by=["ϵ_g", "η_c", "n", "L"])

print(df)

fig, axes = plt.subplots(2, 4, sharex=True, sharey=True, figsize=(20, 10))

for i, ϵ_g in enumerate(ϵ_g_values):
    for j, η_c in enumerate(η_c_values):
        ax = axes[i, j]
        filtered_df = df[(df["ϵ_g"] == ϵ_g) & (df["η_c"] == η_c)]
        grouped_df = filtered_df.groupby("n")

        for name, group in grouped_df:
            ax.plot(group["L"], group["E_Y"], label=f"n={name}")

        ax.set_xscale("log", base=10)
        ax.set_yscale("log", base=10)
        ax.set_title(f"ϵ_g={ϵ_g}, η_c={η_c}")
        ax.legend()

plt.tight_layout(rect=[0.03, 0.03, 1, 0.95])

plt.savefig("./simulate/results/results3.png")
print("File saved.")
