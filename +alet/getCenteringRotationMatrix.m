function [R] = getCenteringRotationMatrix(xyz)

% sanity check
if( ~isequal(size(xyz), [1 3]) ); error('expected 1x3 vector'); end

% convert to sph coord
aed = dpq.coord.cart2sph(xyz);

% deg to rad
aed = [deg2rad(aed(1:2)) aed(3)];

% constrain on 1-radius sphere
aed(3) = 1;

% Creat the Rotation matrices around y and z
Ry = [cos(-aed(2)),   0,              -sin(-aed(2));
      0,                1,              0;
      sin(-aed(2)),   0,              cos(-aed(2))];
Rz = [cos(-aed(1)),    -sin(-aed(1)), 0;
      sin(-aed(1)),    cos(-aed(1)),  0;
      0,                0,              1];

% R is the matrix used to bring the points to az = 0, el = 0
R = Ry*Rz;
    
end

