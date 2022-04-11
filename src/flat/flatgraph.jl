using Proj4

struct FlatSpec <: AbstractSpec
    trans
    terrain_map::TerrainMap
end

function FlatSpec(proj4_code::String, terrain_map::TerrainMap)
    trans = Proj4.Transformation("EPSG:4326", "EPSG:32634")
    FlatSpec(trans, terrain_map)
end

const FlatGraph = MeshGraph{FlatSpec}

FlatGraph(proj, terrain_map::TerrainMap) =
    MeshGraph(FlatSpec(proj, terrain_map))

function FlatGraph(proj4_code::String, terrain_map::TerrainMap)
    trans = Proj4.Transformation("EPSG:4326", proj4_code)
    FlatGraph(trans, terrain_map)
end

function new_coords_flat(g::FlatGraph, v1::Integer, v2::Integer)
    uv1, uv2 = uv(g, v1), uv(g, v2)
    u, v = mean([uv1, uv2])
    elev = real_elevation(spec(g).terrain_map, u, v)
    return [u, v, elev]
end

function convert_proj(g::FlatGraph, coords::AbstractVector{<:Real})
    u, v, e = coords
    x, y = spec(g).trans([v, u])
    return [x, y, e]
end

function distance_uv(g::FlatGraph, v1::Integer, v2::Integer)
    return norm(uv(g, v1) - uv(g, v2))
end

MeshGraphs.add_vertex_strategy(g::FlatGraph) = USE_UVE

MeshGraphs.convert(g::FlatGraph, coords::AbstractVector{<:Real}) =
    convert_proj(g, coords)

MeshGraphs.distance(g::FlatGraph, v1::Integer, v2::Integer) =
    distance_uv(g, v1, v2)

MeshGraphs.new_vertex_coords(g::FlatGraph, v1::Integer, v2::Integer) =
    new_coords_flat(g, v1, v2)

function initial_flat_graph(target_code::String, t::TerrainMap)
    g = rectangle_graph(
        FlatSpec(target_code, t),
        x_min(t),
        x_max(t),
        y_min(t),
        y_max(t),
        180,
        180,
    )

    for i in normal_vertices(g)
        u, v = uv(g, i)
        elev = real_elevation(spec(g).terrain_map, u, v)
        set_elevation!(g, i, elev)
    end

    return g
end
