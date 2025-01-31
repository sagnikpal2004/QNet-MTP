import pandas as pd
import sqlite3

conn = sqlite3.connect("./simulate/results/results3.db")
df = pd.read_sql_query("SELECT * FROM \"QNet-MTP\"", conn)

print(df)