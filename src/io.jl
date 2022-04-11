import ArchGDAL as AG

"""
    load_tiff(filename)

Loads tiff file as TerrainMap.
"""
function load_tiff(filename::String)::TerrainMap
    dataset = AG.readraster(filename)
    band = AG.getband(dataset, 1)
    gt = AG.getgeotransform(dataset)
    start_x = gt[1]
    start_y = gt[4]
    step_x = gt[2]
    step_y = gt[6]
    nx = AG.width(dataset)
    ny = AG.height(dataset)
    M = transpose(band)
    if step_x < 0
        start_x = start_x + (nx-1) * step_x
        step_x = -step_x
        M = reverse(M, dims=2)
    end
    if step_y < 0
        start_y = start_y + (ny-1) * step_y
        step_y = -step_y
        M = reverse(M, dims=1)
    end
    TerrainMap(M, start_x, start_y, step_x, step_y, nx, ny)
end
