function xyz = inter2cart(lpd)

% Interaural to cartesian coordinates
% 
% xyz = inter2cart(lpd)
% 
% lpd is lateral (deg), polar (deg), distance (m), xyz is cartesian
% coordinates (m). Both are Nx3 matrices.

if( size(lpd, 2) ~= 3 ); error('expected Nx3 matrix'); end

xyz = nan(size(lpd));

xyz(:,1) = lpd(:, 3) .* cosd( lpd(:,1) ) .* cosd( lpd(:,2) );
xyz(:,2) = lpd(:, 3) .* sind( lpd(:,1) );
xyz(:,3) = lpd(:, 3) .* cosd( lpd(:,1) ) .* sind( lpd(:,2) );