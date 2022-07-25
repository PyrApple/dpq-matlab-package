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

% interaural error
getErrorInterSigned = @(aed1, aed2) ( wrapTo180(aed1(:,1:2) - aed2(:,1:2)) );
s.errorInterSigned = getErrorInterSigned(hitInter, spawnInter);
s.errorInter = abs( s.errorInterSigned );

% spherical error
getErrorSphSigned = @(aed1, aed2) ( wrapTo180(aed1(:,1:2) - aed2(:,1:2)) );
s.errorSphSigned = getErrorSphSigned(hitSph, spawnSph);
s.errorSph = abs(s.errorSphSigned);

% % cart to double pole (not really double pole, using a lateral adjusted in 0:180)
% spawnDp = [acosd( spawn(:,1) ./ spawnSph(:,3) ) spawnSph(:, 2:3)];
% hitDp = [acosd( hit(:,1) ./ hitSph(:,3) ) hitSph(:, 2:3)];
% 
% % double pole error to avoid compression
% getErrorDpSigned = @(aed1, aed2) ( wrapTo180(aed1(:,1:2) - aed2(:,1:2)) );
% s.errorDpSigned = getErrorDpSigned(hitDp, spawnDp);
% s.errorDp = abs(s.errorDpSigned);

% dilation
s.interCompression = abs(spawnInter(:,1:2)) - abs(hitInter(:,1:2));
s.sphCompression = abs(spawnSph(:,1:2)) - abs(hitSph(:,1:2));
% % same but aggregated into one
% getErrorDilation = @(ang1, ang2) ( abs(ang1) - abs(ang2) );
% dilationLat = getErrorDilation(hitInter(:,1), spawnInter(:,1));
% dilationElev = getErrorDilation(hitSph(:,2), spawnSph(:,2));
% s.errorDilation = [dilationLat dilationElev];

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

% great circle distance
s.greatCircDistance = dpq.alet.getGreatCircleAngle( spawn, hit );

% great circle bearing (towards interaural axis lateral = 90)
s.greatCircBearing = atan2d( cosd(hitInter(:, 1)) .* sind(hitInter(:, 2) - spawnInter(:, 2)), cosd(spawnInter(:, 1)) .* sind(hitInter(:, 1)) - sind(spawnInter(:, 1)) .* cosd(hitInter(:, 1)) .* cosd(hitInter(:, 2) - spawnInter(:, 2)) );
%
% great circle bearing (towards spherical north pole elev = 90)
% s.greatCircBearing = atan2d( cosd(hitSph(:, 2)) .* sind(hitSph(:, 1) - spawnSph(:, 1)), cosd(spawnSph(:, 2)) .* sind(hitSph(:, 2)) - sind(spawnSph(:, 2)) .* cosd(hitSph(:, 2)) .* cosd(hitSph(:, 1) - spawnSph(:, 1)) );
% s.greatCircBearing = atan2d( cosd(spawnSph(:, 2)) .* sind(spawnSph(:, 1) - hitSph(:, 1)), cosd(hitSph(:, 2)) .* sind(spawnSph(:, 2)) - sind(hitSph(:, 2)) .* cosd(spawnSph(:, 2)) .* cosd(spawnSph(:, 1) - hitSph(:, 1)) );

% % avoid compression at poles (rotation to 0, 0 before computing error
% % 
% % rotate so that spawn is always at azim/elev = (0, 0)
% [spawnCentered, hitCentered] = dpq.alet.centerOnSphOrigin(spawn, hit);
% %
% % coordinate convert
% spawnInterCentered = dpq.coord.cart2inter( spawnCentered ); spawnSphCentered = dpq.coord.cart2sph( spawnCentered );
% hitInterCentered = dpq.coord.cart2inter( hitCentered ); hitSphCentered = dpq.coord.cart2sph( hitCentered );
% %
% %
% % interaural error
% s.undistort.errorInterSigned = getErrorInterSigned(hitInterCentered, spawnInterCentered);
% s.undistort.errorInter = abs( s.undistort.errorInterSigned );
% %
% % interaural compression
% s.undistort.interCompression = abs(spawnInterCentered(:,1:2)) - abs(hitInterCentered(:,1:2));
% %
% % spherical error
% s.undistort.errorSphSigned = getErrorSphSigned(hitSphCentered, spawnSphCentered);
% s.undistort.errorSph = abs(s.undistort.errorSphSigned);
% %
% % spherical compression
% s.undistort.sphCompression = abs(spawnSphCentered(:,1:2)) - abs(hitSphCentered(:,1:2));


% avoid compression at poles (inspired from majdak2010 weighting)
% wPoles = @(x) 0.5 * ( cosd(2*x) + 1 );
wPoles = @(x) ( cosd(x) );
%
s.errorAzimWeighted = wPoles(spawnSph(:, 2)) .* s.errorSph(:, 1);
s.errorAzimSignedWeighted = wPoles(spawnSph(:, 2)) .* s.errorSphSigned(:, 1);
%
s.errorPolarWeighted = wPoles(spawnInter(:, 1)) .* s.errorInter(:, 2);
s.errorPolarSignedWeighted = wPoles(spawnInter(:, 1)) .* s.errorInterSigned(:, 2);

% wPoles = @(x) ( 0.5 * cosd(2*x + 0.5 ) );
% %
% % interaural error
% s.undistort.errorInterSigned = s.errorInterSigned;
% s.undistort.errorInterSigned(:, 1) = s.undistort.errorInterSigned(:, 1) .* wPoles(spawnInter(:, 1));
% s.undistort.errorInter = abs( s.undistort.errorInterSigned );
% %
% % spherical error
% s.undistort.errorSphSigned = getErrorSphSigned(hitSphCentered, spawnSphCentered);
% s.undistort.errorSph = abs(s.undistort.errorSphSigned);

% % resolved (based on confusions) hit error (PENDING DISCUSSION FOR INTEGRATION)
% resolved = struct();
% for iMethod = 1:length(confusionMethods)
%     
%     % init locals
%     hitResolved = hit;
%     method = confusionMethods{iMethod};
%     confusionStr = s.confusionStr.(method);
%     
%     % up-down confusions: z symmetry
%     selVect = contains( confusionStr, 'up-down' );
%     hitResolved( selVect, 3 ) = - hitResolved( selVect, 3 );
% 
%     % front-back confusions: x symmetry
%     selVect = contains( confusionStr, 'front-back' );
%     hitResolved( selVect, 1 ) = - hitResolved( selVect, 1 );
%     
%     % DISCARDED: you can't resolve "combined" (they are just wrong)
%     % % combined confusions: x&z symmetry
%     % selVect = contains( confusionStr, 'combined' );
%     % hitResolved( selVect, 1 ) = - hitResolved( selVect, 1 );
%     % hitResolved( selVect, 3 ) = - hitResolved( selVect, 3 );
%     % % warning('debug ');
%     % % hitCorrected( selVect, : ) = spawn(selVect, :);
%     
%     % compute new errors
%     greatCircDistance = dpq.alet.getGreatCircleAngle( spawn, hitResolved );
%     errorInterSigned = getErrorInterSigned(spawnInter, dpq.coord.cart2inter(hitResolved));
%     errorSphSigned = getErrorSphSigned(spawnSph, dpq.coord.cart2sph(hitResolved));
%     
%     % save to locals
%     resolved.(method).greatCircDistance = greatCircDistance;
%     resolved.(method).errorInterSigned = errorInterSigned;
%     resolved.(method).errorInter = abs(errorInterSigned);
%     resolved.(method).errorSphSigned = errorSphSigned;
%     resolved.(method).errorSph = abs(errorSphSigned);
% end
%
% % save to local
% s.resolved = resolved;


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

% reorder fields in alphabetical order
s = orderfields(s);

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
aedRef = [30 30 1.1];
aedRef = repmat(aedRef, size(aed, 1), 1);

% convert
hit = dpq.coord.sph2cart( aed );
spawn = dpq.coord.sph2cart( aedRef );

% test method
s = dpq.alet.getErrors(spawn, hit);

% define attribute to test
% attrVect = s.greatCircDistance;
% attrVect = s.gcAngle;
% attrVect = s.errorInterSigned(:, 1);
% attrVect = s.errorInter(:, 2);
% attrVect = s.undistort.errorInter(:, 2);
% attrVect = s.errorSphSigned(:, 2);
% attrVect = s.errorSph(:, 1);
% attrVect = s.undistort.errorSph(:, 2);
% attrVect = s.undistort.errorSphSigned(:, 2);
% attrVect = s.resolved.poirier.greatCircDistance;
% attrVect = s.errorDpSigned(:, 1);
% attrVect = s.errorDp(:, 1);
%
% attrVect = s.greatCircBearing;
%
a = atan2d(s.errorSph(:, 2), s.errorSph(:, 1));
attrVect = s.greatCircDistance .* cosd(a); % kind of working uncompressed azim (based on linear pythagorean theorem)
%
% attrVect = acosd( cosd(s.greatCircDistance) ./ cosd(s.errorSph(:, 2)) );
% attrVect = abs( cosd(s.greatCircDistance) ./ cosd(s.errorSph(:, 2)) ) > 1;
% attrVect = s.greatCircDistance .* cosd(a); % NOT WORKING uncompressed azim (based on spherical pythagorean theorem: cos(c) = cos(A)*cos(B))
%
% attrVect = cosd(aedRef(:, 2)) .* s.errorSph(:, 1); % carlile2014accommodating like compensation of compression (for interaural in original paper)
% 

% % cart to double pole (not really double pole, using a lateral adjusted in 0:180)
% spawnSph = dpq.coord.cart2sph(spawn);
% hitSph = dpq.coord.cart2sph(hit);
% spawnDp = [acosd( spawn(:,1) ./ spawnSph(:,3) ) spawnSph(:, 2:3)];
% hitDp = [acosd( hit(:,1) ./ hitSph(:,3) ) hitSph(:, 2:3)];
% % hitDp(:, 1) = hitDp(:, 1) + spawnDp(:, 1);
% 
% % double pole error to avoid compression
% getErrorDpSigned = @(aed1, aed2) ( wrapTo180(aed1(:,1:2) - aed2(:,1:2)) );
% errorDpSigned = getErrorDpSigned(hitDp, spawnDp);
% errorDp = abs(errorDpSigned);
% 
% attrVect = errorDp(:, 1);

% d = spawn(:, 1:2) - hit(:, 1:2);
% attrVect = sum(abs(d), 2);

% attrVect = (s.greatCircDistance / 180) .* s.errorSph(:, 1);
% attrVect = s.greatCircDistance - s.errorSph(:, 2);

% % cart to double pole (not really double pole, using a lateral rotated in 0:180)
% spawnSph = dpq.coord.cart2sph(spawn);
% hitSph = dpq.coord.cart2sph(hit);
% % spawnLat = asind(spawn(:,1) ./ spawnSph(:,3));
% % hitLat = acosd( hit(:,1) ./ hitSph(:,3));
% % 
% % hitLat = acosd( (cosd( spawnSph(:, 1) ) .* hit(:,1) + sind( spawnSph(:, 1) ) .* hit(:,2)  ) ./ hitSph(:,3)); % rotated to start at zero for spawn lateral
% % attrVect = hitLat - spawnSph(:, 2);
% % 
% hitLat = acosd( (-sind( spawnSph(:, 1) ) .* hit(:,1) + cosd( spawnSph(:, 1) ) .* hit(:,2)  ) ./ hitSph(:,3)); % rotated to start at zero for spawn lateral
% attrVect = hitLat - 90; % used for signed error

% attrVect = s.errorDilation(:, 1);
% attrVect = s.sphCompression(:, 2);
% attrVect = s.interCompression(:, 1);
% attrVect = s.errorInterSigned(:, 1);
attrVect = s.errorSphSigned(:, 2);

% attrVect = s.undistort.errorSph(:, 1);


% select data
selVect = 1:length(s.greatCircDistance); % dummy (all)
% selVect = selVect & contains(s.confusionStr.zagala, {'precision', 'front-back'});

% apply select data
attrVect = attrVect(selVect);
hit = hit(selVect, :);
spawn = spawn(selVect, :);

% % histogram
% histogram(s.greatCircDistance)
% hold on, 
% histogram(s.corrected.zagala.greatCircDistance)
% hold off, 
% return 

% create cmap
cmap = jet(180);
% cmap = flipud(gray(180));
%
% % symetric cmap
% cmapFun1 = @(n) flipud( [linspace(0.8, 1, n).' linspace(0.1, 1, n).' linspace(0.05, 1, n).'].^0.7 ); % red gradiant
% cmapFun2 = @(n) [linspace(0.05, 1, n).' linspace(0.1, 1, n).' linspace(0.8, 1, n).'].^0.7; % blue gradiant
% cmapFun = @(n) [cmapFun2(n/2); cmapFun1(n/2)];
% cmap = cmapFun(180);

% get cmap ids
isRelCmap = true;
if( isRelCmap )
    cmapIds = floor( normalize(attrVect, 'range') * (size(cmap, 1)-1) ) + 1; % relative map
else 
    cmapIds = floor( attrVect/180 * (size(cmap, 1)-1) ) + 1; % absolute map
end

if( true ) % plot 3d
    
    % plot
    scatter3(hit(:,1), hit(:,2), hit(:,3), 20, cmap(cmapIds, :), 'filled');
    hold on
    scatter3(spawn(1,1), spawn(1,2), spawn(1,3), 500, [1 1 1], 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 2);
    hold off
    
    % format
    view([150 25]);
    rotate3d on
    xlabel('x'); ylabel('y'); zlabel('z');
    
else % plot 2d
    
    % convert
    hitSph = dpq.coord.cart2sph(hit);
    spawnSph = dpq.coord.cart2sph(spawn);
    
    % plot
    scatter(hitSph(:,1), hitSph(:,2), 40, cmap(cmapIds, :), 'filled');
    hold on
    scatter(spawnSph(1,1), spawnSph(1,2), 500, [1 1 1], 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 2);
    hold off
    
    % format
    xlabel('azimuth (deg)'); ylabel('elevation (deg)');
    
end

% format
set(gca, 'FontSize', 22);
colormap(cmap), colorbar, axis equal, grid on
if( isRelCmap )
    caxis([min(min(attrVect), 0) max(attrVect)]); % relative map
else
    % caxis([-180 180]); % relative map
    caxis([0 180]); % absolute map
end

%% debug elevation dilatation
% a positive error corresponds to a dilatation away from the horizontal plane

% define spawn/hit
elevTrue = 0;
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
xlabel('hit elev'); ylabel('error elev signed folded (elev dilation)');
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


 %% debug poles weighting (polar here, exactly the same for azim)

% init local (create scenario illustrating compression)
n = 180;
hitInter = [linspace(-90, 90, n).', 45*ones(n, 1), ones(n, 1)];
spawnInter = hitInter; spawnInter(:, 2) = 0;
hit = dpq.coord.inter2cart(hitInter);
spawn = dpq.coord.inter2cart(spawnInter);
s = dpq.alet.getErrors(spawn, hit);

% compute compression manual
wPoles = @(x) ( cosd(x) );
errorPolarWeighted = wPoles(spawnInter(:, 1)) .* s.errorInter(:, 2);

% plot compression
plot(hitInter(:, 1), s.errorInter(:, 2));
hold on, 
plot(hitInter(:, 1), s.greatCircDistance);
plot(hitInter(:, 1), s.errorPolarWeighted);
plot(hitInter(:, 1), errorPolarWeighted, '--');
hold off,

legend({'raw polar error', 'gc', 'weighted polar error'});