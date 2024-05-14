[latroi, longroi] = regionOfInterest(32.234884, -110.953670,100);

[latGrid, longGrid] = getGrid(32.234884, -110.953670,100, 64);

filename = "map (4).osm";

buildings = readgeotable(filename,Layer="buildingparts");

% basemapName = "osm";
basemapName = "openstreetmap";

latROI = latroi;
lonROI = longroi;

[latmin,latmax] = bounds(latROI);
[lonmin,lonmax] = bounds(lonROI);

shape = buildings.Shape;
clipped = geoclip(shape,[latmin latmax],[lonmin,lonmax]);

idxInsideROI = clipped.NumRegions > 0;
buildingsROI = buildings(idxInsideROI,:);


viewer = siteviewer("Buildings", buildingsROI,"Basemap",basemapName);


% Iterate through each point
for i = 1:numel(latGrid)

    point = geopointshape(latGrid(i),longGrid(i));
   
    % building check
    for j = 1:size(buildingsROI) 
        building = buildingsROI.Shape(j);
        if isinterior(building, point)
            latGrid(i) = NaN;
            longGrid(i) = NaN;
            break;
        end
    end
end


% Iterate through each point
for i = 1:numel(latGrid)

    point = geopointshape(latGrid(i),longGrid(i));

    % building check if building exist remove that point
    for j = 1:size(buildingsROI) 
        building = buildingsROI.Shape(j);
        if isinterior(building, point)
            latGrid(i) = NaN;
            longGrid(i) = NaN;
            break;
        end
    end
end


% remove the nans
validPoints = ~isnan(latGrid) & ~isnan(longGrid);

latGrid = latGrid(validPoints);
longGrid = longGrid(validPoints);


% Propagation model and signal strength calculation
% pm = propagationModel("raytracing");
% sSD = phased.ShortDipoleAntennaElement;
% sURA = phased.URA('Element',sSD,'Size',[16 16]);
% 
% % tx and rx site
% tx = txsite(Latitude=latGrid(6), Longitude=longGrid(6), TransmitterFrequency=28e9, Antenna=sURA, AntennaAngle=90);
% rxs = rxsite(Latitude=latGrid, Longitude=longGrid);
% raytrace(tx,rxs, pm);

fc = 28e9;
ueAntSize = [2 2];                      % number of rows and columns in rectangular array (UE).
ueArrayOrientation = [-90 0].';         % azimuth (0 deg is East, 90 deg is North) and elevation (positive points upwards)  in deg
reflectionsOrder = 2;                   % number of reflections for ray tracing analysis (0 for LOS)
c = physconst('LightSpeed');
lambda = c/fc;

% tx = txsite("Name","100 GHz BS", ...
%     "CoordinateSystem","geographic",...
%     "Latitude",latGrid(i), ...
%     "Longitude",longGrid(i), ...
%     "AntennaHeight",5, ...
%     "TransmitterPower",5, ...
%     "TransmitterFrequency",fc);
% show(tx)

% tx.Antenna = arrayDesign(fc,8,8);


% Configuring propagation model
pm = propagationModel("raytracing", ...
    "Method","sbr", ...
    "CoordinateSystem","geographic",...
    "MaxNumReflections",1, ...
    "BuildingsMaterial","perfect-reflector", ...
    "TerrainMaterial","perfect-reflector",...
    "AngularSeparation","low",...
    "MaxRelativePathLoss", Inf);

rxs = rxsite("CoordinateSystem","geographic",...
        "Latitude",latGrid,...
        "Longitude",longGrid, ...
        "AntennaHeight",1.5,...
        "AntennaAngle",ueArrayOrientation);
        % "Antenna",arrayDesign(fc,2,2));

% coverage(tx,pm, ...
%     SignalStrengths=-120:-5, ...
%     MaxRange=250, ...
%     Resolution=3, ...
%     Transparency=0.6)


% setBSsteeringVector(fc,-90,tx);
folderPath = 'data';

for i = 1: numel(longGrid)
    tx = txsite("Name","100 GHz BS", ...
    "CoordinateSystem","geographic",...
    "Latitude",latGrid(i), ...
    "Longitude",longGrid(i), ...
    "AntennaHeight",5, ...
    "TransmitterPower",5, ...
    "TransmitterFrequency",fc);

     ss = sigstrength(rxs,tx,pm);

    ss(ss == -Inf) = NaN;
    
    % 
    % resolution
    resolution = 100;
    
    
    % Grid for image pixels
    [latGridImage, lonGridImage] = meshgrid(linspace(latmin, latmax, resolution), ...
                                            linspace(lonmin, lonmax, resolution));
    % matc sigstrength to grid point
    ssGrid = griddata(latGrid, longGrid, ss, latGridImage, lonGridImage);
    
    ssGrid = rot90(ssGrid);
    
    figure;
    imagesc( ssGrid);
    colorbar;
    hold on;
    
    show(tx)

    filename = fullfile(folderPath, sprintf('SignalStrength_Image_%d.png', i));
    saveas(gcf, filename);
    close(gcf);
end


% function setBSsteeringVector(fc,az,txSite)
%     steeringVector = phased.SteeringVector("SensorArray",txSite.Antenna);
%     sv = steeringVector(fc,[az;0]);
%     txSite.Antenna.Taper = conj(sv);
% end

