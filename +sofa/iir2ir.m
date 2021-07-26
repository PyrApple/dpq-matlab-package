function sOut = iir2ir(sIn, nSamples)

% Convert sofa IIR to IR
%
% sOut = iir2ir(sIn, nSamples)
% 
% nSamples is the length of the impulse response used in the conversion

% init locals
IR = nan( size(sIn.Data.IR,1), size(sIn.Data.IR,2), nSamples);
stimuli = zeros(nSamples, 1);
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