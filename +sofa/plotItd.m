function [] = plotItd(s)

% get min first onset
onsetThresh = 50e-3;
minFirstOnset = sofaGetMinFirstOnset(s, onsetThresh);

% extract itd (time align) to s.Data.Delay
s = sofaExtractItd(s, minFirstOnset, onsetThresh);

% rad to deg
aed = s.SourcePosition;
aed(:,1:2) = deg2rad(aed(:,1:2));

% sph to cart
[x, y, z] = sph2cart(aed(:,1), aed(:,2), aed(:,3));

% define colors
colorA = [1 0.3 0.3]; 
colorB = [0.9 0.9 0.9]; 
colorNeutre = [0.3 0.3 1];

% color proportional to delay (discrete)
delayDiff = s.Data.Delay(:,1) - s.Data.Delay(:,2);
c = repmat(colorNeutre, length(delayDiff), 1);
selVect = delayDiff < 0;
c(selVect,:) = repmat(colorA, sum(selVect), 1);
selVect = delayDiff > 0;
c(selVect,:) = repmat(colorB, sum(selVect), 1);

% plot
scatter3(x, y, z, 20, c, 'filled', 'LineWidth', 1, 'MarkerEdgeColor', [0.6 0.6 0.6]);

% labels
xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
title('red is L delay < R delay (blue is zero)');

% misc format
axis equal
view([-90 90]);
rotate3d on