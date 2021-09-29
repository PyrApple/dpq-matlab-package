function sOut = cropEnd(sIn, onsetThresh)

% Crop IR tail in sofa struct based on relative (non-log) threshold value
% 
% sOut = cropEnd(sIn, onsetThresh)
% 
% sIn and sOut are sofa structs. The IR is cropped from end to first sample
% above onsetThresh.


if( nargin < 2 ); onsetThresh = 1e-3; end

% define output
sOut = sIn;

% crop start / end
ir = reshape(sOut.Data.IR, [size(sOut.Data.IR, 1) * size(sOut.Data.IR, 2), size(sOut.Data.IR, 3)] ).';
% ir = [squeeze(s.Data.IR(:, 1, :)); squeeze(s.Data.IR(:, 2, :))].';
% [idStart, idIr] = dpq.ir.firstOnset(ir, 0.05);
[idEnd, idIr] = dpq.ir.lastOnset(ir, onsetThresh);
sOut.Data.IR = sOut.Data.IR(:,:,1:idEnd);

% update SOFA dimensions
sOut = SOFAupdateDimensions(sOut);

return 

%% debug

% load sofa 
filePath = '/Users/pyrus/SharedData/HRTFs/listen_hrir_subset/raw/sofa/listen_irc_1008.sofa';
s = SOFAload(filePath);

s2 = dpq.sofa.cropEnd(s, 0.1);
% s2 = s1;

plot(squeeze(s2.Data.IR(1,1,:)));