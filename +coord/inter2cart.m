function [xyz] = inter2cartVect(aed)

if( size(aed, 2) ~= 3 ); error('expected Nx3 vector'); end

xyz = nan(size(aed));

xyz(:,1) = aed(:, 3) .* cosd( aed(:,1) ) .* cosd( aed(:,2) );
xyz(:,2) = aed(:, 3) .* sind( aed(:,1) );
xyz(:,3) = aed(:, 3) .* cosd( aed(:,1) ) .* sind( aed(:,2) );