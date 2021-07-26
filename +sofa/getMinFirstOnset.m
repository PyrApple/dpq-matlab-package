function [delaySamp] = getMinFirstOnset(sIn, onsetThresh)

% Return the minimum duration between IR start and reach of onsetThresh, 
% across all positions and channels.
% 
% [delaySamp] = getMinFirstOnset(sIn, onsetThresh)

% init 
delaySamp = Inf;

% loop over IR to extract delay values
for iPos = 1:size(sIn.Data.IR,1)
for iCh = 1:size(sIn.Data.IR,2)
    
    % get IR delay
    ir = squeeze( sIn.Data.IR(iPos, iCh, :) );
    delaySampTmp = firstOnset(ir, onsetThresh);
    
    % safety (few samples before)
    delaySamp = min(delaySamp, delaySampTmp);
    
end
end