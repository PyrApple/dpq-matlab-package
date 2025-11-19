function sOut = resample(sIn, fs)

% Resample SOFA IR frequency
%
% s = resample(s, Fs)
% 
% fs is the new sampling frequency

% discard is already correct sampling frequency
if( sIn.Data.SamplingRate == fs )
    warning('resampling discarded (already at correct sampling freq.)');
end

% init locals
N = ceil( (fs/sIn.Data.SamplingRate) * size(sIn.Data.IR, 3) ); % new length
IR = zeros(size(sIn.Data.IR, 1), size(sIn.Data.IR, 2), N);

% loop over irs
for iPos = 1:size(sIn.Data.IR, 1)
    for iCh = 1:size(sIn.Data.IR, 2)
        
        % resample
        IR(iPos, iCh, :) = resample(squeeze( sIn.Data.IR(iPos, iCh, :) ), fs, sIn.Data.SamplingRate);
        
    end
end

% save to local
sOut = sIn;
sOut.Data.IR = IR;

% resample Delays
sOut.Data.Delay = sOut.Data.Delay * (fs / sOut.Data.SamplingRate);

% update sampling rate
sOut.Data.SamplingRate = fs;

return


%% debug

% load sofa 
filePath = '/Users/pyrus/SharedData/HRTFs/listen_hrir_subset/raw/sofa/listen_irc_1008.sofa';
s1 = SOFAload(filePath);

% norm
s2 = dpq.sofa.resample(s1, s1.Data.SamplingRate*3);

% plot
posId = 1;
chId = 1;
ir1 = squeeze(s1.Data.IR(posId, chId, :));
ir2 = squeeze(s2.Data.IR(posId, chId, :));
t1 = (0:(length(ir1)-1))/s1.Data.SamplingRate;
subplot(211), plot(t1, ir1); xlim([0 4e-3]);
t2 = (0:(length(ir2)-1))/s2.Data.SamplingRate;
subplot(212), plot(t2, ir2); xlim([0 4e-3]);
