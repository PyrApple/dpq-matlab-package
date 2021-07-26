function c = edc(x)
%  
% edc = calcEDC(x)
% edc is the energy-decay curve of the impulse response x. 
% For matrices, operates along first dimension.

x2 = sqrt(x.^2);
E = sum(x2);
y = E-cumsum(x2);
c = mag2db(y)-mag2db(max(y));

return 

%% test

% create ir
rt60 = 1.0; fs = 44100;
x = wgn( ceil(rt60 * fs), 1, 1);
t = ((0:(length(x)-1)).')/fs;
x = x .* db2mag(-t * 60/rt60);

% compute EDC
y = dpq.ir.edc(x);

% plot
plot(t, mag2db(x) - mag2db(max(abs(x)))); 
hold on
plot(t, y);
hold off

% linear regression
selVect = 1:500;
a = t(selVect)\y(selVect);
fprintf('rt60 estimate: %.1f sec\n', a / -60);

% format
o = max(y); ylim([o-100 o]);
