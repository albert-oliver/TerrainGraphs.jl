module TerrainGraphs

using MeshGraphs
using LinearAlgebra
using Statistics

export
    SphereGraph,
    radius,
    initial_spheregraph,

    # Utils
    refine_all!,

    # TerrainMap
    TerrainMap,
    x_min,
    x_max,
    y_min,
    y_max,
    Δx,
    Δy,
    nx,
    ny,
    width,
    height,
    real_elevation,
    index_to_point,
    point_to_index,
    point_to_index_coords

include("terrain_map.jl")
include("spherical_graphs/spherical_graphs.jl")
include("flat/flatgraph.jl")
include("utils.jl")
include("adapt_terrain.jl")
include("io.jl")

end
