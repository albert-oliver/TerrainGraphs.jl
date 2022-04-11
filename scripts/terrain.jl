using Revise
using MeshGraphs
using TerrainGraphs

g  = TerrainGraphs.initial_spheregraph(60000, -180, 180, 65, -65, 11, 6)
t = TerrainGraphs.load_tiff("world.tif")
tk = TerrainGraphs.kriging_nan(t)
gt = TerrainGraphs.TerrainSphereGraph(g, tk)
p = TerrainGraphs.RefinementParameters(100, -100, 100, 100)
TerrainGraphs.adapt_terrain!(gt, tk, p, 5)
