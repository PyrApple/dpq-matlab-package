function [aed] = cart2interVect(xyz)

if( size(xyz, 2) ~= 3 ); error('expected Nx3 vector'); end

aed = nan(size(xyz));

aed(:,3) = sqrt( xyz(:,1).^2 + xyz(:,2).^2 + xyz(:,3).^2 );
aed(:,1) = asind( xyz(:,2) ./ aed(:,3) );

p = aed(:,3) .* cosd( aed(:,1) );
aed(:,2) = atan2d( p .* xyz(:,3), p .* xyz(:,1));

% rewrap elev around [-90 270]
selVect = aed(:,2) < -90;
aed(selVect,2) = 360 + aed(selVect,2);

% deal with radius = 0 scenario
selVect = aed(:,3) == 0;
aed(selVect,1) = 0;
aed(selVect,2) = 0;