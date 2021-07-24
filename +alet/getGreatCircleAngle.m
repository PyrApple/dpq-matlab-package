function [gcAngle] = getGreatCircleAngle(xyzA, xyzB)

% xyzA and xyzB are Nx3 cartesian coordinates

% sanity check
if( ~isequal( size(xyzA), size(xyzB) ) ); error('different input sizes'); end
if( size(xyzA, 2) ~= 3 ); error('expected Nx3 vector'); end


% gcAngle = atan2d( vecnorm(cross(xyzA,xyzB).',2).', dot(xyzA,xyzB,2));
gcAngle = atan2d( vecnorm(cross(xyzA.',xyzB.'), 2).', dot(xyzA, xyzB, 2));

%% debug great circle (copy/paste in console)

% % define grid (sphere)
% step = 2;
% azim = -180:step:180;
% elev = -89:step:90;
% dist = 1;
% tmp = repmat(elev, length(azim), 1); tmp = tmp(:);
% aed = [ repmat(azim', length(elev), 1)  tmp  dist*ones(length(azim) * length(elev), 1) ];
% 
% % define reference point
% aedRef = [55 150 1.1];
% aedRef = repmat(aedRef, size(aed, 1), 1);
% 
% % get great circle angle difference
% xyz = sph2cartVect( aed );
% xyzRef = sph2cartVect( aedRef );
% gc = getGreatCircleAngle(xyz, xyzRef);
% 
% % plot difference
% cmap = parula;
% cmapIds = floor( normalize(gc, 'range') * (size(cmap, 1)-1) ) + 1;
% 
% scatter3(xyz(:,1), xyz(:,2), xyz(:,3), 40, cmap(cmapIds, :), 'filled');
% hold on
% scatter3(xyzRef(1,1), xyzRef(1,2), xyzRef(1,3), 500, [1 0 0], 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 2);
% hold off
% colorbar, axis equal, rotate3d on, grid on