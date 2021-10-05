function [onsetIdSamp, onsetIdIr] = lastOnset(ir_m, thresh)

% Detects last onset above thresh in matrix or impulse responses
%
% last_onset_n = lastOnset(ir_m, thresh)
%
% ir_m is a matrix of impulse responses, each column an ir, thresh is the
% onset relative (to max ir value) threshold

% init default arguments
if( nargin < 2 ); thresh = 1e-3; end

% handle vector input
if( isrow(ir_m) ); ir_m = ir_m.'; end
    
% init locals
onsetIdSamp = -Inf;
onsetIdIr = 0;

% loop over irs
for iIr = 1:size(ir_m,2)
    
    % find last onset
    ir_v = abs(ir_m(:,iIr));
    last = find(ir_v > max(ir_v) * thresh, 1, 'last');
    
    % save to locals
    if( last > onsetIdSamp )
        onsetIdSamp = last;
        onsetIdIr = iIr;
    end
        
end

return 


%% debug

% load sofa 
filePath = '/Users/pyrus/SharedData/HRTFs/listen_hrir_subset/raw/sofa/listen_irc_1008.sofa';
s = SOFAload(filePath);

% shape data
ir_m = squeeze(s.Data.IR(:, 1, :)).';
% ir_m = squeeze(s.Data.IR(:, 1, :)).';

% test function
[idEnd, idIr] = dpq.ir.lastOnset(ir_m, 0.1);

% plot
plot(ir_m, 'Color', 0.8*[1 1 1]);
hold on,
plot(ir_m(:, idIr), '-r');
line([idEnd idEnd], [2*min(min(ir_m)), 2*max(max(ir_m))], 'Color', 'r', 'LineStyle', '--');

% format
hold off, 
grid on, grid minor
