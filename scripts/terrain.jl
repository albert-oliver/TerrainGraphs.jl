using TerrainGraphs

t = TerrainGraphs.load_tiff("resources/world.tif")
tk = TerrainGraphs.kriging_nan(t)

# Initial graph - regular grid (in uv)
g = SphereGraph(60000, -180, 180, -65, 65, 20, 10)

# Graph that can be adapted to terrain
gk = TerrainGraphs.TerrainSphereGraph(g, tk)

p = TerrainGraphs.RefinementParameters(100, -100, 100, 100)
TerrainGraphs.adapt_terrain!(gk, p, 5)
export_inp(gk, "tmp.inp")
