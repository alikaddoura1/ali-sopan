[latroi, longroi] = regionOfInterest(32.234884, -110.953670,100);
display(latroi)
display(longroi)

[latGrid, longGrid] = getGrid(32.234884, -110.953670,100, 8);


filename = "map (4).osm";

buildings = readgeotable(filename,Layer="buildingparts");

basemapName = "osm";

figure
geobasemap(basemapName)
geoplot(buildings,FaceColor="#808080",FaceAlpha=1)
geotickformat dd


latROI = latroi;
lonROI = longroi;

latROI(end+1) = latROI(1);
lonROI(end+1) = lonROI(1);
ROI = geopolyshape(latROI,lonROI);

hold on
geoplot(ROI,FaceColor="m",FaceAlpha=0.2,EdgeColor="m",LineWidth=2)

[latmin,latmax] = bounds(latROI);
[lonmin,lonmax] = bounds(lonROI);

shape = buildings.Shape;
clipped = geoclip(shape,[latmin latmax],[lonmin,lonmax]);

idxInsideROI = clipped.NumRegions > 0;
buildingsROI = buildings(idxInsideROI,:);

figure
geobasemap(basemapName)
geoplot(buildingsROI,FaceColor="#808080",FaceAlpha=1)

viewer = siteviewer(Buildings=buildingsROI,Basemap=basemapName);


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

% Display the result grid
disp(latGrid);
disp(longGrid);

% 
% interactivelySelectBuildings = false;
% if interactivelySelectBuildings
%     [latGlass,lonGlass] = ginput(1); 
%     [latBrick,lonBrick] = ginput(1); 
%     [latMetal,lonMetal] = ginput(1); 
% else
%     latGlass = 32.23723;
%     lonGlass = -110.95423;
%     latBrick = 32.23326;
%     lonBrick = -110.954333;
%     latMetal = 32.23329;
%     lonMetal = -110.954333;
% end
% 
% pointGlass = geopointshape(latGlass,lonGlass);
% pointBrick = geopointshape(latBrick,lonBrick);
% pointMetal = geopointshape(latMetal,lonMetal);


% for row = 1:height(buildingsROI)
%     bldg = buildingsROI.Shape(row); 
%     if isinterior(bldg,pointGlass)
%         buildingsROI.Material(row) = "glass";
%         buildingsROI.Color(row) = "#35707E";
%     elseif isinterior(bldg,pointMetal)
%         buildingsROI.Material(row) = "metal";
%         buildingsROI.Color(row) = "#151513";
%     elseif isinterior(bldg,pointBrick)
%     buildingsROI.Material(row) = "brick";
%     buildingsROI.Color(row) = "#AA4A44";
%     else 
%         buildingsROI.Material(row) = "concrete";
%         buildingsROI.Color(row) = "#808080";
%     end
% end



% Find indices where latGrid and longGrid are not NaN
validPoints = ~isnan(latGrid) & ~isnan(longGrid);

latGrid = latGrid(validPoints);
longGrid = longGrid(validPoints);

% Create txsite 
tx = txsite(Latitude=latGrid, Longitude=longGrid);

% rx = rxsite(Latitude=latGrid,Longitude=-110.953647);

% pm = propagationModel("raytracing",MaxNumReflections=3);
% 
% rxLatitudes = 32.234935:0.0005:32.235761;
% rxLongitutes = -110.953690:0.0005:-110.952899;
% 
% rays = raytrace(tx,rx,pm);
% rays= rays{1};

show(tx);
% show(rx);
% plot(rays);




