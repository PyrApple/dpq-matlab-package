function [delaySamp] = getMinFirstOnset(sIn, onsetThresh)

% sofaGetMinFirstOnset return the min number of samples before onsetThresh 
% (rel value wrt sIn individual amplitudes) for all sofa file pos /
% channels. used to know before using methods like sofaExtractItd if the
% whole IR set requires a time offset to make sure nPointsHead variable
% (see sofaExtractItd) is respected 
%
% Usage
%   [minDelayInSamples] = sofaGetMinFirstOnset(sIn)
%
% Input
%   sIn: sofa struct
%
% Output
%   minDelayInSamples: minimum time between IR start and reach of
%   onsetThreash, across all positions and channels
%
% Authors
%   David Poirier-Quinot

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