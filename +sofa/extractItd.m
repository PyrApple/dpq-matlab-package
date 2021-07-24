function [sOut] = extractItd(sIn, nPointsBeforeOnsetHead, onsetThresh)

% sofaExtractItd return a time-aligned (threshold itd extraction) version
% of input sofa struct
%
% Usage
%   [sOut] = sofaExtractItd(sIn, nPointsHead, onsetThresh)
%
% Input
%   sIn: sofa struct
%   nPointsBeforeOnsetHead: number of points before first onset
%   onsetThresh: first onset threshold value (linear, relative)
%
% Output
%   sOut: sofa struct
%
% Authors
%   David Poirier-Quinot

if( nargin < 2 ); onsetThresh = 1e-3; end
if( nargin < 3 ); nPointsBeforeOnsetHead = 20; end

% skip if delay already extracted in Data.Delay field
if( size(sIn.Data.Delay, 1) == size(sIn.Data.IR, 1) )
    warning('hrir already aligned, itd alignement operation discarded \n');
    sOut = sIn;
    return
end

% define output
sOut = sIn;
sOut.Data.Delay = zeros( size(sIn.Data.IR,1), size(sIn.Data.IR,2) );

% get min num samples before onsetThresh in whole IR
minDelayBeforeOnset = sofaGetMinFirstOnset(sOut, onsetThresh);
if( minDelayBeforeOnset <= nPointsBeforeOnsetHead)
    numSampPadding = nPointsBeforeOnsetHead - minDelayBeforeOnset + 1;
    sOut.Data.IR = zeros(size(sOut.Data.IR, 1), size(sOut.Data.IR, 2), size(sOut.Data.IR, 3) + numSampPadding);
    warning('padding IR beginning with %ld zeros to match nPointsBeforeOnsetHead criteria (current min delay before onset is %ld samp)', numSampPadding, minDelayBeforeOnset);
    for iPos = 1:size(sOut.Data.IR,1)
    for iCh = 1:size(sOut.Data.IR,2)
        sOut.Data.IR(iPos, iCh, :) = cat(3, zeros(1,1,numSampPadding), sIn.Data.IR(iPos, iCh, :));
    end
    end
end

% loop over IR to extract delay values
for iPos = 1:size(sOut.Data.IR,1)
for iCh = 1:size(sOut.Data.IR,2)
    
    % get IR delay
    ir = squeeze( sOut.Data.IR(iPos, iCh, :) );
    delaySampTmp = firstOnset(ir, onsetThresh);
    
    % safety (few samples before)
    delaySamp = delaySampTmp - nPointsBeforeOnsetHead;
    
    % align IR and add delay to struct
    if( delaySamp > 0 )
        % save delay in sofa struct
        sOut.Data.Delay(iPos, iCh) = delaySamp;
        % 'circular' shift (with zero at the end) not changing hrir length
        ir = [ ir(delaySamp:end); zeros(delaySamp-1, 1)];
        % save back ir to sofa struct
        sOut.Data.IR(iPos, iCh, :) = ir;
    % skip, usualy because nPointsBeforeOnsetHead is too big
    else
        plot(ir);
        line([delaySampTmp delaySampTmp], [min(ir), max(ir)], 'Linestyle', '--', 'Color', 'r');
        error('negative delay, nPointsBeforeOnsetHead to big or thresh too low.'); 
    end
end
end

% update SOFA dimensions
sOut = SOFAupdateDimensions(sOut);