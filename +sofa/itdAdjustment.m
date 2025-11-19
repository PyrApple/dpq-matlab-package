function sOut = itdAdjustment(sIn, headCircumInMeter)

% Return a sofa struct with adjusted delays based on head circumference
% based on model presented in [<need-to-find-original-paper>]
% 
% sOut = itdAdjustment(sIn, headCircumInMeter)
% 
% 

% need to extract delays first
if( size(sIn.Data.Delay) == [1 2] )
    error('need to extract delays from hrtf before invoking this function');
end

% load itd model 
filePath = mfilename('fullpath');
[folderPath, ~, ~] = fileparts(filePath);
filePath = fullfile(folderPath, 'itd_model.sofa');
sItd = SOFAload(filePath);

% init locals
sOut = sIn;
toleranceThreshDegree = 3; % in degree

% find matching positions: init
itdIds = zeros(sIn.API.M, 1);

% loop over positions
for iPos = 1:sIn.API.M
    
    % get positions difference
    ae = sItd.SourcePosition(:, 1:2) - sIn.SourcePosition(iPos, 1:2);
    delta = sum(abs(ae), 2);
    
    % find matching within tolerance
    id = find(delta < toleranceThreshDegree);
    if( isempty(id) ); error('cannot find matching position within %.1f degree tolerance', toleranceThreshDegree); end
    if( length(id) > 1); warning('more than one position matches within tolerance, consider reducing tolerance'); end
    
    itdIds(iPos) = id;
    
end

% % debug pos find
% xyz = dpq.coord.sph2cart([sIn.SourcePosition(:, 1:2) ones(sIn.API.M, 1)]);
% plot3(xyz(:,1), xyz(:,2), xyz(:,3), 'o');
% hold on
% xyz = dpq.coord.sph2cart(sItd.SourcePosition(itdIds, :));
% plot3(xyz(:,1), xyz(:,2), xyz(:,3), 'x');
% hold off,
% legend({'hrtf', 'itd'});
% axis equal, grid on, grid minor,

% % debug: plot model delays
% plot(sItd.Data.Delay(itdIds, :));

% itd adjustment
correctionFactor = 0.0223 * headCircumInMeter + 0.002942;
correctionFactor = correctionFactor * sIn.Data.SamplingRate / 1000;
sOut.Data.Delay = correctionFactor * sItd.Data.Delay(itdIds, :);

return 


%% debug

% load sofa 
filePath = '/Users/pyrus/SharedData/HRTFs/listen_hrir_subset/raw/sofa/listen_irc_1008.sofa';
s1 = SOFAload(filePath);
thresh = 1e-1;

% extract itd
s1 = dpq.sofa.extractItd(s1, 20, thresh);
s1.Data.Delay = s1.Data.Delay - min(min(s1.Data.Delay));

% apply itd correction
headCircum = 0.575; % in m
% headCircum = 0.9; % in m
s2 = dpq.sofa.itdAdjustment(s1, headCircum);

% plot
lineSpecs = {'-b', '--b', '-r', '--r'};
selVect = s1.SourcePosition(:,2) == 0; % zero elevation
plot(0, 0, 'HandleVisibility', 'off'); hold on,

for iCh = 1:2
    f = 1000 / s1.Data.SamplingRate;
    plot(s1.SourcePosition(selVect, 1), f * s1.Data.Delay(selVect, iCh), lineSpecs{2*(iCh-1) + 1});
    plot(s2.SourcePosition(selVect, 1), f * s2.Data.Delay(selVect, iCh), lineSpecs{2*iCh});
    
end

a = 1000 * (headCircum/pi) / 343;
line([0 360], [a a], 'Color', 'k', 'LineStyle', '--');

% format
hold off,
legend({'original left', 'adjusted left', 'original right', 'adjusted right'}, 'Location', 'SouthEast');
title(sprintf('head cicum %.1f mm, elev 0 deg', headCircum * 1000) );
xlabel('azim (deg)'); ylabel('time (ms)');
grid on, grid minor
