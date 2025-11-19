function [y, f] = fft(x, fs, nfft)

%
% [y, f] = fft(x, fs)
%
% nfft is optional

% sanity check 
if( ~isvector(x) ); error('expected vector input'); end

% respect caller's vector orientation
needFlip = false; if( size(x, 1) == 1); x = x.'; needFlip = true; end

% default args
if( nargin < 3 )
    % get fft length as nex power of two
    nfft = pow2(nextpow2(length(x)));
    % x = [ x; zeros( nfft - length(x), 1 ) ];
else
    nfft = (nfft - 1 ) * 2; % compensate for drop negative freqs
end

% fft
y = fft(x, nfft);

% normalise
y = y / fs;

% magnitude
y = abs(y);

% keep only positive freq
y = y(1:nfft/2+1);

% and compensate for energy loss for all but DC
% y(2:end) = 2*y(2:end);

% associated freq
f = (fs/2) * linspace(0, 1, nfft/2 + 1);
f = f.';

% % plot
% semilogx(f, mag2db(y));
% grid on, grid minor,
% xlim([32 f(end)]);
% ylabel('amplitude (dB)'); xlabel('frequency (Hz)');
% xticks(10^3 * (2 .^ (-4:5)));

if( needFlip ); y = y.'; f = f.'; end

return 


%% debug

fs = 44100;
t = (0:0.03*fs)/fs;
f1 = 300; f2 = 1200;
x = sin(2*pi*f1*t) + sin(2*pi*f2*t);
x = x.';

[y, f] = dpq.math.fft(x, fs);

% plot(t, x);
semilogx(f, y); xlim([33 f(end)]);
