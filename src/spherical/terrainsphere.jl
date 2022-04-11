struct TerrainSphereSpec <: AbstractSpec
    radius::Real
    terrain_map::TerrainMap
end

const TerrainSphereGraph = MeshGraph{TerrainSphereSpec}

TerrainSphereGraph(radius::Real, terrain_map::TerrainMap) =
    MeshGraph(TerrainSphereSpec(radius, terrain_map))

TerrainSphereGraph(terrain_map::TerrainMap) =
    TerrainSphereGraph(6371000, terrain_map)   # Earth's radius

function TerrainSphereGraph(sphere_graph::SphereGraph)

end

function new_coords_on_terrain_sphere(g::SphereGraph, v1::Integer, v2::Integer)
    uv1, uv2 = get_adjusted_uve(g, v1, v2)
    u, v = mean([uv1, uv2])
    elev = real_elevation(spec(g).terrain_map, u, v)
    return [u, v, elev]
end

MeshGraphs.add_vertex_strategy(g::SphereGraph) = USE_UVE

MeshGraphs.convert(g::SphereGraph, coords::AbstractVector{<:Real}) =
    convert_on_sphere(g, coords)

MeshGraphs.distance(g::SphereGraph, v1::Integer, v2::Integer) =
    distance_xyz(g, v1, v2)

MeshGraphs.new_vertex_coords(g::SphereGraph, v1::Integer, v2::Integer) =
    new_coords_on_terrain_sphere(g, v1, v2)
