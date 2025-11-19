function out = conv(ir, y)
%  
% out = conv(ir, y)
% ir is [m, n] where m is time and n is channel, y is [m,1] vector

useMethod = 'time';

% sanity check
if( ~isvector(y) ); error('expected input vector'); end

% flip input
flipRequired = false;
if( size(y, 1) == 1 ); y = y.'; flipRequired = true; end

switch useMethod

    case 'freq'

        % pad ir (to avoid cropped output)
        ir = [ir; zeros(size(y, 1) - 1, size(ir, 2))];
        
        % filter
        out = fftfilt(y, ir);
    
    case 'time'

        % prepare output
        out = zeros(size(ir, 1) + length(y) - 1, size(ir, 2));
        
        % loop over channels
        for iCh = 1:size(ir, 2)
            out(:, iCh) = conv(y, ir(:, iCh));
        end

end

% flip output
if( flipRequired ); out = out.'; end

return 


%% another freq. based impl. 

% % init fft
% L = length(ir) + length(y) - 1;
% out = zeros(size(ir,2), L);
% 
% % zero pad and compute fft
% X = fft(ir,L); 
% Y = fft(y,L);   
% 
% % convolve
% for iCh = 1:size(ir,2)
%     out(iCh,:) = ifft(Y.*X(:,iCh));
% end
% out = out.';

%% frequency based implementation (todo: compare efficiency)

% function out = convfft2(ir, y)
% 
% % ir is [m, n] where m is time and n is ambisonic channel
% % y is [m,1] mono audio input vector
% 
% % init fft
% L = length(ir) + length(y) - 1;
% out = zeros(size(ir,2), L);
% 
% %zero pad and compute fft
% X = fft(ir,L); 
% Y = fft(y,L);   
% 
% % convolve
% for i = 1:size(ir,2)
%     out(i,:) = ifft(Y.*X(:,i));
% end


%% test

% load audio
load handel % y, Fs
fs = Fs;
audioIn = y;
% audioIn = y(1:floor(0.2 * fs));
% audioIn = audioIn(1:1000, :);

% create ir
% ir = rand( floor(4*fs), 9);
ir = zeros( floor(4*fs), 2);
ir(1, :) = 1;
ir(100, :) = 0.5;
ir(200, :) = 0.3;

% profiling
tic

% convolve
audioOut1 = dpq.math.conv(ir, audioIn);

% profiling
toc 

% % matlab equivalent
% audioOut2 = zeros(size(ir, 1) + size(audioIn,1) - 1, size(ir, 2));
% for iCh = 1:size(ir, 2)
%     audioOut2(:, iCh) = conv(ir(:, iCh), audioIn);
% end

% audioIn2 = [audioIn; zeros(size(ir, 1)-1, size(audioIn, 2))];
ir2 = [ir; zeros(size(audioIn, 1) - 1, size(ir, 2))];
audioOut2 = fftfilt(audioIn, ir2);


% debug plot
% subplot(311), plot((0:(size(audioIn, 1)-1))/fs, audioIn);
% subplot(312), plot((0:(size(ir, 1)-1))/fs, ir);
% subplot(313), plot((0:(size(audioOut1, 1)-1))/fs, audioOut1);
plot(audioOut1 - audioOut2);

soundsc(audioOut1, fs);

display('done');
