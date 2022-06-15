using Statistics

struct BoundingBox
    min_x::Number
    max_x::Number
    min_y::Number
    max_y::Number
end

struct RefinementParameters
    ϵ::Number
    coastline_lower_bound::Number
    coastline_upper_bound::Number
    coastline_min_size::Number
end

"""
    point_in_triangle(p, M)
    point_in_triangle(p, t)

Is point `p` inside triangle represented as:
- matrix `M`, see [`barycentric_matrix`](@ref)
- Triangle `t`, see [`Triangle`](@ref)

Note that second method is ineffective when used repeatedly on the same
triangle.
"""
function point_in_triangle end

function point_in_triangle(p, M)
    bc = barycentric(M, p)
    return bc[1] > 0 && bc[2] > 0 && 1 - bc[1] - bc[2] > 0
end

function point_in_triangle(p, t::Triangle)
    M = barycentric_matrix(t)
    point_in_triangle(p, t, M)
end

"Return all indexes of matrix (field of `terrain`) that are inside triangle `t`"
function indexes_in_triangle(t::Triangle, terrain::TerrainMap)
    t_i = map(p -> point_to_index_coords(terrain, p[1], p[2]), t)

    bb = BoundingBox(
            minimum([t_i[1][1], t_i[2][1], t_i[3][1]]),
            maximum([t_i[1][1], t_i[2][1], t_i[3][1]]),
            minimum([t_i[1][2], t_i[2][2], t_i[3][2]]),
            maximum([t_i[1][2], t_i[2][2], t_i[3][2]])
        )

    M = barycentric_matrix(t_i)
    indexes = []
    for i in ceil(Int, bb.min_x):floor(Int, bb.max_x)
        for j in ceil(Int, bb.min_y):floor(Int, bb.max_y)
            if point_in_triangle([i, j], M)
                push!(indexes, [i, j])
            end
        end
    end

    return indexes
end

"""
Return iterator over pairs `(real, approx)` of all the points from `terrain`
inside triangle represented by `interior`, where `real` is value from `terrain`
and `approx` is approximated value in graph `g`
"""
function zipped_points_inside_triangle(g, interior, terrain)
    v1, v2, v3 = interior_connectivity(g, interior)
    triangle = (uv(g, v1), uv(g, v2), uv(g, v3))
    indexes = indexes_in_triangle(triangle, terrain)
    points = map(i -> index_to_point(terrain, i[1], i[2]), indexes)
    M = barycentric_matrix(triangle)
    points_br = map(p -> barycentric(M, p), points)

    function approx(p)
        get_elevation(g, v1) * p[1] +
        get_elevation(g, v2) * p[2] +
        get_elevation(g, v3) * (1 - p[1] - p[2])
    end
    approx_elev = map(approx, points_br)
    real_elev = map(i -> terrain.M[i[1], i[2]], indexes)

    return zip(real_elev, approx_elev)
end


"""
    height_difference_refinement_criterion(g, interior, terrain, ϵ)

Check if traingle should be refined based on height difference. If **any** of
the points in triangle has error greater than `ϵ` return `true`.

See also: See also: [`height_difference_refinement_criterion`](@ref)
"""
function height_difference_refinement_criterion(g, interior, terrain, ϵ)
    for (real, approx) in zipped_points_inside_triangle(g, interior, terrain)
        if abs(real - approx) > ϵ
            return true
        end
    end
    return false
end

function coastline_refinement_criterion(g, interior, terrain, params)

    lower_bound = params.coastline_lower_bound
    upper_bound = params.coastline_upper_bound

    vertices = interior_connectivity(g, interior)

    if (projection_area(g, interior) > params.coastline_min_size &&

        # All of these transtales into: not all the nodes above upper bound OR
        #                               not all the nodes below lower bound
        (
        (any([get_elevation(g, v) <= upper_bound for v in vertices]) &&
         any([get_elevation(g, v) > upper_bound for v in vertices]))
        ||
        (any([get_elevation(g, v) <= lower_bound for v in vertices]) &&
         any([get_elevation(g, v) > lower_bound for v in vertices]))
        ||
        any([lower_bound .<= get_elevation(g, v) .<= upper_bound for v in vertices])
        )
        )
            return true
    end
    return false
end

"Mark all traingles where error is larger than `ϵ` for refinement."
function mark_for_refinement(g::MeshGraph, terrain::TerrainMap, params)::Array{Number, 1}
    to_refine = []
    for interior in interiors(g)

        if (height_difference_refinement_criterion(g, interior, terrain, params.ϵ) ||
              coastline_refinement_criterion(g, interior, terrain, params))
            push!(to_refine, interior)
        end
    end
    return to_refine
end

"""
    adapt_terrain!(g, terrain, ϵ, max_iters)

Adapt graph `g` to terrain map `terrain`. Stop when error is lesser than ϵ, or
after `max_iters` iterations.

See also: [`generate_terrain_mesh`](@ref)
"""
function adapt_terrain!(
    g::MeshGraph,
    terrain::TerrainMap,
    params,
    max_iters::Integer,
)
    for i = 1:max_iters
        println("Iteration ", i)
        # export_obj(g, "baltyk_iter_$i.obj")
        to_refine = mark_for_refinement(g, terrain, params)
        if isempty(to_refine)
            break
        end
        for interior in to_refine
            set_refine!(g, interior)
        end
        refine!(g)
    end
    return g
end
