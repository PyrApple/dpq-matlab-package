function [region, regionStr] = getSphereRegions(xyz, flagMethod)

% xyz is Nx3 cartesian position 
% flagMethod is a string, used to define the method used to flag regions of
% the sphere
% 
% assumes x positive is fwd, y positive is left, z positive is up (subject
% is always facing +x)

% get list of available flag methods
if( nargin == 0 )
    region = {'leftright', 'fourfrontback'};
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
n = 100000;
inter = [ 180*rand(n,1) - 90, 360*rand(n,1) - 90, ones(n,1) ];
aed = inter2sphVect(inter);
xyz = inter2cartVect(inter);

% compute region type
[region, regionStr] = getSphereRegions(xyz, 'leftright');
[region, regionStr] = getSphereRegions(xyz, 'fourfrontback');

% plot
regionColors = [ 0.6 0.6 0.6; 1 0 0; 0 1 0; 0 0 1; 0 0 0];
cmap = regionColors(region+1,:);
scatter(aed(:,1), aed(:,2), 5, cmap, 'filled');

% format
axis equal
grid on
xticks(-180:45:180); yticks(-90:45:90);
xlabel('azim (deg)');
ylabel('elev (deg)');

% title(sprintf('lateral angle (deg): %d', lat));

%% debug function: check confusions by types on 3D sphere

% create fake positions
n = 100000;
aed = [ 360*rand(n,1) - 180, 180*rand(n,1) - 90, ones(n,1) ];
xyz = sph2cartVect(aed);

% compute region type
% [region, regionStr] = getSphereRegions(xyz, 'leftright');
[region, regionStr] = getSphereRegions(xyz, 'fourfrontback');

% plot interaural spawn vs hit
regionColors = [ 0.6 0.6 0.6; 1 0 0; 0 1 0; 0 0 1; 0 0 0];
cmap = regionColors(region+1,:);
scatter3(xyz(:,1), xyz(:,2), xyz(:,3), 6, cmap, 'filled', 'HandleVisibility', 'off');
hold on,
scatter3(1, 0, 0, 1000, [0 1 1], 'filled'); % user forward
hold off

% format
xlabel('x (+fwd)'); ylabel('y (+left)'); zlabel('z (+up)');
axis equal, rotate3d on, grid on, 
view([140 24]);
legend({'usr fwd'});
% view([180 0]);

% title(sprintf('lateral angle (deg): %d', 60));

