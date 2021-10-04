function [s] = getErrors(spawn, hit)

% xyzA and xyzB are Nx3 cartesian coordinates

% sanity check
if( ~isequal( size(spawn), size(hit) ) ); error('different input sizes'); end
if( size(spawn, 2) ~= 3 ); error('expected Nx3 vector'); end

% init locals
s = struct();

% coordinate convert
spawnInter = dpq.coord.cart2inter( spawn ); spawnSph = dpq.coord.cart2sph( spawn );
hitInter = dpq.coord.cart2inter( hit ); hitSph = dpq.coord.cart2sph( hit );

% signed interaural error
getErrorInterSigned = @(spawnInter, hitInter) ( wrapTo180(spawnInter(:,1:2) - hitInter(:,1:2)) );
s.errorInterSigned = getErrorInterSigned(spawnInter, hitInter);
s.errorInter = abs( s.errorInterSigned );

% signed interaural error + folding to ease overshoot / undershoot analysis
%
% define regions
front = spawn(:,1) > 0; up = spawn(:,3) > 0; left = spawn(:,2) > 0;
back = ~front; down = ~up; % right = ~left;
%
% fold lateral angle (so that >0 is overshoot for both left and right)
% errorInterSigned = s.errorInterSigned;
% errorInterSigned(left, 1) = -errorInterSigned(left, 1);
%
% % fold polar angle (so that >0 is overshoot wrt 0° everywhere) DISCARDED
% errorInterSigned(front & up, 2) = -errorInterSigned(front & up, 2);
% errorInterSigned(back & down, 2) = -errorInterSigned(back & down, 2);
%
% save to locals
s.errorInterSignedFolded = abs(spawnInter(:,1:2)) - abs(hitInter(:,1:2));

% spherical error
getErrorSphSigned = @(spawnSph, hitSph) ( wrapTo180(spawnSph(:,1:2) - hitSph(:,1:2)) );
s.errorSphSigned = getErrorSphSigned(spawnSph, hitSph);
s.errorSph = abs(s.errorSphSigned);

% signed spherical error + folding to ease overshoot / undershoot analysis
% errorSphSignedFolded = s.errorSphSigned;
% errorSphSignedFolded(up, 2) = -errorSphSignedFolded(up, 2);
% s.errorSphSignedFolded = errorSphSignedFolded;
s.errorSphSignedFolded = abs(hitSph(:,1:2)) - abs(spawnSph(:,1:2));

% confusions
confusion = struct(); confusionStr = struct();
confusionMethods = dpq.alet.getConfusionType();
for iMethod = 1:length(confusionMethods)
    method = confusionMethods{iMethod};
    [typeId, typeStr] = dpq.alet.getConfusionType( spawn, hit,method );
    confusion.(method) = typeId;
    confusionStr.(method) = typeStr;
end
s.confusion = confusion;
s.confusionStr = confusionStr;
% [s.confusionType, s.confusionTypeStr] = getConfusionType( spawn, hit, 'interaural' );

% great circle error
s.greatCircAngle = dpq.alet.getGreatCircleAngle( spawn, hit );

% resolved (based on confusions) hit error
resolved = struct();
for iMethod = 1:length(confusionMethods)
    
    % init locals
    hitResolved = hit;
    method = confusionMethods{iMethod};
    confusionStr = s.confusionStr.(method);
    
    % up-down confusions: z symmetry
    selVect = contains( confusionStr, 'up-down' );
    hitResolved( selVect, 3 ) = - hitResolved( selVect, 3 );

    % front-back confusions: x symmetry
    selVect = contains( confusionStr, 'front-back' );
    hitResolved( selVect, 1 ) = - hitResolved( selVect, 1 );
    
    % DISCARDED: you can't resolve "combined" (they are just wrong)
    % % combined confusions: x&z symmetry
    % selVect = contains( confusionStr, 'combined' );
    % hitResolved( selVect, 1 ) = - hitResolved( selVect, 1 );
    % hitResolved( selVect, 3 ) = - hitResolved( selVect, 3 );
    % % warning('debug ');
    % % hitCorrected( selVect, : ) = spawn(selVect, :);
    
    % compute new errors
    greatCircAngle = dpq.alet.getGreatCircleAngle( spawn, hitResolved );
    errorInterSigned = getErrorInterSigned(spawnInter, dpq.coord.cart2inter(hitResolved));
    errorSphSigned = getErrorSphSigned(spawnSph, dpq.coord.cart2sph(hitResolved));
    
    % save to locals
    resolved.(method).greatCircAngle = greatCircAngle;
    resolved.(method).errorInterSigned = errorInterSigned;
    resolved.(method).errorInter = abs(errorInterSigned);
    resolved.(method).errorSphSigned = errorSphSigned;
    resolved.(method).errorSph = abs(errorSphSigned);
end

% save to local
s.resolved = resolved;

% compute sphere regions for spawned source
region = struct(); regionStr = struct();
regionMethods = dpq.alet.getSphereRegions();
for iMethod = 1:length(regionMethods)
    method = regionMethods{iMethod};
    [typeId, typeStr] = dpq.alet.getSphereRegions( spawn, method );
    region.(method) = typeId;
    regionStr.(method) = typeStr;
end
s.region = region;
s.regionStr = regionStr;

return 


%% debug angle metrics

% define grid (sphere)
step = 1;
azim = -180:step:180;
elev = -89:step:90;
dist = 1;
tmp = repmat(elev, length(azim), 1); tmp = tmp(:);
aed = [ repmat(azim', length(elev), 1)  tmp  dist*ones(length(azim) * length(elev), 1) ];

% define reference point
aedRef = [45 45 1.1];
aedRef = repmat(aedRef, size(aed, 1), 1);

% convert
hit = dpq.coord.sph2cart( aed );
spawn = dpq.coord.sph2cart( aedRef );

% test method
s = dpq.alet.getErrors(spawn, hit);

% define attribute to test
attrVect = s.greatCircAngle;
attrVect = s.errorInterSigned(:, 2);
% attrVect = s.errorSphSigned(:, 1);
attrVect = s.resolved.poirier.greatCircAngle;

% select data
selVect = 1:length(s.greatCircAngle); % dummy (all)
% selVect = selVect & contains(s.confusionStr.zagala, {'precision', 'front-back'});

% apply select data
attrVect = attrVect(selVect);
hit = hit(selVect, :);
spawn = spawn(selVect, :);

% % histogram
% histogram(s.greatCircAngle)
% hold on, 
% histogram(s.corrected.zagala.greatCircAngle)
% hold off, 
% return 

% create cmap
cmap = jet(180);
cmapIds = floor( normalize(attrVect, 'range') * (size(cmap, 1)-1) ) + 1; % relative map
% cmapIds = floor( attrVect/180 * (size(cmap, 1)-1) ) + 1; % absolute map

if( true ) % plot 3d
    
    % plot
    scatter3(hit(:,1), hit(:,2), hit(:,3), 20, cmap(cmapIds, :), 'filled');
    hold on
    scatter3(spawn(1,1), spawn(1,2), spawn(1,3), 500, [1 1 1], 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 2);

    % format
    view([150 25]);
    hold off
    colormap(cmap), colorbar, axis equal, rotate3d on, grid on
    caxis([min(min(attrVect), 0) max(attrVect)]); % relative map
    % caxis([0 180]); % absolute map
    xlabel('x'); ylabel('y'); zlabel('z');
    
else % plot 2d
    
    % convert
    hitSph = dpq.coord.cart2sph(hit);
    spawnSph = dpq.coord.cart2sph(spawn);
    
    % plot
    scatter(hitSph(:,1), hitSph(:,2), 40, cmap(cmapIds, :), 'filled');
    hold on
    scatter(spawnSph(1,1), spawnSph(1,2), 500, [1 1 1], 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 2);

    % format
    hold off
    colormap(cmap), colorbar, axis equal, grid on
    caxis([min(min(attrVect), 0) max(attrVect)]); % relative map
    % caxis([0 180]); % absolute map
    xlabel('azimuth (deg)'); ylabel('elevation (deg)');
    
end

% format
set(gca, 'FontSize', 22);


%% debug elevation dilatation
% a positive error corresponds to a dilatation away from the horizontal plane

% define spawn/hit
elevTrue = 5;
elevResp = [-90:90].';
n = length(elevResp);
spawnSph = [zeros(n, 1), repmat(elevTrue, n, 1), ones(n, 1)];
hitSph = [zeros(n, 1), elevResp, ones(n, 1)];

% coord convert
spawn = dpq.coord.sph2cart(spawnSph);
hit = dpq.coord.sph2cart(hitSph);

% test method
s = dpq.alet.getErrors(spawn, hit);

% plot
plot(hitSph(:,2), s.errorSphSignedFolded(:, 2));
line([elevTrue elevTrue], [-90 90], 'Color', 'r');
xlabel('hit elev'); ylabel('error elev signed folded');
grid on, grid minor


%% debug lateral dilatation
% a positive error corresponds to a dilatation away from the median plane axis

% define spawn/hit
latTrue = 30;
latResp = [-90:90].';
n = length(latResp);
spawnInter = [repmat(latTrue, n, 1), zeros(n, 1), ones(n, 1)];
hitInter = [latResp, zeros(n, 1), ones(n, 1)];

% coord convert
spawn = dpq.coord.inter2cart(spawnInter);
hit = dpq.coord.inter2cart(hitInter);

% test method
s = dpq.alet.getErrors(spawn, hit);

% plot
plot(hitInter(:,1), s.errorInterSignedFolded(:, 1));
line([latTrue latTrue], [-90 90], 'Color', 'r');
xlabel('hit lateral'); ylabel('error lateral signed folded');
grid on, grid minor

