function [y, f] = fft(x, fs)

% sanity check 
if( ~isvector(x) ); error('expected vector input'); end

% respect caller's vector orientation
needFlip = false; if( size(x, 1) == 1); x = x.'; needFlip = true; end

% zero pad
nfft = pow2(nextpow2(length(x)));
x = [ x; zeros( nfft - length(x), 1 ) ];

% fft
y = fft(x, nfft);
n = length(y);

% magnitude
y = abs(y/n);

% keep only positive freq
y = y(1:n/2+1);
% y(2:end-1) = 2*y(2:end-1);

% associated freq
f = (fs/2) * linspace(0, 1, n/2 + 1);
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
t = (0:1*fs)/fs;
f1 = 300; f2 = 1200;
x = sin(2*pi*f1*t) + sin(2*pi*f2*t);

[y, f] = dpq.math.fft(x, fs);

plot(t, x);
semilogx(f, y); xlim([33 f(end)]);