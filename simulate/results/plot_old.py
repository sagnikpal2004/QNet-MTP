# TODO: Modify to use SQLite

import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import LogLocator
from matplotlib.ticker import ScalarFormatter

results_df = pd.read_csv("./results/results2.csv")
grouped_df = results_df.groupby("n")

plt.figure()
for name, group in grouped_df:
    plt.plot(group["l0"], group["E_Y"], label=f"N={name}")

plt.xscale("log", base=2)
plt.yscale("log", base=2)
plt.ylim(bottom=1)

plt.gca().xaxis.set_major_locator(LogLocator(base=2))
plt.gca().xaxis.set_major_formatter(ScalarFormatter())
plt.gca().yaxis.set_major_locator(LogLocator(base=2))
plt.gca().yaxis.set_major_formatter(ScalarFormatter())

plt.title("Two-way quantum relay network\nMultiplexed links per elem. segment = 256")
plt.xlabel("Inter-repeater spacing L₀ (km)")
plt.ylabel("Expected number of Bell pairs delivered end-to-end")
plt.legend(fontsize="small")

plt.savefig("./results/results2.png")
print("File saved")