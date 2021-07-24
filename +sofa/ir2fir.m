function [sOut] = ir2fir(sIn, nfft)

% convert IR sofa to FIR sofa (time to freq domain)
%
% Usage
%   [sOut] = sofaIR2FIR(sIn, nfft)
%
% Input
%   sIn: sofa struct
%   nfft: num fft samples
%
% Output
%   sOut: sofa struct
%
% Authors
%   David Poirier-Quinot

warning('need to re-implement fft based on dpq.fft');

% init locals
IR = nan( size(sIn.Data.IR,1), size(sIn.Data.IR,2), nfft);
stimuli = zeros(nfft, 1);
stimuli(1) = 1;

% loop over positions
for iPos = 1:size(sIn.Data.IR, 1)
    
% loop over channels
for iCh = 1:size(sIn.Data.IR, 2)

    % get ir
    ir = squeeze( sIn.Data.IR(iPos, iCh, :) );
    
    % get fir: ir to fir
    fir = abs(fft(ir, nfft*2)); 
    fir = fir(1:length(fir)/2);  
    
    % store to locals
    IR(iPos, iCh, :) = fir;

end
end

% sanity check 
if( any( isnan( IR ) ) ); error('incomplete assign'); end

% update field
sOut = sIn;
sOut.Data.IR = IR;

% update SOFA dimensions
sOut = SOFAupdateDimensions(sOut);