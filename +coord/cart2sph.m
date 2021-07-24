function [aed] = cart2sphVect(xyz)

% xyz is vect Nx3, output angles in degrees

% input / output coord conv matches unity's HRTF learning game

aed = zeros(size(xyz));

for iPos = 1:size(xyz,1)
    
    % cart to sph
    [azim, elev, r] = cart2sph(xyz(iPos, 1), xyz(iPos, 2), xyz(iPos, 3));
    
    % rad to deg
    azim = rad2deg(azim); 
    elev = rad2deg(elev);
    
    % save to locals
    aed(iPos,:) = [azim, elev, r];
end