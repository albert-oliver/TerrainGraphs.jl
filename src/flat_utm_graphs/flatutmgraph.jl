using Proj

# Type definition
struct FlatUTMSpec <: AbstractSpec
    trans
    terrain_map::TerrainMap
end

function FlatUTMSpec(proj4_code::String, terrain_map::TerrainMap)
    trans = Proj.Transformation(proj4_code, "EPSG:4326", always_xy = true)
    FlatUTMSpec(trans, terrain_map)
end

const FlatUTMGraph = MeshGraph{FlatUTMSpec}

FlatUTMGraph(proj4_code::String, terrain_map::TerrainMap) =
    FlatUTMGraph(FlatUTMSpec(proj4_code, terrain_map))

terrain_map(g::FlatUTMGraph) = spec(g).terrain_map

# Type adjusting
function new_coords_flat(g::FlatUTMGraph, v1::Integer, v2::Integer)
    xy1 = xyz(g, v1)[1:2]
    xy2 = xyz(g, v2)[1:2]
    new_x, new_y = mean([xy1, xy2])
    _, _, elev = MeshGraphs.convert(g, [new_x, new_y])
    return [new_x, new_y, elev]
end

function convert_proj(g::FlatUTMGraph, coords::AbstractVector{<:Real})
    u, v = spec(g).trans(coords)
    elev = real_elevation(spec(g).terrain_map, u, v)
    return [u, v, elev]
end

function distance_flat_xy(g::FlatUTMGraph, v1::Integer, v2::Integer)
    xy1 = xyz(g, v1)[1:2]
    xy2 = xyz(g, v2)[1:2]
    return norm(xy2 - xy1)
end

MeshGraphs.add_vertex_strategy(_::FlatUTMGraph) = USE_XYZ

MeshGraphs.convert(g::FlatUTMGraph, coords::AbstractVector{<:Real}) =
    convert_proj(g, coords)

MeshGraphs.distance(g::FlatUTMGraph, v1::Integer, v2::Integer) =
    distance_flat_xy(g, v1, v2)

MeshGraphs.new_vertex_coords(g::FlatUTMGraph, v1::Integer, v2::Integer) =
    new_coords_flat(g, v1, v2)

function local_get_elevation(g::FlatUTMGraph, i::Integer)
    u, v = uv(g, i)
    return real_elevation(spec(g).terrain_map, u, v)
end


# Initial graphs
function FlatUTMGraph(proj4_code::String, t::TerrainMap, x_min, x_max, y_min, y_max, n_elem_x, n_elem_y)
    g = rectangle_graph(
        FlatUTMSpec(proj4_code, t),
        x_min,
        x_max,
        y_min,
        y_max,
        n_elem_x,
        n_elem_y,
    )

    for i in normal_vertices(g)
        elev = local_get_elevation(g, i)
        set_elevation!(g, i, elev)
    end

    return g
end
