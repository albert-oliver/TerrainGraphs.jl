using TerrainGraphs
using MeshGraphs

t = TerrainGraphs.load_tiff("resources/val.tif")
tk = TerrainGraphs.kriging_nan(t)
t2 = TerrainMap(tk.M, tk.x_min, tk.y_min, tk.Δx, tk.Δy, tk.nx, tk.ny)
p = TerrainGraphs.RefinementParameters(20, -100, 100, 100)
g = TerrainGraphs.FlatGraph("EPSG:9155", t2, 1, 1)
export_step(g, step) = export_inp(g, "val_$(step).inp")
export_step(g, 0)
TerrainGraphs.adapt_terrain!(g, p, 18; after_step=export_step)
