using Logging
global_logger(NullLogger())

using CSV, DataFrames
using Plots, ColorSchemes, LaTeXStrings

palette = ColorSchemes.mk_12

ϵ_g_values = [0.0001, 0.001]
η_c_values = [1.0, 0.9, 0.5, 0.3]

plot_layout = @layout [a b c d; e f g h]
p = plot(layout = plot_layout, size=(2000, 1000))

for (i, ϵ_g) in enumerate(ϵ_g_values)
    for (j, η_c) in enumerate(η_c_values)
        filepath = "predicted/fth_0.95/AlwaysDistillAtAllLevels_Generalfile_Swap_Opt_SKRjan15_withdecoherence_maxD_10000_iniF_$(1-1.25ϵ_g)_t2_1_gaterror_$(ϵ_g)_mx_$(0.25ϵ_g)etac_$(η_c)fth_0.95.csv"

        df = CSV.File(filepath, types=BigFloat) |> DataFrame
        sort!(df, [:N, :col_Distance])
        filter!(row -> row.col_Distance >= 10, df)
        filter!(row -> row.N <= (ϵ_g == 0.001 ? 128 : 512), df)
        grouped_df = groupby(df, [:N])

        for g in grouped_df
            n = g[1, :N]; iter = convert(Int, log2(n)) + 1
            distance_vec = g[!, :col_Distance]
            real_vec = g[!, :col_SKR_pipeline] ./ 1024

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
                legend = :none
            )
        end
    end
end

plot!(p, xscale=:log10, yscale=:log10)
savefig(p, "predicted/predicted.png")