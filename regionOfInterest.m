function [latROI, longROI] = regionOfInterest(lat, long, distance)
    % Convert meters to degrees for latitude
    lat_deg_per_meter = 1 / 111.32e3; % Approximation at the equator
    lat_offset = distance * lat_deg_per_meter;
    
    % Calculate longitudinal distance per degree of latitude
    long_deg_per_meter = 1 / (111.32e3 * cosd(lat)); % Approximation
    
    % Convert meters to degrees for longitude
    long_offset = distance * long_deg_per_meter;
    
    % Define the four points of the rectangular ROI
    % Point 1 (bottom left)
    latROI(1) = lat;
    longROI(1) = long;
    
    % Point 2 (bottom right)
    latROI(2) = lat;
    longROI(2) = long + long_offset;
    
    % Point 3 (top right)
    latROI(3) = lat + lat_offset;
    longROI(3) = long + long_offset;
    
    % Point 4 (top left)
    latROI(4) = lat + lat_offset;
    longROI(4) = long;

    latROI = latROI(:); 
    longROI = longROI(:);
end
