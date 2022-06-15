# Type definition

struct TerrainSphereSpec <: AbstractSpec
    radius::Real
    terrain_map::TerrainMap
end

const TerrainSphereGraph = MeshGraph{TerrainSphereSpec}

TerrainSphereGraph(radius::Real, terrain_map::TerrainMap) =
    MeshGraph(TerrainSphereSpec(radius, terrain_map))

TerrainSphereGraph(terrain_map::TerrainMap) =
    TerrainSphereGraph(6371000, terrain_map)   # Earth's radius

radius(g::TerrainSphereGraph) = spec(g).radius

# Type adjusting

function new_coords_on_terrain_sphere(g::TerrainSphereGraph, v1::Integer, v2::Integer)
    uv1, uv2 = get_adjusted_uve(g, v1, v2)
    u, v = mean([uv1, uv2])
    elev = real_elevation(spec(g).terrain_map, u, v)
    return [u, v, elev]
end

MeshGraphs.add_vertex_strategy(g::TerrainSphereGraph) = USE_UVE

MeshGraphs.convert(g::TerrainSphereGraph, coords::AbstractVector{<:Real}) =
    convert_on_sphere(g, coords)

MeshGraphs.distance(g::TerrainSphereGraph, v1::Integer, v2::Integer) =
    distance_uv_on_sphere(g, v1, v2)

MeshGraphs.new_vertex_coords(g::TerrainSphereGraph, v1::Integer, v2::Integer) =
    new_coords_on_terrain_sphere(g, v1, v2)

# Initial graphs

function TerrainSphereGraph(sphere_graph::SphereGraph, t::TerrainMap)
    r = radius(sphere_graph)
    g = TerrainSphereGraph(r, t)
    v_map = Dict()
    counter = 0
    for v in normal_vertices(sphere_graph)
        counter += 1
        coords = uve(sphere_graph, v)
        coords[3] = real_elevation(t, coords[1], coords[2])
        add_vertex!(g, coords)
        v_map[v] = counter
    end
    for v in interiors(sphere_graph)
        v1, v2, v3 = interior_connectivity(sphere_graph, v)
        v1 = v_map[v1]
        v2 = v_map[v2]
        v3 = v_map[v3]
        add_interior!(g, v1, v2, v3)
    end
    for (v1, v2) in edges(sphere_graph)
        if is_on_boundary(sphere_graph, v1, v2)
            v1 = v_map[v1]
            v2 = v_map[v2]
            set_boundary!(g, v1, v2)
        end
    end
    return g
end
