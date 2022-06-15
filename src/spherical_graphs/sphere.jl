# Type definition

struct SphereSpec <: AbstractSpec
    radius::Real
end

const SphereGraph = MeshGraph{SphereSpec}

SphereGraph(radius::Real) = MeshGraph(SphereSpec(radius))

radius(g::SphereGraph) = spec(g).radius

# Type adjusting

function new_coords_on_sphere(g::SphereGraph, v1::Integer, v2::Integer)
    uv1, uv2 = get_adjusted_uve(g, v1, v2)
    u, v = mean([uv1, uv2])
    elev = 0
    return [u, v, elev]
end

MeshGraphs.add_vertex_strategy(g::SphereGraph) = USE_UVE

MeshGraphs.convert(g::SphereGraph, coords::AbstractVector{<:Real}) =
    convert_on_sphere(g, coords)

MeshGraphs.distance(g::SphereGraph, v1::Integer, v2::Integer) =
    distance_uv_on_sphere(g, v1, v2)

MeshGraphs.new_vertex_coords(g::SphereGraph, v1::Integer, v2::Integer) =
    new_coords_on_sphere(g, v1, v2)

# Advanced constructors

function SphereGraph(
    radius::Real,
    u_min::Real,
    u_max::Real,
    v_min::Real,
    v_max::Real,
    n_elem_x::Integer,
    n_elem_y::Integer,
)
    is_full_lon = u_min ≈ -180 && u_max ≈ 180
    has_north_pole = v_max ≈ 90
    has_south_pole = v_min ≈ -90
    nx = n_elem_x
    ny = n_elem_y

    if is_full_lon
        u_max -= 360 / n_elem_x
        nx -= 1
    end
    if has_north_pole
        v_max -= 180 / n_elem_y
        ny -= 1
    end
    if has_south_pole
        v_min += 180 / n_elem_y
        ny -= 1
    end

    g = rectangle_graph(SphereSpec(radius), u_min, u_max, v_min, v_max, nx, ny)

    if is_full_lon
        for i = 0:(nx+1):(ny-1)*(nx+1)
            add_interior!(g, (nx + 1) + i, 1 + i, 2 * (nx + 1) + i)
            add_interior!(g, 1 + i, (nx + 2) + i, 2 * (nx + 1) + i)
        end
    end
    if has_north_pole
        v2 = add_vertex!(g, [0.0, 90.0, 0.0])
        for i = 0:(nx-1)
            add_interior!(g, ny * (nx + 1) + 1 + i, ny * (nx + 1) + 2 + i, v2)
        end
        if is_full_lon
            add_interior!(g, (nx + 1) * (ny + 1), ny * (nx + 1) + 1, v2)
        end
    end
    if has_south_pole
        v1 = add_vertex!(g, [0.0, -90.0, 0.0])
        for i = 0:(nx-1)
            add_interior!(g, 1 + i, v1, 2 + i)
        end
        if is_full_lon
            add_interior!(g, nx + 1, v1, 1)
        end
    end

    update_boundaries!(g)
    return g
end

function SphereGraph(radius::Real, n_elem_x::Integer)
    nx = n_elem_x
    ny = Int(ceil(nx / 2))
    g = SphereGraph(radius, -180, 180, -90, 90, nx, ny)
end
