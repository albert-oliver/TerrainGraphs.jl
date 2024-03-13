using TerrainGraphs

t = TerrainGraphs.load_tiff("resources/world.tif")
tk = TerrainGraphs.simple_NaN_removal(t)

# Initial graph - regular grid (in uv)
g = SphereGraph(60000, -180, 180, -65, 65, 20, 10)

# Graph that can be adapted to terrain
gk = TerrainGraphs.TerrainSphereGraph(g, tk)

p = TerrainGraphs.RefinementParameters(100, -100, 100, 100)
export_step(g, step) = export_inp(g, "earth_globe_$(step).inp")
export_step(gk, 0)
TerrainGraphs.adapt_terrain!(gk, p, 9, after_step = export_step)
