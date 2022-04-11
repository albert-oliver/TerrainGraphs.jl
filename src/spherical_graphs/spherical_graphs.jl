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

function distance_uv_on_sphere(g::MeshGraph, v1::Integer, v2::Integer)
    uv1, uv2 = get_adjusted_uve(g, v1, v2)
    return norm(uv1[1:2] - uv2[1:2])
end

function distance_xyz(g::MeshGraph, v1::Integer, v2::Integer)
    return norm(xyz(g, v1) - xyz(g, v2))
end

function convert_on_sphere(g::MeshGraph, coords::AbstractVector{<:Real})
    lon, lat, elev = coords
    real_r = elev + radius(g)
    return spherical_to_cartesian([lon, lat, real_r])
end

include("sphere.jl")
include("terrainsphere.jl")
