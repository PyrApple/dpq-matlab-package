function [aedSph] = inter2sphVect(aed)

if( size(aed, 2) ~= 3 ); error('expected Nx3 vector'); end

xyz = inter2cartVect(aed);
aedSph = cart2sphVect(xyz);