function [onsetIdSamp] = getMinFirstOnset(sIn, onsetThresh)

% Return the minimum duration between IR start and reach of onsetThresh, 
% across all positions and channels.
% 
% [onsetIdSamp] = getMinFirstOnset(sIn, onsetThresh)

% init 
onsetIdSamp = Inf;

% loop over IR to extract delay values
for iPos = 1:size(sIn.Data.IR,1)
for iCh = 1:size(sIn.Data.IR,2)
    
    % get IR delay
    ir = squeeze( sIn.Data.IR(iPos, iCh, :) );
    onsetIdSampTmp = dpq.ir.firstOnset(ir, onsetThresh);
    
    % safety (few samples before)
    onsetIdSamp = min(onsetIdSamp, onsetIdSampTmp);
    
end
end

return 

%% debug

% load sofa 
filePath = '/Users/pyrus/SharedData/HRTFs/listen_hrir_subset/raw/sofa/listen_irc_1008.sofa';
s = SOFAload(filePath);

% test function
idStart = dpq.sofa.getMinFirstOnset(s, 0.99)

