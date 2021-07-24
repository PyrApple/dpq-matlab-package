function [y, f] = fft(x, fs)

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

% % plot
% semilogx(f, mag2db(y));
% grid on, grid minor,
% xlim([32 f(end)]);
% ylabel('amplitude (dB)'); xlabel('frequency (Hz)');
% xticks(10^3 * (2 .^ (-4:5)));