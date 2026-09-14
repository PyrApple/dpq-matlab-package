function [region, regionStr] = getSphereRegions(xyz, flagMethod)

% xyz is Nx3 cartesian position 
% flagMethod is a string, used to define the method used to flag regions of
% the sphere
% 
% assumes x positive is fwd, y positive is left, z positive is up (subject
% is always facing +x)

% get list of available flag methods
if( nargin == 0 )
    region = {'leftright', 'fourfrontback', 'ninemiddle', 'homogeneous10'};
    return
end

% sanity check
if( size(xyz, 2) ~= 3 ); error('expected Nx3 vector'); end


switch flagMethod

    
%% left-right
% split the sphere based on left / right position of xyz

case 'leftright'
    
    % define regions
    selVectL = xyz(:,2) > 0;
    selVectR = ~selVectL;
    
    % output id of region type
    region = nan(size(xyz, 1), 1);
    region(selVectL) = 0;
    region(selVectR) = 1;
    
    % output strings of region type
    regionStr = cell(size(region));
    regionStr(selVectL) = {'left'};
    regionStr(selVectR) = {'right'};
    
%% front-up, front-down, back-up, back-down

case 'fourfrontback'

    % define regions
    selVectFront = xyz(:,1) > 0; 
    selVectBack = ~selVectFront; 
    selVectUp = xyz(:,3) > 0; 
    selVectDown = ~selVectUp;
    
    % output id of region type
    region = nan(size(xyz, 1), 1);
    region(selVectUp & selVectFront) = 0;
    region(selVectUp & selVectBack) = 1;
    region(selVectDown & selVectFront) = 2;
    region(selVectDown & selVectBack) = 3;
    
    % output strings of zone type
    regionStr = cell(size(region));
    regionStr(region == 0) = {'front-up'};
    regionStr(region == 1) = {'back-up'};
    regionStr(region == 2) = {'front-down'};
    regionStr(region == 3) = {'back-down'};

%% front-up, front-down, back-up, back-down

case 'ninemiddle'
    
    % init local
    % aed = dpq.coord.cart2sph(xyz);
    xyzNorm = xyz./ repmat(sqrt(sum(xyz.^2, 2)), 1, 3);
    
    % define regions
    o = sind(20);
    selVectFront = xyzNorm(:, 1) >= o;
    selVectBack = xyzNorm(:, 1) <= -o;
    selVectUp = xyzNorm(:, 3) >= o;
    selVectDown = xyzNorm(:, 3) <= -o;
    
    % output id of region type
    region = nan(size(xyz, 1), 1);
    region(selVectFront & selVectUp) = 0;
    region(selVectFront & ~(selVectUp | selVectDown)) = 1;
    region(selVectFront & selVectDown) = 2;
    region( ~(selVectFront | selVectBack) & selVectUp ) = 3;
    region( ~(selVectFront | selVectBack | selVectUp | selVectDown) ) = 4;
    region( ~(selVectFront | selVectBack) & selVectDown ) = 5;
    region(selVectBack & selVectUp) = 6;
    region(selVectBack & ~(selVectUp | selVectDown)) = 7;
    region(selVectBack & selVectDown) = 8;
    
    % output strings of zone type
    regionStr = cell(size(region));
    regionStr(region == 0) = {'front-up'};
    regionStr(region == 1) = {'front-mid'};
    regionStr(region == 2) = {'front-down'};
    regionStr(region == 3) = {'mid-up'};
    regionStr(region == 4) = {'mid-lr'};
    regionStr(region == 5) = {'mid-down'};
    regionStr(region == 6) = {'back-up'};
    regionStr(region == 7) = {'back-mid'};
    regionStr(region == 8) = {'back-down'};

case 'homogeneous10'
    
    % init locals
    xyzGrid = dpq.alet.getUniformSphereGrid(13);

    % remove below certain elevation angle
    aedGrid = dpq.coord.cart2sph(xyzGrid);
    selVect = aedGrid(:, 2) < -45;
    selVect = selVect | aedGrid(:, 2) > 60;
    xyzGrid = xyzGrid(~selVect, :);
    
    % project xyz on sphere of radius 1
    aed = dpq.coord.cart2sph(xyz);
    aed(:, 3) = 1;
    xyz = dpq.coord.sph2cart(aed);

    % assign nearest neighbor indices
    region = zeros(size(xyz, 1), 1);
    for iPos = 1:size(xyz, 1)
        
        % nearest neighbor based on cart. distance
        % dist = sum( sqrt((xyzGrid - xyz(iPos, :)).^2), 2 );
        % [~, id] = min(dist);
        
        % nearest neighbor based on gc distance
        gc = dpq.alet.getGreatCircleAngle(xyzGrid, repmat(xyz(iPos, :), size(xyzGrid, 1), 1));
        [~, id] = min(gc);

        region(iPos) = id-1;

    end

    regionStr = arrayfun(@num2str, region, 'UniformOutput', 0);

    
%% default is error

otherwise

error('undefined flagMethod: %s', flagMethod);

end

%% sanity check 

% check underlap
if( any( isnan( region ) ) ); error('some points are not processed'); end

return 


%% debug function: plot polar regions

% create fake positions
n = 40000;
xyz = rand(n, 3)-0.5; aed = dpq.coord.cart2sph(xyz); aed(:, 3) = 1; xyz = dpq.coord.sph2cart(aed);
% inter = [ 180*rand(n,1) - 90, 360*rand(n,1) - 90, ones(n,1) ]; aed = dpq.coord.inter2sph(inter); xyz = dpq.coord.inter2cart(inter);

% compute region type
% [region, regionStr] = dpq.alet.getSphereRegions(xyz, 'leftright');
% [region, regionStr] = dpq.alet.getSphereRegions(xyz, 'fourfrontback');
% [region, regionStr] = dpq.alet.getSphereRegions(xyz, 'ninemiddle');
[region, regionStr] = dpq.alet.getSphereRegions(xyz, 'homogeneous10');

% plot
% regionColors = [ 0.6 0.6 0.6; 1 0 0; 0 1 0; 0 0 1; 0 0 0; 1 1 0; 0 1 1; 1 0 1; .5 .5 1];
% cmap = regionColors(region+1,:);
cmap = summer(max(region)+1); cmap = cmap(region+1);
scatter(aed(:,1), aed(:,2), 5, cmap, 'filled');

% format
axis equal
grid on
xticks(-180:45:180); yticks(-90:45:90);
xlabel('azim (deg)');
ylabel('elev (deg)');

% title(sprintf('lateral angle (deg): %d', lat));

%% debug function: 3D plot regions

% create fake positions
n = 100000;
xyz = rand(n, 3)-0.5; aed = dpq.coord.cart2sph(xyz); aed(:, 3) = 1;
% aed = [ 360*rand(n,1) - 180, 180*rand(n,1) - 90, ones(n,1) ];
xyz = dpq.coord.sph2cart(aed);

% compute region type
% [region, regionStr] = dpq.alet.getSphereRegions(xyz, 'leftright');
% [region, regionStr] = dpq.alet.getSphereRegions(xyz, 'fourfrontback');
% [region, regionStr] = dpq.alet.getSphereRegions(xyz, 'ninemiddle');
[region, regionStr] = dpq.alet.getSphereRegions(xyz, 'homogeneous10');

% % debug: reduce data
% selVect = region == 0;
% sum(selVect)
% regionStr = regionStr(selVect);
% region = region(selVect);
% xyz = xyz(selVect,:);

% plot interaural spawn vs hit
% regionColors = [ 0.6 0.6 0.6; 1 0 0; 0 1 0; 0 0 1; 0 0 0; 1 1 0; 0 1 1; 1 0 1; .5 .5 1];
% cmap = regionColors(region+1,:);
cmap = summer(max(region)+1); cmap = cmap(region+1);
scatter3(xyz(:,1), xyz(:,2), xyz(:,3), 20, cmap, 'filled', 'HandleVisibility', 'off');
hold on,
plot3(1.2, 0, 0, 'ok', 'MarkerSize', 30, 'MarkerFaceColor', [1 1 1], 'LineWidth', 2); % user forward
hold off

% format
xlabel('x (+fwd)'); ylabel('y (+left)'); zlabel('z (+up)');
axis equal, rotate3d on, grid on, 
view([140 24]);
legend({'usr fwd'});
% view([180 0]);

% title(sprintf('lateral angle (deg): %d', 60));

