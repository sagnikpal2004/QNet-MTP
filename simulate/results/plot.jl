using Plots
using LaTeXStrings
using Plots.PlotMeasures

using ColorSchemes
palette = ColorSchemes.mk_12

using SQLite, DataFrames
db = SQLite.DB("./simulate/results/results4.db")
df = DBInterface.execute(db, "SELECT * FROM \"QNet-MTP\"") |> DataFrame
sort!(df, [:n, :η_c, :ϵ_g, :L])

η_c_values = [1.0, 0.9, 0.5, 0.3]
ϵ_g_values = [0.0001, 0.001]


plot_layout = @layout [a b c d; e f g h]
p = plot(layout = plot_layout, size=(2000, 1000))

xlabel!(p, "Distance (km)")
ylabel!(p, "Secret key rate \n (bits per channel use per burst)")

for (i, ϵ_g) in enumerate(ϵ_g_values)
    for (j, η_c) in enumerate(η_c_values)
        filtered_df = filter(row -> row.ϵ_g == ϵ_g && row.η_c == η_c, df)
        grouped_df = groupby(filtered_df, :n)

        for g in grouped_df
            n = g[1, :n]; iter = convert(Int, log2(n)) + 1
            distance_vec = g[!, :L] ./ 1000
            real_vec = g[!, :SKR]

            plot!(p[i, j], distance_vec, real_vec,
                title=L"ϵ_g = %$(ϵ_g), η_c = %$(η_c)", 
                legend_font_pointsize=10, 
                legend_title_font=10, 
                label="N = $n", 
                lw=3.5, 
                xlims=(1e1, 1e4),
                ylim=(1e-4, 1e0), 
                color=palette[iter],
                dpi=500, 
                left_margin = 5mm ,
                right_margin = 5mm,
                bottom_margin = 5mm, 
                top_margin = 4mm,
                legend = :none
            )
        end
    end
end

plot!(p, xscale=:log10, yscale=:log10,)
savefig(p, "simulate/results/results4.png")
