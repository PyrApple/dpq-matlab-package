function [] = plotItd(s, cmap)

% init default arguments
if( nargin < 2 )
    cmap = parula(50);
end

% get min first onset
onsetThresh = 50e-3;
% onsetThresh = 0.7;
minFirstOnset = dpq.sofa.getMinFirstOnset(s, onsetThresh);

% debug
if true

    % skip if delay already extracted in Data.Delay field
    if( size(s.Data.Delay, 1) == size(s.Data.IR, 1) && ~isequal(s.Data.Delay, zeros(size(s.Data.Delay))))
        warning('hrir already aligned, itd alignement operation discarded \n');
        itdInSamples = s.Data.Delay(:, 1) - s.Data.Delay(:, 2);
    else

        % alternate estimate itd methods (from AMT, need amt_start to run beforehand)
        itd = itdestimator(s, 'MaxIACCe', 'lp', 'upper_cutfreq', 3000); % a more robust one
        % itd = itdestimator(s, 'Threshold', 'threshlvl', -30, 'lp', 'upper_cutfreq', 3000); % the one recommanded in katz paper
        itdInSamples = itd * s.Data.SamplingRate;
        warning('alternate delay estimation method');
    end
else
    % extract itd (time align) to s.Data.Delay
    s = dpq.sofa.extractItd(s, minFirstOnset, onsetThresh);
    itdInSamples = s.Data.Delay(:, 1) - s.Data.Delay(:, 2);
end

% rad to deg
aed = s.SourcePosition;
aed(:,1:2) = deg2rad(aed(:,1:2));

% sph to cart
[x, y, z] = sph2cart(aed(:,1), aed(:,2), aed(:,3));

% % define colors
% colorA = [1 0.3 0.3]; 
% colorB = [0.3 0.3 1]; 
% colorNeutre = [0.3 0.3 1];

% build color map
delayAmbitusInSamples = max(itdInSamples) - min(itdInSamples);
id = floor( size(cmap, 1) * (itdInSamples-min(itdInSamples)) / (delayAmbitusInSamples+1) ) + 1;
c = cmap(id, :);

% % deprecated
% c = repmat(colorNeutre, length(delayDiff), 1);
% selVect = delayDiff < 0;
% c(selVect,:) = repmat(colorA, sum(selVect), 1);
% selVect = delayDiff > 0;
% c(selVect,:) = repmat(colorB, sum(selVect), 1);

if false

    % plot 3D (xyz)
    % scatter3(x, y, z, 100, c, 'filled', 'LineWidth', 1, 'MarkerEdgeColor', [0.6 0.6 0.6]);
    scatter3(x, y, z, 100, c, 'filled');
    
    % labels
    xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
    
    % misc format
    axis equal
    view([-90 90]);
    rotate3d on

else 

    % plot flat (azim/elev)
    aed = s.SourcePosition;
    aed = wrapTo180(aed);
    scatter(aed(:, 1), aed(:, 2), 100, c, 'filled');
    
    % format
    grid on, grid minor
    yminMax = [min(aed(:, 2)) max(aed(:, 2))];
    line([180 180], yminMax, 'color', 'k', 'linestyle', '--');
    line([0 0], yminMax, 'color', 'k', 'linestyle', '--');
    xlabel('azimuth (deg)'); ylabel('elevation (deg)');
    ylim([-90 90]); xlim([-180 180]);
    % line([360 360], yminMax, 'color', 'k', 'linestyle', '--');

end

% format plot
% title('red is L delay below R delay (blue is zero)');
title('Left - Right delta ITD (ms)');
% colorbar(c)
colorbar; 
colormap(cmap);
if( min(itdInSamples) < max(itdInSamples))
    caxis(1000 * [min(itdInSamples) max(itdInSamples)]/s.Data.SamplingRate);
end

return 


%% debug

% load sofa 
filePath = '/Users/pyrus/SharedData/HRTFs/listen_hrir_subset/raw/sofa/listen_irc_1008.sofa';
s = SOFAload(filePath);

% plot itd
dpq.sofa.plotItd(s, [1 0.3 0.3; 0.3 0.3 1]);

% % init colormap
% n = 50;
% xvect = repmat(linspace(0, 1, n), 2, 1).';
% cmap = [ones(n, 1) xvect];
% cmap = [cmap; flipud(xvect) ones(n, 1) ];