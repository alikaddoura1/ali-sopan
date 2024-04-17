function [latGrid, longGrid] = getGrid(lat, long, distance, size)

    % This is Region of Interest
    [latROI, longROI] = regionOfInterest(lat, long, distance);
    
    % Calculate the number of divisions for the grid
    divisions = size;
    
    % Calculate the distance between grid points
    lat_step = (latROI(4) - latROI(1)) / (divisions - 1);
    long_step = (longROI(2) - longROI(1)) / (divisions - 1);
    
    % Generate the grid
    latGrid = zeros(1, divisions);
    longGrid = zeros(1, divisions);
    
    for i = 1:divisions
        for j = 1:divisions
            latGrid((i-1)*divisions + j) = latROI(1) + (i - 1) * lat_step;
            longGrid((i-1)*divisions + j) = longROI(1) + (j - 1) * long_step;
        end
    end
    
end

