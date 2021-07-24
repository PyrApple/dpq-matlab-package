function [sOut] = crop(sIn, onsetThresh)

% sofaCrop crop ir tail in sofa struct (based on rel. linear threshold value)
%
% Usage
%   [sOut] = sofaCrop(sIn, thresh)
%
% Input
%   sIn: sofa struct
%   onsetThresh: last onset threshold value (linear, relative)
%
% Output
%   sOut: sofa struct
%
% Authors
%   David Poirier-Quinot

if( nargin < 2 ); onsetThresh = 1e-3; end

% define output
sOut = sIn;

% loop over IR to find max last onset value
lastOnsetIndex = 0;
for iPos = 1:size(sIn.Data.IR,1)
for iCh = 1:size(sIn.Data.IR,2)
    ir = squeeze( sIn.Data.IR(iPos, iCh, :) );
    lastOnsetIndex = max(lastOnsetIndex, lastOnset(ir, onsetThresh)); 
end
end

% crop IR based on max last onset value
if( size(sIn.Data.IR,3) > lastOnsetIndex )
    % resize output IR length
    sOut.Data.IR = zeros( size(sIn.Data.IR, 1), size(sIn.Data.IR, 2), lastOnsetIndex);
    for iPos = 1:size(sIn.Data.IR,1)
    for iCh = 1:size(sIn.Data.IR,2)
        sOut.Data.IR(iPos, iCh, :) = squeeze(sIn.Data.IR(iPos, iCh, 1:lastOnsetIndex));
    end
    end
else
    warning('crop discraded (threshold too low, nothing to crop)');
end

% update SOFA dimensions
sOut = SOFAupdateDimensions(sOut);