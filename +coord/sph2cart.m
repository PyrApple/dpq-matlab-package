function xyz = sph2cart(aed)

% Spherical to cartesian coordinates
% 
% xyz = sph2cart(aed)
% 
% aed is azimuth (deg), elevation (deg), distance (m), xyz is cartesian
% coordinates (m). Both are Nx3 matrices.

if( size(aed, 2) ~= 3 ); error('expected Nx3 matrix'); end

xyz = nan(size(aed));

xyz(:,1) = aed(:, 3) .* cosd( aed(:,1) ) .* cosd( aed(:,2) );
xyz(:,2) = aed(:, 3) .* sind( aed(:,1) ) .* cosd( aed(:,2) );
xyz(:,3) = aed(:, 3) .* sind( aed(:,2) );