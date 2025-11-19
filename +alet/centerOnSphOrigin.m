function [spawnCentered, hitCentered] = centerOnSphOrigin(spawn, hit)

% xyzA and xyzB are Nx3 cartesian coordinates

% sanity check
if( ~isequal( size(spawn), size(hit) ) ); error('different input sizes'); end
if( size(spawn, 2) ~= 3 ); error('expected Nx3 vector'); end

spawnCentered = nan(size(spawn));
hitCentered = nan(size(spawn));

% loop over positions
for iPos = 1:size(spawn, 1)
    
    % get rotation matrix for current spawn pos
    R = dpq.alet.getCenteringRotationMatrix(spawn(iPos, :));
    
    % apply rotation
    spawnCentered(iPos, :) = (R*spawn(iPos, :).').';
    hitCentered(iPos, :) = (R*hit(iPos, :).').';
    
end

return 


%% debug rotation

% define spawn / hit
spawnSph = [-45, 40, 1.1];
spawnSph = repmat(spawnSph, 3, 1);
hitSph = spawnSph + 40* (rand(size(spawnSph)) - 0.5 ) ;
hitSph(:, 3) = spawnSph(1, 3);

% sph to cart
spawn = dpq.coord.sph2cart(spawnSph);
hit = dpq.coord.sph2cart(hitSph);

% apply method
[spawnCentered, hitCentered] = dpq.alet.centerOnSphOrigin(spawn, hit);

% init plot
mSize = 16; lw = 2;
plot3(0, 0, 0, 'HandleVisibility', 'off');
hold on,

% plot sphere
[x, y, z] = sphere(30);
surf(x,y,z, 'FaceColor', 'w', 'FaceAlpha', 1);
    
% plot original data
xyz = spawn;
plot3(xyz(:, 1), xyz(:, 2), xyz(:, 3), 'sqk', 'MarkerSize', mSize, 'MarkerFaceColor', 0.6*[1 1 1], 'LineWidth', lw);
xyz = hit;
plot3(xyz(:, 1), xyz(:, 2), xyz(:, 3), 'ok', 'MarkerSize', mSize, 'MarkerFaceColor', 0.6*[1 1 1], 'LineWidth', lw);

% plot rotated data
xyz = spawnCentered;
plot3(xyz(:, 1), xyz(:, 2), xyz(:, 3), 'sqk', 'MarkerSize', mSize, 'MarkerFaceColor', 'r', 'LineWidth', lw);
xyz = hitCentered;
plot3(xyz(:, 1), xyz(:, 2), xyz(:, 3), 'ok', 'MarkerSize', mSize, 'MarkerFaceColor', 'r', 'LineWidth', lw);

% format
hold off
rotate3d on,
grid on, grid minor,
xlim([-1 1]); axis equal
xlabel('x (+fwd)'); ylabel('y (+left)'); zlabel('z (+up)');
view([140 24]);



