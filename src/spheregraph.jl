using MeshGraphs
using ReusePatterns
using LinearAlgebra
using Statistics

struct SphereSpec <: AbstractSpec
    radius::Real
    terrain_map::TerrainMap
end

const SphereGraph = MeshGraph{SphereSpec}

SphereGraph(radius::Real, terrain_map::TerrainMap) =
    MeshGraph(SphereSpec(radius, terrain_map))

function cartesian_to_spherical(coords::AbstractVector{<:Real})
    x, y, z = coords
    r = norm(coords[1:3])
    lat = r !=0 ? -acosd(z / r) + 90.0 : 0
    lon = atand(y, x)
    [lon, lat, r]
end

function spherical_to_cartesian(coords::AbstractVector{<:Real})
    lon, lat, r = coords
    r .* [cosd(lon) * cosd(lat), sind(lon) * cosd(lat), sind(lat)]
end

function deal_with_180(uv1, uv2)
    uv1 = copy(uv1)
    uv2 = copy(uv2)
    if uv1[1] ≈ -180 || uv2[1] ≈ -180
        if uv1[1] > 0 || uv2[1] > 0
            uv1[1] = abs(uv1[1])
            uv2[1] = abs(uv2[1])
        end
    end
    return uv1, uv2
end

function deal_with_poles(uv1, uv2)
    uv1 = copy(uv1)
    uv2 = copy(uv2)
    if abs(uv1[2]) ≈ 90
        uv1[1] = uv2[1]
    end
    if abs(uv2[2]) ≈ 90
        uv2[1] = uv1[1]
    end
    return uv1, uv2
end

function get_adjusted_uve(g, v1, v2)
    uv1 = copy(uve(g, v1))
    uv2 = copy(uve(g, v2))
    uv1, uv2 = deal_with_180(uv1, uv2)
    uv1, uv2 = deal_with_poles(uv1, uv2)
    return uv1, uv2
end

MeshGraphs.add_vertex_strategy(g::SphereGraph) = USE_UVE

function MeshGraphs.convert(g::SphereGraph, coords::AbstractVector{<:Real})
    r = spec(g).radius
    lon, lat, elev = coords
    real_r = elev + r
    return spherical_to_cartesian([lon, lat, real_r])
end

function distance_uve(g::SphereGraph, v1::Integer, v2::Integer)
    uv1, uv2 = get_adjusted_uve(g, v1, v2)
    return norm(uv1 - uv2)
end

function distance_xyz(g::SphereGraph, v1::Integer, v2::Integer)
    return norm(xyz(g, v1) - xyz(g, v2))
end

MeshGraphs.distance(g::SphereGraph, v1::Integer, v2::Integer) =
    distance_uve(g, v1, v2)

function MeshGraphs.new_vertex_coords(g::SphereGraph, v1::Integer, v2::Integer)
    uv1, uv2 = get_adjusted_uve(g, v1, v2)
    u, v = mean([uv1, uv2])
    elev = 0 # real_elevation(spec(g).terrain_map, u, v)
    return [u, v, elev]
end

function initial_spheregraph(u_min, u_max, v_min, v_max, n_elem_x, n_elem_y)
    t = TerrainMap(ones(2,2),ones(2,2),ones(2,2))
    g = rectangle_graph_uve( u_min, u_max, v_min, v_max, n_elem_x, n_elem_y, SphereSpec(6000, t))
    return g
end

function initial_spheregraph()
    nx = 17
    ny = Int(ceil((nx - 3) / 2))
    println("$(360/(nx+1)) $(180/(ny+2))")
    g = initial_spheregraph(
        -180.0,
        180 - 360 / (nx + 1),
        -90 + (180 / (ny + 2)),
        90 - (180 / (ny + 2)),
        nx,
        ny,
    )
    for i = 0:(nx+1):(ny-1)*(nx+1)
        add_interior!(g, (nx + 1) + i, 1 + i, 2 * (nx + 1) + i)
        add_interior!(g, 1 + i, (nx + 2) + i, 2 * (nx + 1) + i)
    end
    v1 = add_vertex!(g, [0.0, -90.0, 0.0])
    v2 = add_vertex!(g, [0.0, 90.0, 0.0])
    for i = 0:(nx-1)
        add_interior!(g, 1 + i, v1, 2 + i)
        add_interior!(g, ny * (nx + 1) + 1 + i, ny * (nx + 1) + 2 + i, v2)
    end
    add_interior!(g, nx + 1, v1, 1)
    add_interior!(g, (nx + 1) * (ny + 1), ny * (nx + 1) + 1, v2)
    update_boundaries!(g)
    return g
end
