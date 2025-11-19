function s = reinjectItd(sIn)

% Reinject ITD values from Data.Delay to Data.IR of sofa struct
% 
% s = injectItd(sIn)
% 

% init locals
s = sIn;

% discard if Data.Delay already at zero
if( isequal(s.Data.Delay, [0 0]) )
    return
end

% collapse if Data.Delay already at zero
if( all(s.Data.Delay(:) == 0) )
    s.Data.Delay = [0 0];
    return;
end

% sanity check: delays are in samples
if( ~isequal(round(s.Data.Delay), s.Data.Delay) ); error('expected delay in sample'); end

% sanity check: all delays are positive
if( any(s.Data.Delay(:) < 0) ); error('negative delays not supported'); end

% round delays (in samples)
s.Data.Delay = round(s.Data.Delay);

% init locals
maxDelay = max(max(s.Data.Delay));
irs = zeros(size(s.Data.IR, 1), size(s.Data.IR, 2), size(s.Data.IR, 3) + maxDelay);

% loop over positions
for iPos = 1:size(s.SourcePosition(:, 1))
    
    % extract delays
    delayL = s.Data.Delay(iPos, 1);
    delayR = s.Data.Delay(iPos, 2);
    
    % reinject delays
    irs(iPos, 1, :) =  [zeros(delayL, 1); squeeze(s.Data.IR(iPos, 1, :)); zeros(maxDelay - delayL, 1)];
    irs(iPos, 2, :) =  [zeros(delayR, 1); squeeze(s.Data.IR(iPos, 2, :)); zeros(maxDelay - delayR, 1)];
    
    % % debug
    % plot(squeeze(s.Data.IR(iPos, 1, :)));
    % hold on, 
    % plot(squeeze(irs(iPos, 1, :)), '--');
    % title(sprintf('delay %d', delayL))
    % hold off,
end

% update locals
s.Data.IR = irs;
s.Data.Delay = [0 0];

% update SOFA dimensions
s = SOFAupdateDimensions(s);

return 


%% debug

% load sofa 
filePath = '/Users/pyrus/SharedData/HRTFs/listen_hrir_subset/raw/sofa/listen_irc_1008.sofa';
s1 = SOFAload(filePath);

% test method
s2 = s1;
s2 = dpq.sofa.extractItd(s1, 0, 3e-2);
s2 = dpq.sofa.reinjectItd(s2);
selVect = 1:min(size(s1.Data.IR, 3), size(s2.Data.IR, 3));

% compare outputs (single)
id = 1; ch = 2;
l = squeeze( s1.Data.IR(id, ch, selVect) );
r = squeeze( s2.Data.IR(id, ch, selVect) );
plot(l); hold on
plot(r+0.2);
plot(l-r+0.4); hold off
legend({'original', 'processed', 'difference'});
grid on, grid minor


% % compare outputs (all)
% l = squeeze( s2.Data.IR(:, 1, selVect) ) - squeeze( s1.Data.IR(:, 1, selVect) );
% r = squeeze( s2.Data.IR(:, 2, selVect) ) - squeeze( s1.Data.IR(:, 2, selVect) );
% surf(l-r);




