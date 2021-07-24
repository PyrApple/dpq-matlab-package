function xyz = getUniformSphereGrid(n)

    % problem: when occupation check grid not dense enough, misalignement can
    % cause shift in metric variation 

    % init
    % n = 1550; % for ~5 deg grid
    % n = 94; % for ~20 deg grid
    % n = 370; % for ~10 deg grid
    % radius = 1.95; % sphere radius
    xyz = zeros(n,3);
    %
    % maxAcceptableVoidAngle = 5; % min angle in degree


    % % create uniform distribution on sphere
    % inc = pi * (3 - sqrt(5));
    % off = 2 / n;
    % x = 0; y = 0; z = 0; r = 0; phi = 0;
    % for k = 0:n-1
    %     y = k * off - 1 + (off /2);
    %     r = sqrt(1 - y * y);
    %     phi = k * inc;
    %     x = cos(phi) * r;
    %     z = sin(phi) * r;
    %     xyz(k+1, :) = radius * [x, y, z];
    % end

    % % create uniform distribution on sphere: fibonacci lattice 
    % % from http://extremelearning.com.au/evenly-distributing-points-on-a-sphere/
    % i = 0:1:(n-1) + 0.5;
    % phi = acos(1 - 2*i/n);
    % goldenRatio = (1 + 5^0.5)/2;
    % theta = 2 * pi * i / goldenRatio;
    % xyz = [cos(theta) .* sin(phi); sin(theta) .* sin(phi); cos(phi)].';

    % % create uniform distribution on sphere: derived from method of Saff and Kuijlaars
    % see http://web.archive.org/web/20120421191837/http://www.cgafaq.info/wiki/Evenly_distributed_points_on_sphere
    dlong = pi*(3-sqrt(5));
    dz = 2.0/n;
    long = 0;
    z = 1 - dz/2;
    for k = 1:n
        r = sqrt(1-z*z);
        xyz(k, :) = [cos(long)*r, sin(long)*r, z];
        z = z - dz;
        long = long + dlong;
    end

     
    return
    
    
    %% debug
    
    % init
    % n = 1550;
    n = 111;
    xyz = getUniformSphereGrid(n);
    
    % get min gc angle between points
    gcVect = nan(n, 1);
    for iPos = 1:n
        % compare one to the rest of them
        xyzA = repmat(xyz(iPos, :), n-1, 1);
        xyzB = xyz; xyzB(iPos,:) = [];

        % get gc min value
        gc = getGreatCircleAngle( xyzA, xyzB );
        gcVect(iPos) = min(gc);
    end

    % plot gc stats
    subplot(122), 
    plot(gcVect);
    title(sprintf('great-circle in [%.1f:%.1f], mean = %.1f \n', min(gcVect), max(gcVect), mean(gcVect)));

    % plot 3D
    subplot(121), 
    mSize = 8;
    plot3(xyz(:,1), xyz(:,2), xyz(:,3), 'ok', 'MarkerSize', mSize, 'MarkerFaceColor', 0.9*[1 1 1]);

    % format
    grid on, rotate3d on,
    axis equal

end