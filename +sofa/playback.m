function [] = playback(s, ioiPauseInSec, shouldPlot, idsRange, viewPos)

% Play content of sofa struct, diplay associated position
% 
% [] = playback(s)
% 
% 

% todo: account for extracted ITD
if( size(s.Data.Delay, 1) ~= 1 ) 
    warning('extracted itd not taken into acount');
end

% init default arguments
if( nargin < 3 ); shouldPlot = true; end
if( nargin < 4 ); idsRange = 1:size(s.SourcePosition, 1); end
if( nargin < 5 ); viewPos = [-40 30]; end

for iPos = idsRange
   
    % get ir
    ir = squeeze(s.Data.IR(iPos,:,:)).';
    
    % zero pad to account for extracted itd
    % ...
    
    % playback
    soundsc(ir, s.Data.SamplingRate);
    
    if( shouldPlot )
        % plot all positions
        xyz = dpq.coord.sph2cart(s.SourcePosition);
        plot3(xyz(:,1), xyz(:,2), xyz(:,3), '.k', 'MarkerSize', 7);
        hold on

        % plot current position
        xyz = dpq.coord.sph2cart(s.SourcePosition(iPos,:));
        plot3(xyz(:,1), xyz(:,2), xyz(:,3), 'ok', 'MarkerFaceColor', 'r', 'MarkerSize', 10);

        % format
        hold off,
        title(sprintf('pos %d: aed = %.1f %.1f %.1f', iPos, s.SourcePosition(iPos,:)));
        xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
        grid on, grid minor, 
        axis equal,
        view(viewPos);
    end
    
    % pause 
    pause(ioiPauseInSec);

end


return 


%% debug

% load sofa 
filePath = '/Users/pyrus/SharedData/HRTFs/listen_hrir_subset/raw/sofa/listen_irc_1008.sofa';
s = SOFAload(filePath);

% debug reduce
selVect = 1:24;
% selVect = 1:2;
s.SourcePosition = s.SourcePosition(selVect,:);
s.Data.IR = s.Data.IR(selVect,:,:);
s = SOFAupdateDimensions(s);

% extract itd
% s = dpq.sofa.extractItd(s, 20, 1e-3);

% playback
dpq.sofa.playback(s, 0);
