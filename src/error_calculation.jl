function plain_error(g::AbstractMeshGraph, i::Integer)
    values = zipped_points_inside_triangle(g, i, spec(g).terrain_map)
    return sum(x -> abs(x[1] - x[2]), values)
end

function absolute_error(g::AbstractMeshGraph, i::Integer)
    values = zipped_points_inside_triangle(g, i, spec(g).terrain_map)
    v1, v2, v3 = interior_connectivity(g, i)
    area = triangle_area(xyz(g, v1), xyz(g, v2), xyz(g, v3))
    A = length(values)
    return sum(x -> abs(x[1] - x[2]), values)
end

function relative_error(g::AbstractMeshGraph, i::Integer)
    values = zipped_points_inside_triangle(g, i, spec(g).terrain_map)
    v1, v2, v3 = interior_connectivity(g, i)
    area = triangle_area(xyz(g, v1), xyz(g, v2), xyz(g, v3))
    A = area / length(values)
    return sum(x -> abs(x[1] - x[2]), values) * A / area
end

function plain_error(g::AbstractMeshGraph)
    return sum(i -> plain_error(g, i), interiors(g))
end

function absolute_error(g::AbstractMeshGraph)
    return sum(i -> absolute_error(g, i), interiors(g))
end

function relative_error(g::AbstractMeshGraph)
    return sum(i -> relative_error(g, i), interiors(g))
end
