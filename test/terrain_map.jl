@testset "TerrainMap" begin
    function get_terrain(elev_fun=(x, y) -> x + y)
        nx = 5
        ny = 5
        lat = fill(NaN, ny, nx)
        lon = copy(lat)
        elev = copy(lon)
        for i = 1:ny
            for j = 1:nx
                lat[i, j] = 3 + 3 * (i - 1)
                lon[i, j] = 2 + 2 * (j - 1)
                elev[i, j] = elev_fun(lon[i, j], lat[i, j])
            end
        end
        t = TerrainMap(lat, lon, elev)
        t
    end

    @testset "basic" begin
        t = get_terrain()
        @test x_max(t) == 10
        @test y_max(t) == 15
        @test width(t) == 8
        @test height(t) == 12
    end

    @testset "point_to_index" begin
        t = get_terrain()

        @testset "inside cell" begin
            # First row
            @test point_to_index(t, 3, 5) == [1, 1]
            @test point_to_index(t, 4.5, 4.5) == [1, 2]
            @test point_to_index(t, 7, 5.5) == [1, 3]
            @test point_to_index(t, 9.5, 4) == [1, 4]
            # Second row
            @test point_to_index(t, 3, 7) == [2, 1]
            @test point_to_index(t, 4.5, 7) == [2, 2]
            @test point_to_index(t, 7.5, 7) == [2, 3]
            @test point_to_index(t, 9.5, 7) == [2, 4]
            # Third row
            @test point_to_index(t, 3, 10) == [3, 1]
            @test point_to_index(t, 4.5, 10) == [3, 2]
            @test point_to_index(t, 7.5, 10) == [3, 3]
            @test point_to_index(t, 9.5, 10) == [3, 4]
            # Third row
            @test point_to_index(t, 3, 14) == [4, 1]
            @test point_to_index(t, 4.5, 14) == [4, 2]
            @test point_to_index(t, 7.5, 14) == [4, 3]
            @test point_to_index(t, 9.5, 14) == [4, 4]
        end

        @testset "on edge" begin
            # Bottom horzinotnal edges edges
            @test point_to_index(t, 3, 3) == [1, 1]
            @test point_to_index(t, 5, 3) == [1, 2]
            @test point_to_index(t, 7, 3) == [1, 3]
            @test point_to_index(t, 9, 3) == [1, 4]

            # Middle horizontal egdes
            @test point_to_index(t, 3, 6) == [2, 1]
            @test point_to_index(t, 5, 9) == [3, 2]
            @test point_to_index(t, 7, 12) == [4, 3]
            @test point_to_index(t, 9, 9) == [3, 4]

            # Top horizontal egdess
            @test point_to_index(t, 3, 15) == [4, 1]
            @test point_to_index(t, 5, 15) == [4, 2]
            @test point_to_index(t, 7, 15) == [4, 3]
            @test point_to_index(t, 9, 15) == [4, 4]

            # Left vertical edges edges
            @test point_to_index(t, 2, 4) == [1, 1]
            @test point_to_index(t, 2, 7) == [2, 1]
            @test point_to_index(t, 2, 10) == [3, 1]
            @test point_to_index(t, 2, 13) == [4, 1]

            # Middle vertical egdes
            @test point_to_index(t, 4, 4) == [1, 2]
            @test point_to_index(t, 6, 7) == [2, 3]
            @test point_to_index(t, 8, 10) == [3, 4]
            @test point_to_index(t, 8, 4) == [1, 4]

            # Right vertical egdess
            @test point_to_index(t, 10, 4) == [1, 4]
            @test point_to_index(t, 10, 7) == [2, 4]
            @test point_to_index(t, 10, 10) == [3, 4]
            @test point_to_index(t, 10, 13) == [4, 4]
        end

        @testset "on vertex" begin
            # First row
            @test point_to_index(t, 2, 3) == [1, 1]
            @test point_to_index(t, 4, 3) == [1, 2]
            @test point_to_index(t, 6, 3) == [1, 3]
            @test point_to_index(t, 8, 3) == [1, 4]
            @test point_to_index(t, 10, 3) == [1, 4]

            # Second row
            @test point_to_index(t, 2, 6) == [2, 1]
            @test point_to_index(t, 4, 6) == [2, 2]
            @test point_to_index(t, 6, 6) == [2, 3]
            @test point_to_index(t, 8, 6) == [2, 4]
            @test point_to_index(t, 10, 6) == [2, 4]

            # Third row2
            @test point_to_index(t, 2, 9) == [3, 1]
            @test point_to_index(t, 4, 9) == [3, 2]
            @test point_to_index(t, 6, 9) == [3, 3]
            @test point_to_index(t, 8, 9) == [3, 4]
            @test point_to_index(t, 10, 9) == [3, 4]

            # Fourth row
            @test point_to_index(t, 2, 12) == [4, 1]
            @test point_to_index(t, 4, 12) == [4, 2]
            @test point_to_index(t, 6, 12) == [4, 3]
            @test point_to_index(t, 8, 12) == [4, 4]
            @test point_to_index(t, 10, 12) == [4, 4]

            # Fifth row
            @test point_to_index(t, 2, 15) == [4, 1]
            @test point_to_index(t, 4, 15) == [4, 2]
            @test point_to_index(t, 6, 15) == [4, 3]
            @test point_to_index(t, 8, 15) == [4, 4]
            @test point_to_index(t, 10, 15) == [4, 4]
        end

        @testset "outside map" begin
            @test_throws DomainError point_to_index(t, 1, 2)   # left-below
            @test_throws DomainError point_to_index(t, 11, 2)  # right-below
            @test_throws DomainError point_to_index(t, 1, 16)  # left-above
            @test_throws DomainError point_to_index(t, 11, 16) # right-above
            @test_throws DomainError point_to_index(t, 6, 2)   # below
            @test_throws DomainError point_to_index(t, 7, 2)   # below
            @test_throws DomainError point_to_index(t, 1, 9)   # left
            @test_throws DomainError point_to_index(t, 1, 10)  # left
            @test_throws DomainError point_to_index(t, 11, 9)  # right
            @test_throws DomainError point_to_index(t, 11, 10) # right
            @test_throws DomainError point_to_index(t, 6, 16)   # above
            @test_throws DomainError point_to_index(t, 7, 16)   # above
            @test_throws DomainError point_to_index(t, 7, -1)   # sth negative
        end
    end

    @testset "index_to_point" begin
        t = get_terrain()

        @test index_to_point(t, 1, 1) == [2, 3]
        @test index_to_point(t, 1, 2) == [4, 3]
        @test index_to_point(t, 1, 3) == [6, 3]
        @test index_to_point(t, 1, 4) == [8, 3]
        @test index_to_point(t, 1, 5) == [10, 3]

        @test index_to_point(t, 2, 1) == [2, 6]
        @test index_to_point(t, 2, 2) == [4, 6]
        @test index_to_point(t, 2, 3) == [6, 6]
        @test index_to_point(t, 2, 4) == [8, 6]
        @test index_to_point(t, 2, 5) == [10, 6]

        @test index_to_point(t, 3, 1) == [2, 9]
        @test index_to_point(t, 3, 2) == [4, 9]
        @test index_to_point(t, 3, 3) == [6, 9]
        @test index_to_point(t, 3, 4) == [8, 9]
        @test index_to_point(t, 3, 5) == [10, 9]

        @test index_to_point(t, 4, 1) == [2, 12]
        @test index_to_point(t, 4, 2) == [4, 12]
        @test index_to_point(t, 4, 3) == [6, 12]
        @test index_to_point(t, 4, 4) == [8, 12]
        @test index_to_point(t, 4, 5) == [10, 12]

        @test index_to_point(t, 5, 1) == [2, 15]
        @test index_to_point(t, 5, 2) == [4, 15]
        @test index_to_point(t, 5, 3) == [6, 15]
        @test index_to_point(t, 5, 4) == [8, 15]
        @test index_to_point(t, 5, 5) == [10, 15]

        @test_throws DomainError index_to_point(t, 0, 0)
        @test_throws DomainError index_to_point(t, 6, 0)
        @test_throws DomainError index_to_point(t, 0, 6)
        @test_throws DomainError index_to_point(t, 6, 6)
        @test_throws DomainError index_to_point(t, 3, 0)
        @test_throws DomainError index_to_point(t, 0, 3)
        @test_throws DomainError index_to_point(t, 6, 3)
        @test_throws DomainError index_to_point(t, 3, 6)
    end

    @testset "point_to_index_coords" begin
        t = get_terrain()
        @test point_to_index_coords(t, 2, 3) == [1, 1]
        @test point_to_index_coords(t, 2, 15) == [5, 1]
        @test point_to_index_coords(t, 10, 3) == [1, 5]
        @test point_to_index_coords(t, 10, 15) == [5, 5]

        @test point_to_index_coords(t, 6, 9) == [3, 3]
        @test point_to_index_coords(t, 6, 10.5) == [3.5, 3]
        @test point_to_index_coords(t, 7, 9) == [3, 3.5]
        @test point_to_index_coords(t, 7, 10.5) == [3.5, 3.5]
    end

    @testset "barycentric" begin
        t = get_terrain()
        @test TerrainGraphs.barycentric(t, [5, 7.5]) == fill(1 / 4, 4)
        @test TerrainGraphs.barycentric(t, [2.5, 6.75]) ==
              [0.75 * 0.75, 0.75 * 0.25, 0.25 * 0.25, 0.25 * 0.75]
        @test TerrainGraphs.barycentric(t, [5.5, 8.25]) ==
              [0.25 * 0.25, 0.25 * 0.75, 0.75 * 0.75, 0.25 * 0.75]
        @test TerrainGraphs.barycentric(t, [5.5, 8.25]) ==
              [0.25 * 0.25, 0.25 * 0.75, 0.75 * 0.75, 0.25 * 0.75]
    end

    @testset "real_elevation" begin
        aux_f_not_simple(x, y) = 2x - pi * y + sqrt(2)
        aux_f_not_simple(p::AbstractVector) = aux_f_not_simple(p[1], p[2])

        @testset "simple terrain" begin
            aux_f(x, y) = x + y
            aux_f(p::AbstractVector) = aux_f(p[1], p[2])
            t = get_terrain(aux_f)

            p = [2.6978391245, pi]
            @test real_elevation(t, p) ≈ aux_f(p)
            p = [8, 12]
            @test real_elevation(t, p) ≈ aux_f(p)
            p = [8, 10.5]
            @test real_elevation(t, p) ≈ aux_f(p)
            p = [6.23, 12]
            @test real_elevation(t, p) ≈ aux_f(p)
            p = [2, 3]
            @test real_elevation(t, p) ≈ aux_f(p)

            for p in eachrow(3 .+ 7 .* rand(20, 2))
                @test real_elevation(t, p) ≈ aux_f(p)
            end
        end

        @testset "more comlex terrain" begin
            aux_f(x, y) = 2x - pi * y + sqrt(2)
            aux_f(p::AbstractVector) = aux_f(p[1], p[2])
            t = get_terrain(aux_f)

            p = [2.6978391245, pi]
            @test real_elevation(t, p) ≈ aux_f(p)
            p = [8, 12]
            @test real_elevation(t, p) ≈ aux_f(p)
            p = [8, 10.5]
            @test real_elevation(t, p) ≈ aux_f(p)
            p = [6.23, 12]
            @test real_elevation(t, p) ≈ aux_f(p)
            p = [2, 3]
            @test real_elevation(t, p) ≈ aux_f(p)

            for p in eachrow(3 .+ 7 .* rand(20, 2))
                @test real_elevation(t, p) ≈ aux_f(p)
            end
        end
    end
end
