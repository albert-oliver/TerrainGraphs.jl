module TerrainGraphs

using MeshGraphs
using LinearAlgebra
using Statistics

export
    # FlatGraph
    FlatGraph,
    FlatSpec,
    initial_flat_graph,

    # FlatUTMGraph
    FlatUTMGraph,
    FlatUTMSpec,

    # ShpereGraph
    SphereGraph,
    SphereSpec,
    TerrainSphere,
    TerrainSphereSpec,
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
    point_to_index_coords,

    # From MeshGraphs
    export_inp

include("terrain_map.jl")
include("spherical_graphs/spherical_graphs.jl")
include("flat_graphs/flat_graphs.jl")
include("flat_utm_graphs/flat_utm_graphs.jl")
include("utils.jl")
include("adapt_terrain.jl")
include("error_calculation.jl")
include("io.jl")

end
