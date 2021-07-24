function [sOut, fNormWarped] = warpFIR(sIn, warpFactor)

% apply bark frequency warping to sIn FIR

% init locals
nPos = sIn.API.M; nCh = sIn.API.R; nSamp = sIn.API.N;
fNorm = linspace(0, 1, nSamp);
IR = nan( size(sIn.Data.IR,1), size(sIn.Data.IR,2), nSamp);

% loop over channels and positions
for iCh = 1:nCh
for iPos = 1:nPos
    
    % get fir
    fir = squeeze(sIn.Data.IR(iPos,iCh,:));
    
    % warp
    [firWarped, fNormWarped] = localWarpFIR(fir, fNorm, warpFactor);
    
    % mse = 0; sd = 0;
    % figure, plot(fNormWarped, firWarped), title('new'), return 
    
    % save to locals
    IR(iPos,iCh,:) = firWarped;
    
end
end

% sanity check 
if( any( isnan( IR ) ) ); error('incomplete assign'); end

% update field
sOut = sIn;
sOut.Data.IR = IR;

% update SOFA dimensions
sOut = SOFAupdateDimensions(sOut);



function [firWarped, fNormWarped] = localWarpFIR(fir, fNorm, warpFactor)

    % init frequency warping
    barkWarp = @(w, lambda) angle( ( exp(1i*w) - lambda ) ./ (1 - lambda * exp(1i*w)));

    % get warped (weighted really) target fir
    w = pi*fNorm;
    wWarp = barkWarp( w, -warpFactor );
    firWarped = interp1(w, fir, wWarp, 'linear');

    fNormWarped = wWarp / pi;

return 

