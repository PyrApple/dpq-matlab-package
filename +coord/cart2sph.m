function aed = cart2sph(xyz)

% Cartesian to spherical coordinates
% 
% aed = cart2sph(xyz)
% 
% aed is azimuth (deg), elevation (deg), distance (m), xyz is cartesian
% coordinates (m). Both are Nx3 matrices.

if( size(xyz, 2) ~= 3 ); error('expected Nx3 matrix'); end

% init locals
aed = zeros(size(xyz));

% loop over positions
for iPos = 1:size(xyz,1)
    
    % cart to sph
    [azim, elev, r] = cart2sph(xyz(iPos, 1), xyz(iPos, 2), xyz(iPos, 3));
    
    % rad to deg
    azim = rad2deg(azim); 
    elev = rad2deg(elev);
    
    % save to locals
    aed(iPos,:) = [azim, elev, r];
    
end

return 


%% debug

xyz = rand(100, 3);

% n = 100;
% aed = [360*rand(n, 1) 180*(rand(n, 1)-0.5) ones(n, 1)];
% xyz = dpq.coord.sph2cart(aed);

plot3(xyz(:, 1), xyz(:, 2), xyz(:, 3), '.k', 'MarkerSize', 10);
hold on,

aed = dpq.coord.cart2sph(xyz);
xyz = dpq.coord.sph2cart(aed);

plot3(xyz(:, 1), xyz(:, 2), xyz(:, 3), 'ob', 'MarkerSize', 8);

lpd = dpq.coord.cart2inter(xyz);
xyz = dpq.coord.inter2cart(lpd);

plot3(xyz(:, 1), xyz(:, 2), xyz(:, 3), 'or', 'MarkerSize', 13);

lpd = dpq.coord.cart2inter(xyz);
aed = dpq.coord.inter2sph(lpd);
lpd = dpq.coord.sph2inter(aed);
xyz = dpq.coord.inter2cart(lpd);

plot3(xyz(:, 1), xyz(:, 2), xyz(:, 3), 'og', 'MarkerSize', 17);

% format
hold off,
axis equal
grid on