xyz = rand(1000, 3);

plot3(xyz(:, 1), xyz(:, 2), xyz(:, 3), '.k', 'MarkerSize', 10);
hold on,

aed = dpq.coord.cart2sph(xyz);
xyz = dpq.coord.sph2cart(aed);

plot3(xyz(:, 1), xyz(:, 2), xyz(:, 3), 'ob', 'MarkerSize', 10);

lpd = dpq.coord.cart2inter(xyz);
xyz = dpq.coord.inter2cart(lpd);

plot3(xyz(:, 1), xyz(:, 2), xyz(:, 3), 'or', 'MarkerSize', 14);

lpd = dpq.coord.cart2inter(xyz);
aed = dpq.coord.inter2sph(lpd);
lpd = dpq.coord.sph2inter(aed);
xyz = dpq.coord.inter2cart(lpd);

plot3(xyz(:, 1), xyz(:, 2), xyz(:, 3), 'og', 'MarkerSize', 18);

hold off