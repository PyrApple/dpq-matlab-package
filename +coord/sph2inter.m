function lpd = sph2inter(aed)

% Interaural to spherical coordinates
% 
% lpd = sph2inter(aed)
% 
% aed is azimuth (deg), elevation (deg), distance (m), lpd is lateral
% (deg), polar (deg), distance (m). Both are Nx3 matrices.

if( size(aed, 2) ~= 3 ); error('expected Nx3 matrix'); end

xyz = dpq.coord.sph2cart(aed);
lpd = dpq.coord.cart2inter(xyz);