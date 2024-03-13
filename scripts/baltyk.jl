using TerrainGraphs

t = TerrainGraphs.load_tiff("resources/extended_baltyk.tif")
tk = TerrainGraphs.simple_NaN_removal(t)
t2 = TerrainMap(tk.M, tk.x_min, tk.y_min, tk.Δx, tk.Δy, tk.nx, tk.ny)
p = TerrainGraphs.RefinementParameters(20, -100, 100, 100)
g = TerrainGraphs.FlatUTMGraph(
    "EPSG:25837", t2,
    -1500000, 61000,
    6100000, 7661000,
    1, 1,
)
export_step(g, step) = export_inp(g, "baltyk_$(step).inp")
export_step(g, 0)
TerrainGraphs.adapt_terrain!(g, p, 18; after_step = export_step)
