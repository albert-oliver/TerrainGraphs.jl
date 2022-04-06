using LinearAlgebra

"""
    TerrainMap(M, x_min, y_min, Δx, Δy, nx, ny)

Struct that represents terrain map with real elevations as matrix.

    TerrainMap(lat, lon, elev)

Takes three matrixes:
- `lat`: matrix of latitudes of terrain
- `lon`: matrix of longitudes of terrain
- `elev`: matrix of terrain elevations
"""
struct TerrainMap
    M::Array{Real, 2}
    x_min::Real
    y_min::Real
    Δx::Real
    Δy::Real
    nx::Real
    ny::Real
end

function TerrainMap(lat::Matrix, lon::Matrix, elev::Matrix)
    TerrainMap(
        elev,
        minimum(lon),
        minimum(lat),
        lon[1, 2] - lon[1, 1],
        lat[2, 1] - lat[1, 1],
        size(elev, 2),
        size(elev, 1),
    )
end

# TODO Remove - backword compatible function
function TerrainMap(M, w, h, scale, offset)
    TerrainMap(
        (M .- 1) .* scale .+ offset,
        0,
        0,
        w / (size(M, 2) - 1),
        h / (size(M, 1) - 1),
        size(M, 2),
        size(M, 1)
    )
end

x_min(t::TerrainMap) = t.x_min
x_max(t::TerrainMap) = t.x_min + (t.nx - 1) * t.Δx
y_min(t::TerrainMap) = t.y_min
y_max(t::TerrainMap) = t.y_min + (t.ny - 1) * t.Δy
Δx(t::TerrainMap) = t.Δx
Δy(t::TerrainMap) = t.Δy
nx(t::TerrainMap) = t.nx
ny(t::TerrainMap) = t.ny
width(t::TerrainMap) = x_max(t) - x_min(t)
height(t::TerrainMap) = y_max(t) - y_min(t)

"Return barycentric coordinates of point `p` in the single cell of
terrain map `t`"
function barycentric(t::TerrainMap, p::AbstractVector)

    # Translated p is the point with origin in the bottom/left corner of the cell (not the map)
    i, j = point_to_index(t, p)
    translated_p = p - index_to_point(t, i, j)

    Δx_left = translated_p[1] / Δx(t)
    Δy_bottom = translated_p[2] / Δy(t)
    Δx_right = 1 - Δx_left
    Δy_top = 1 - Δy_bottom

    return [
        Δx_right * Δy_top,
        Δx_left * Δy_top,
        Δx_left * Δy_bottom,
        Δx_right * Δy_bottom
    ]
end

"""
    real_elevation(t, x, y)
    real_elevation(t, p)

Return elevation from terrain map `t` in point `p` (or coordinates `x` and `y`).
"""
function real_elevation end

function real_elevation(t::TerrainMap, p::AbstractVector)
    bc = barycentric(t, p)
    i, j = point_to_index(t, p)
    heights = [
        t.M[i, j],
        t.M[i, j+1],
        t.M[i+1, j+1],
        t.M[i+1, j]
    ]
    return dot(heights, bc)
end

real_elevation(t::TerrainMap, x::Real, y::Real) = real_elevation(t, [x, y])

"""
    index_to_point(t, i, j)
    index_to_point(t, indices)

Return coodrinates of point based on it's indexes in matrix inside terrain
map `terrain`.

See also: [`point_to_index`](@ref)
"""
function index_to_point(t::TerrainMap, i::Integer, j::Integer)
    if i < 1 || i > size(t.M, 1)
        throw(DomainError("Index out of map range"))
    end
    if j < 1 || j > size(t.M, 2)
        throw(DomainError("Index out of map range"))
    end

    x = x_min(t) + (j-1) * Δx(t)
    y = y_min(t) + (i-1) * Δy(t)
    return [x, y]
end

index_to_point(t::TerrainMap, indices::AbstractVector) =
    index_to_point(t, indices[1], indices[2])

"""
    point_to_index(t, x, y)
    point_to_index(t, p)

Return indexes of point `p` in matrix inside terrain map `t`. Always return
**lowest-left** coordinates.

# Note
- Will **never return** max indices of matrix - in such cases index will be 1 smaller
- Except for above the following is true
    - When exectly on point in map, its exact index will be returned
    - When on 'edge' connecting two points, return lowest-left point on this edge

See also: [`index_to_point`](@ref)
"""
function point_to_index end

function point_to_index(t::TerrainMap, x::Real, y::Real)
    if x < x_min(t) || x > x_max(t)
        throw(DomainError("Point not in terrain map. Input x: $x, min x: $(x_min(t)), max x: $(x_max(t))"))
    end
    if y < y_min(t) || y > y_max(t)
        throw(DomainError("Point not in terrain map. Input y: $y, min y: $(y_min(t)), max y: $(y_max(t))"))
    end

    i = Int(trunc((y - y_min(t)) / Δy(t)))
    j = Int(trunc((x - x_min(t)) / Δx(t)))

    i = i + 1 == size(t.M, 1) ? i : i + 1
    j = j + 1 == size(t.M, 2) ? j : j + 1

    return [i, j]
end

point_to_index(t::TerrainMap, p::AbstractVector) = point_to_index(t, p[1], p[2])


# TODO remove in the future, when points distribution during splitting triangle
# is implemented
"""
    point_to_index_coords(terrain, x, y)
    point_to_index_coords(terrain, p)

Similar to `point_to_index` but doesn't result to integers. So you could say
that returned values are coordinates in 'matrix based system'.

For example, when `point_to_index_coords` return `[1.2, 5.8]`, then
`point_to_index` would return [1, 5], so it can be used as
indexes in matrix.

See also: [`point_to_index`](@ref), [`index_to_point`](@ref)
"""
function point_to_index_coords end

function point_to_index_coords(t::TerrainMap, x::Real, y::Real)
    if x < x_min(t) || x > x_max(t)
        throw(DomainError("Point not in terrain map. Input x: $x, min x: $(x_min(t)), max x: $(x_max(t))"))
    end
    if y < y_min(t) || y > y_max(t)
        throw(DomainError("Point not in terrain map. Input y: $y, min y: $(y_min(t)), max y: $(y_max(t))"))
    end

    i = (y - y_min(t)) / Δy(t)
    j = (x - x_min(t)) / Δx(t)

    i = i + 1
    j = j + 1

    return [i, j]
end

point_to_index_coords(t, p) = point_to_index_coords(t, p[1], p[2])
