function lpd = cart2inter(xyz)

% Cartesian to interaural coordinates
% 
% lpd = cart2inter(xyz)
% 
% lpd is lateral (deg), polar (deg), distance (m), xyz is cartesian
% coordinates (m). Both are Nx3 matrices.

if( size(xyz, 2) ~= 3 ); error('expected Nx3 matrix'); end

lpd = nan(size(xyz));

lpd(:,3) = sqrt( xyz(:,1).^2 + xyz(:,2).^2 + xyz(:,3).^2 );
lpd(:,1) = asind( xyz(:,2) ./ lpd(:,3) );

p = lpd(:,3) .* cosd( lpd(:,1) );
lpd(:,2) = atan2d( p .* xyz(:,3), p .* xyz(:,1));

% rewrap elev around [-90 270]
selVect = lpd(:,2) < -90;
lpd(selVect,2) = 360 + lpd(selVect,2);

% deal with radius = 0 scenario
selVect = lpd(:,3) == 0;
lpd(selVect,1) = 0;
lpd(selVect,2) = 0;