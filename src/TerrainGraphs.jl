module TerrainGraphs

export
    SphereGraph,
    initial_spheregraph,

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
include("spheregraph.jl")

end
