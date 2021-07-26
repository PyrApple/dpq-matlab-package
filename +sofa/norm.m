function [sOut, normFactor] = norm(sIn)

% sofaNorm normalize ir amplitude in sofa struct (based on rms value)
%
% Usage
%   [sOut] = sofaNorm(sIn)
%
% Input
%   sIn: sofa struct
%
% Output
%   sOut: sofa struct
%
% Authors
%   David Poirier-Quinot

% define output
sOut = sIn;

% get overall rms
% g = mean(mean(sum(abs(sIn.Data.IR),3)));
% g = mean(mean( sqrt(sum( sIn.Data.IR.^2 ,3)) ));


% get power across samples and channels
normFactor = sum( (sum( sOut.Data.IR.^2 ,3)), 2);
% mean power over positions
normFactor = sqrt( mean(normFactor) );

% apply norm
sOut.Data.IR = sOut.Data.IR / normFactor;

% % peak normalization
% g = max(abs(sOut.Data.IR), [], 3); % over time
% g = max(g,[],2); % over ear
% g = mean(g); % over pos
% sOut.Data.IR = sOut.Data.IR / g;

return 


%% debug

% load sofa 
filePath = '/Users/pyrus/SharedData/HRTFs/listen_hrir_subset/raw/sofa/listen_irc_1008.sofa';
s1 = SOFAload(filePath);

% norm
[s2, normFactor] = dpq.sofa.norm(s1);

% plot
posId = 1;
chId = 1;
ir1 = squeeze(s1.Data.IR(posId, chId, :));
ir2 = squeeze(s2.Data.IR(posId, chId, :));
fs = s1.Data.SamplingRate;
t = (0:(length(ir1)-1))/fs;
subplot(211), plot(t, ir1);
subplot(212), plot(t, ir2);
