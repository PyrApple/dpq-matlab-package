function aed = inter2sph(lpd)

% Interaural to spherical coordinates
% 
% aed = inter2sph(lpd)
% 
% aed is azimuth (deg), elevation (deg), distance (m), lpd is lateral
% (deg), polar (deg), distance (m). Both are Nx3 matrices.

if( size(lpd, 2) ~= 3 ); error('expected Nx3 matrix'); end

xyz = dpq.coord.inter2cart(lpd);
aed = dpq.coord.cart2sph(xyz);