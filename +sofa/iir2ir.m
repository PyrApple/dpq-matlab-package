function [sOut] = iir2ir(sIn, nfft)

% convert IIR sofa to IR sofa
%
% Usage
%   [sOut] = sofaIIR2IR(sIn)
%
% Input
%   sIn: sofa struct
%
% Output
%   sOut: sofa struct
%
% Authors
%   David Poirier-Quinot

% init locals
IR = nan( size(sIn.Data.IR,1), size(sIn.Data.IR,2), nfft);
stimuli = zeros(nfft, 1);
stimuli(1) = 1;

% loop over positions
for iPos = 1:size(sIn.Data.IR, 1)
    
% loop over channels
for iCh = 1:size(sIn.Data.IR, 2)

    % get iir coefs
    iir = squeeze( sIn.Data.IR(iPos, iCh, :) );
    nCoef = length(iir) / 2;
    b = iir(1:nCoef); a = iir( (nCoef+1): end);

    % % iir to fir
    % [firFit, w] = freqz(b, a, nfft);
    % 
    % % fir to ir
    % IR(iPos, iCh, :) = ifft(firFit, nfft);
    
    % iir to ir
    IR(iPos, iCh, :) = filter(b, a, stimuli);

end
end

% sanity check 
if( any( isnan( IR ) ) ); error('incomplete assign'); end

% update field
sOut = sIn;
sOut.Data.IR = IR;

% update SOFA dimensions
sOut = SOFAupdateDimensions(sOut);