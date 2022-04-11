struct TerrainSphereSpec <: AbstractSpec
    radius::Real
    terrain_map::TerrainMap
end

const TerrainSphereGraph = MeshGraph{TerrainSphereSpec}

TerrainSphereGraph(radius::Real, terrain_map::TerrainMap) =
    MeshGraph(TerrainSphereSpec(radius, terrain_map))


TerrainSphereGraph(terrain_map::TerrainMap) =
    TerrainSphereGraph(6371000, terrain_map))   # Earth's radius

function TerrainSphereGraph(sphere_graph::SphereGraph)

end
