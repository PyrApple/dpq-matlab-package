
function [reverbTail] = getReverbTail(rt60, initGainDb, initDelaySec, fs, freqBands)
%  
% [reverbTail] = getReverbTail(rt60, initGainDb, initDelaySec, fs)
% reverbTail is a gaussian noise exponentially decreasing reverb tail.
% Given a vector rt60, reverbTail will be frequency specific.
% 
% rt60: response time (sec)
% initGainDb: initial gain of reverb tail (dB)
% initDelaySec: initial delay of reverb tail, applying decrease slope (sec)
% 
% advice: use freqBands = 10^3 * (2 .^ (-4:3));

% multi freq band test
useMultiBand = false;
if( length(rt60) > 1 )
    
    % sanity check on freq band input
    if(  nargin < 5 ); error('missing freqBands input argument'); end
    
    % sanity check on matching num elmts in rt60 and freqBands
    if( length(rt60) ~= length(freqBands) ); error('mismatch rt60 and freqBands length'); end
    
    % enable multi band
    useMultiBand = true;
    
end

% init locals
initGain = 10^(initGainDb/20); % in dB
tailSlope = -60 ./ rt60; 
filterOrder = 3;

% generate gaussian noise
nSamp = ceil(fs * max(rt60));
%
% gaussianNoise = 2*(rand(nSamp, 1) - 0.5);
% gaussianNoise = randn(nSamp, 1);
% gaussianNoise = wgn(nSamp, 1, 0);
gaussianNoise = wgn(nSamp, 1, 2); % mean of 1
%
% gaussianNoise = gaussianNoise / max(abs(gaussianNoise));

% define decrease envelope 
gain_f = @(g0, t, slope) 10.^( ( 20*log10(g0) + t * slope ) /20 ); % in secs
time = ( ( 0:(nSamp-1) ) / fs ).';

if( ~useMultiBand )
    
    % get envelope 
    gain_v = gain_f(initGain, time, tailSlope);

    % shape noise with envelope
    reverbTail = (gain_v .* gaussianNoise).';
    
else
    
    % init output
    reverbTail = zeros(length(freqBands), nSamp);
    
    % loop over freq bands
    for iBand = 1:length(rt60)

        % get IIR
        [b, a] = octdsgn(freqBands(iBand), fs, filterOrder);

        % filter gaussian noise 
        gaussianNoiseFiltered = filter(b, a, gaussianNoise);
    
        % get envelope 
        gain_v = gain_f(initGain, time, tailSlope(iBand));

        % shape noise with envelope, sum to output
        reverbTail(iBand,:) = gain_v .* gaussianNoiseFiltered;

    end
    
end

% % fade in
% xFadeSamp = 512; % in samples
% w = hann(2*xFadeSamp);

% zero out init delay
selVect = 1:floor(initDelaySec*fs);
reverbTail(:,selVect) = 0.*reverbTail(:,selVect);


return 

%% debug test mono band

% init 
rt60 = 0.6;
initGainDb = 0;
initDelaySec = 0;
fs = 44100;

% get tail
tail = getReverbTail(rt60, initGainDb, initDelaySec, fs).';

% get edc
edc = 10*log10( flipud( cumsum( flipud( tail.^2 ))));
edc = edc - max(edc);

% plot
t = ( ( 0:(length(tail)-1) ) / fs ).';
plot(t, mag2db(tail));
hold on, 
plot(t, edc);
hold off

% format
ylim([-60 0]);
grid on, grid minor, 


%% debug test multi band

% init 
freqBands = 10^3 * (2 .^ (-4:3));
rt60 = 1:length(freqBands);
initGainDb = 0;
initDelaySec = 0;
fs = 44100;

% get tail
tail = getReverbTail(rt60, initGainDb, initDelaySec, fs, freqBands);

% get edc, rt60
opt = 'OctEx'; % octave bands extended
twin = 0; % in ms, analysis window duration, default value
noiseLimit = 10; % in dB, noise floor, default value
verbose = 0;
[iraCurve, iraCalc] = IRAcalc(tail, fs, opt, noiseLimit, twin, verbose);

% plot tail
t = ( ( 0:(length(tail)-1) ) / fs ).';
h = plot(t, mag2db(tail), 'Color', 0.4 * [1 1 1], 'HandleVisibility','off');
h.Color(4) = 0.1; % alpha

% plot edc
colorMap = hsv(length(iraCurve.Freq));
hold on, 
for iBand = 1:length(iraCalc.Freq)
    plot(iraCurve.time, iraCurve.RICdB(iBand,:), 'Color', colorMap(iBand,:), 'HandleVisibility','off');
end
hold off

% plot rt60: init
% define working freq band
selVect = ismember(freqBands, iraCalc.Freq);
commonFreqBands = freqBands(selVect);
[~, bandIds_iraCalc] = ismember(commonFreqBands, iraCalc.Freq);
[~, bandIds_local] = ismember(commonFreqBands, freqBands);

% plot rt60
hold on
colorMap = colorMap(bandIds_iraCalc, :);
for iBand = 1:length(commonFreqBands)
    
    % target rt60
    bandId = bandIds_local(iBand);
    plot(rt60(bandId), -60, 'ok', 'MarkerSize', 12, 'MarkerFaceColor', colorMap(iBand, :), 'HandleVisibility','off');
    
    % obtained rt60 
    bandId = bandIds_iraCalc(iBand);
    plot(iraCalc.T30_b(bandId), -60, 'ok', 'MarkerSize', 6, 'MarkerFaceColor', colorMap(iBand, :));
    % plot(iraCalc.T30_b(iBand), -60, 'ok', 'MarkerSize', 12, 'MarkerFaceColor', 0.8 * [1 1 1]);
    
end
hold off

% format
legendCell = cellstr(num2str(commonFreqBands', '%d Hz'));
legend(legendCell, 'Location', 'NorthEast');
ylim([-60 0]);
grid on, grid minor, 
