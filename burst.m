function buffer = burst(num_burst, fs)

% Generates a vector of num_burst white audio bursts at sampling freq fs
%
% buffer = burst(num_burst, fs)
%
%  

% Same burst as that used in [1]
% [1] David Poirier-Quinot, Brian Katz. On the improvement of accommodation 
% to non-individual HRTFs via VR active learning and inclusion of a 3D room 
% response. Acta Acustica, EDP Sciences, 2021, 5, pp.25. 
% ⟨10.1051/aacus/2021019⟩. ⟨hal-03263411⟩
% 
% "The taser audio stimulus was a sequence of three bursts of white noise,
% 40 ms each with a 4 ms cosine-squared onset/offset ramp and a 70 ms 
% inter-onset interval for a total duration of 180 ms"

   
% create burst
duration = 0.04; % burst duration, in sec
buffer = wgn(ceil(fs*duration), 1, 0);
% burst = rand(ceil(fs*duration), 1)-0.5;

% % plot
% [y, f] = dpq.math.fft(burst, fs);
% semilogx(f, mag2db(y));
% grid on, grid minor,
% xlim([32 f(end)]);
% ylabel('amplitude (dB)'); xlabel('frequency (Hz)');
% xticks(10^3 * (2 .^ (-4:5)));

% normalise
buffer = 0.99 * buffer / max(abs(buffer));

% create window
duration = 0.004; % window fade in duration, in sec
win = hann(ceil(fs*duration)*2+1);
win = win(1:ceil(length(win)/2));
% plot((0:(length(win)-1))/fs, win);

% apply window
buffer(1:length(win)) = win .* buffer(1:length(win));
buffer(((end-length(win))+1):end) = flipud(win) .* buffer(((end-length(win))+1):end);

% concatenate
duration = 0.03; % IOI pause duration, in sec
silence = zeros(ceil(duration*fs), 1);
bufferTmp = [];
for iBurst = 1:num_burst
    bufferTmp = [bufferTmp; buffer];
    if( iBurst < num_burst )
        bufferTmp = [bufferTmp; silence];
    end
end
buffer = bufferTmp;

return 


%% debug

fs = 44100;
buffer = dpq.burst(3, fs);
plot((0:(length(buffer)-1))/fs, buffer);

