function [mse, sd] = compareFIR(sofaFirA, sofaFirB)

% sofaPairwiseComp computes various metrics to compare two sofa FIRs

% sanity check
if( sofaFirA.API.M ~= sofaFirB.API.M ); error('mismatch number of source positions'); end
if( sofaFirA.API.R ~= sofaFirB.API.R ); error('mismatch number of channels'); end
if( sofaFirA.API.N ~= sofaFirB.API.N ); error('mismatch number of samples'); end
if( sofaFirA.Data.SamplingRate ~= sofaFirB.Data.SamplingRate ); error('mismatch sampling rates'); end

% init locals
nSamp = sofaFirA.API.N;

% extract data
xA = abs( sofaFirA.Data.IR(:) );
xB = abs( sofaFirB.Data.IR(:) );

% normalize
% figure, plot(xA);  title('xA');
xA = xA / max(xA); xB = xB / max(xB);

% compute differences
mse = 100 * vecnorm(xA - xB, 2, 1).^2 ./ vecnorm(xB, 2, 1).^2;
sd = sqrt( sum(mag2db( xA ./ xB ).^2 ) / nSamp );

end

% function [firWarped, fNormWarped] = localWarpFIR(fir, fNorm, warpFactor)
% 
%     % init frequency warping
%     barkWarp = @(w, lambda) angle( ( exp(1i*w) - lambda ) ./ (1 - lambda * exp(1i*w)));
% 
%     % get warped (weighted really) target fir
%     w = pi*fNorm;
%     wWarp = barkWarp( w, -warpFactor );
%     firWarped = interp1(w, fir, wWarp, 'linear');
% 
%     fNormWarped = wWarp / pi;
% 
% end


function [fitScoreSamples, fitScoreBands] = sofaCompFIR(firA, firB)

% firA and firB are sofa frequency IR
% fitScoreSamples is nPos x nCh vector
% fitScoreBands is nPos x nCh x nBand vector

% sanity check
if( firA.API.M ~= firB.API.M ); error('mismatch number of pos'); end
if( firA.API.R ~= firB.API.R ); error('mismatch number of channels'); end
if( firA.API.N ~= firB.API.N ); error('mismatch number of samples'); end
if( firA.Data.SamplingRate ~= firB.Data.SamplingRate ); error('mismatch sampling rate'); end

% init locals
nPos = firA.API.M; nCh = firA.API.R; nSamp = firA.API.N;
fNorm = linspace(0, 1, nSamp);
fs = firA.Data.SamplingRate;

% get number of bands used for analysis
[~, fc] = bandwiseDelta(0, 0, 0, 0); 
nBands = length(fc);

% init loop
fitScoreBands = struct('score', nan(nPos, nCh, nBands), 'fc', fc);
fitScoreSamples = nan(nPos, nCh);

% loop over positions
for iPos = 1:nPos 

    % loop over channels
    for iCh = 1:nCh

        % get locals
        a = squeeze( firA.Data.IR(iPos, iCh, :) );
        b = squeeze( firB.Data.IR(iPos, iCh, :) );

        % assess fit: per-band
        [score, ~] = bandwiseDelta( a, fs*fNorm, b, fs*fNorm);
        fitScoreBands.score(iPos, iCh, :) = score;

        % assess fit: per-samples
        score = sum(abs( mag2db(a) - mag2db(b) ));
        fitScoreSamples(iPos, iCh) = score;

    end

end
    
end

