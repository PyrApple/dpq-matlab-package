function [last_onset_n] = lastOnset(ir_m, thresh)

% Detects last onset above thresh in matrix or impulse responses
%
% last_onset_n = lastOnset(ir_m, thresh)
%
% ir_m is a matrix of impulse responses, each column an ir, thresh is the
% onset relative (to max ir value) threshold

% init default arguments
if( nargin < 2 ); thresh = 1e-3; end

% init locals
last_onset_n = -Inf;

% loop over irs
for i = 1:size(ir_m,2)
    
    % find last onset
    ir_v = abs(ir_m(:,i));
    last = find(ir_v > max(ir_v) * thresh, 1, 'last');
    
    % save to locals
    last_onset_n = max(last_onset_n, last);
    
end

return 


%% debug

% load sofa 
filePath = '/Users/pyrus/SharedData/HRTFs/listen_hrir_subset/raw/sofa/listen_irc_1008.sofa';
s = SOFAload(filePath);

ir_m = squeeze(s.Data.IR(:, 1, :)).';
idStop = dpq.ir.lastOnset(ir_m, .5e-1)