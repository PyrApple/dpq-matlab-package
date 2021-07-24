function [aedInter] = sph2interVect(aed)

if( size(aed, 2) ~= 3 ); error('expected Nx3 vector'); end

xyz = sph2cartVect(aed);
aedInter = cart2interVect(xyz);