function sOut = ir2fir(sIn, nfft)

% Convert sofa IR to FIR (time to freq domain)
% 
% sOut = ir2fir(sIn, nfft)
% 
% sOut and sIn are sofa structures. nfft is optional

% default args
if( nargin < 2 )
    % get ir final length
    irTmp = squeeze( sIn.Data.IR(1, 1, :) );
    fs = sIn.Data.SamplingRate;
    nfft = length( dpq.math.fft( irTmp, fs ) );
end



% init ir
IR = nan( size(sIn.Data.IR,1), size(sIn.Data.IR,2), nfft);

% loop over positions
for iPos = 1:size(sIn.Data.IR, 1)
    
% loop over channels
for iCh = 1:size(sIn.Data.IR, 2)

    % get ir
    ir = squeeze( sIn.Data.IR(iPos, iCh, :) );
    
    % get fir: ir to fir
    [fir, ~] = dpq.math.fft(ir, sIn.Data.SamplingRate, nfft);
    
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

return 


%% debug

% load sofa 
filePath = '/Users/pyrus/SharedData/HRTFs/listen_hrir_subset/raw/sofa/listen_irc_1008.sofa';
sIr = SOFAload(filePath);

% ir to fir
sFir = dpq.sofa.ir2fir(sIr);

% plot
posId = 1;
chId = 1;
ir = squeeze(sIr.Data.IR(posId, chId, :));
fir = squeeze(sFir.Data.IR(posId, chId, :));
fs = sIr.Data.SamplingRate;

t = (0:(length(ir)-1))/fs;
f = (fs/2) * linspace(0, 1, length(fir));
subplot(211), plot(t, ir);
subplot(212), semilogx(f, fir);










