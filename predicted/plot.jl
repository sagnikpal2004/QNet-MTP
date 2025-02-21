# INCOMPLETE

using CSV, DataFrames
using Plots, ColorSchemes

palette = ColorSchemes.mk_12

ϵ_g_values = [0.0001, 0.001]
η_c_values = [1.0, 0.9, 0.5, 0.3]

for (i, ϵ_g) in enumerate(ϵ_g_values)
    for (j, η_c) in enumerate(η_c_values)
        filepath = "predicted/fth_0.95/AlwaysDistillAtAllLevels_Generalfile_Swap_Opt_SKRjan15_withdecoherence_maxD_10000_iniF_$(1-1.25ϵ_g)_t2_1_gaterror_$(ϵ_g)_mx_$(0.25ϵ_g)etac_$(η_c)fth_0.95.csv"

        df = CSV.File(filepath, types=BigFloat) |> DataFrame
        filter!(row -> row.col_Distance >= 10, df)
        filter!(row -> )
        grouped_df = groupby(df, [:N])

        for g in grouped_df
            n = g[1, :N]; iter = convert(Int, log2(n)) + 1
        end
    end
end

filepath = "predicted/fth_0.95/AlwaysDistillAtAllLevels_Generalfile_Swap_Opt_SKRjan15_withdecoherence_maxD_10000_iniF_$(F)_t2_1_gaterror_$(ϵ_g)_mx_$(ξ)etac_$(η_c)fth_0.95.csv"

using CSV, DataFrames

df = CSV.File(filepath, types=BigFloat) |> DataFrame
df = filter(row -> row.N < 513, df)
grouped_df = groupby(df, [:N])

using Plots
using Plots.PlotMeasures
using ColorSchemes
palette = ColorSchemes.mk_12

for g in grouped_df
    N = g[1, :N]; iter = convert(Int, log2(N)) + 1

    x = g.col_Distance
    y = g.col_SKR_pipeline ./ 1024

    # plot!(x, y, xlims=[10, 10000], ylims=[10^-4, 1])

    plot!(x, y,
        # title=L"ϵ_g = %$(ϵ_g), η_c = %$(η_c)", 
        legend_font_pointsize=10, 
        legend_title_font=10, 
        label="N = $N", 
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

plot!(xscale=:log10, yscale=:log10,)

savefig("predicted/plot.png")