%% load file
sIn = SOFAload('/Users/pyrus/SharedData/HRTFs/listen_hrir_subset/compensated/sofa/listen_irc_c_1008.sofa');

return;

%% debug extract itd
onsetThresh = 40e-3;
numSampBeforeOnset = 20;
sOut = sofaExtractItd(sIn, numSampBeforeOnset, onsetThresh);

for iPos = 1:size(sOut.Data.IR,1)
for iCh = 1:size(sOut.Data.IR,2)
    fOnsetVal = firstOnset(squeeze(sOut.Data.IR(iPos, iCh, :)), onsetThresh);
    if( fOnsetVal ~= numSampBeforeOnset + 1)
        error('error');
    end
end
end

plot( squeeze(sOut.Data.IR(:,1,:))' );
fprintf('debug extract itd success \n');

%% debug crop ir
sOut = sofaCrop(sIn, 0.1*onsetThresh);
plot( squeeze(sOut.Data.IR(:,1,:))' );
fprintf('debug crop hrir success \n');

%% debug sofa resample

% init (extract itd to test resampling on both ir and delays)
sIn2 = sofaExtractItd(sIn);

% resample
resamplingFactor = 2; % integer, >= 1
fsIn = sIn.Data.SamplingRate;
fsOut = sIn.Data.SamplingRate * resamplingFactor;
sOut = sofaResample(sIn2, fsOut);

% test resampling delays
errorDelays = sIn2.Data.Delay - (fsIn/fsOut)*sOut.Data.Delay;
if( sum(sum(abs(errorDelays))) > 1e-5 )
    subplot(311), plot(sIn2.Data.Delay); title('delay in');
    subplot(312), plot(sOut.Data.Delay); title('delay out');
    subplot(313), plot(errorDelays); title('delay diff');
    error('error in delay resampling');
end

errIr = zeros(size(sIn2.Data.IR, 1), size(sIn2.Data.IR, 2));
selVect = 1:resamplingFactor:size(sOut.Data.IR, 3);
for iPos = 1:size(sIn2.Data.IR, 1)
    for iCh = 1:size(sIn2.Data.IR, 2)
        irDiff = squeeze(sIn2.Data.IR(iPos, iCh,:) - sOut.Data.IR(iPos, iCh,selVect));
        errIr(iPos, iCh) = sum(abs(irDiff));
    end
end

errMax = max(max(abs(errIr)));
irMax = max(max(max(abs(sIn2.Data.IR))));
tolerance = 1e-2;
if( errMax >= tolerance * irMax )
    % plot worst case scenario
    [tmp, posId] = max(abs(errIr));
    [~, chId] = max(abs(tmp));
    posId = posId(chId);
    tIn = (1:size(sIn2.Data.IR,3)) / fsIn;
    tOut = (1:size(sOut.Data.IR,3)) / fsOut;
    plot(tIn, squeeze(sIn2.Data.IR(posId, chId, :))); hold on,
    plot(tOut, squeeze(sOut.Data.IR(posId, chId, :)), '--r'); hold off,
    title('orig vs interp IR'); legend({'orig', 'interp'});    
    % throw error
    error('error in delay resampling');
end

%% TODELETE
% test resampling ir

chId = 1; posId = 1;
irIn = squeeze(sIn2.Data.IR(posId, chId,:));
irOut = squeeze(sOut.Data.IR(posId, chId,:));

plot(tIn, irIn); hold on, plot(tOut, irOut, '--'); hold off, legend({'in', 'out'});


%% debug spherical harmonic interpolation 

% prepare interpolation 
onsetThresh = 50e-3;
numSampBeforeOnset = 20;
sIn2 = sofaExtractItd(sIn, numSampBeforeOnset, onsetThresh);

% apply interpolation 
gridStep = 15;
sOut = sofaInterpSphHarm(sIn2, gridStep);

%% debug
% find matching positions pairs (between old and newly interp struct)

% find matching indices
[C, IA, IB] = intersect(sIn2.SourcePosition, sOut.SourcePosition, 'rows');

% how much point from original grid found in interp. grid
fprintf('num matching points: %ld (%.1f perc. of original) \n', length(IA), 100 * length(IA) / size(sIn.SourcePosition,1) );

% plot matching points
[X,Y,Z] = sph2cart(deg2rad(C(:,1)),deg2rad(C(:,2)), C(:,3)); 
scatter3(X,Y,Z, '.');

% aed = sIn2.SourcePosition(IA, :);
% [X,Y,Z] = sph2cart(deg2rad(aed(:,1)), deg2rad(aed(:,2)), aed(:,3)); 
% scatter3(X,Y,Z, '.');
% hold on
% aed = sOut.SourcePosition(IB, :);
% [X,Y,Z] = sph2cart(deg2rad(aed(:,1)), deg2rad(aed(:,2)), aed(:,3)); 
% scatter3(X,Y,Z, 'o');
% hold off

% error on ITD

funSampToMs = @(x, f) 1000 * x / f;

delta = sOut.Data.Delay(IB,:) - sIn2.Data.Delay(IA,:);
subplot(121), plot(sIn2.Data.Delay(IA,1) - sIn2.Data.Delay(IA,2));
subplot(122), plot(sOut.Data.Delay(IB,1) - sOut.Data.Delay(IB,2));

subplot(121), plot(sIn2.Data.Delay(IA,:));
subplot(122), plot(sOut.Data.Delay(IB,:));

delta = (sIn2.Data.Delay(IA,1) - sIn2.Data.Delay(IA,2)) - (sOut.Data.Delay(IB,1) - sOut.Data.Delay(IB,2));
delta = funSampToMs(delta, sIn.Data.SamplingRate);
fprintf('summed (abs) error on itd interp: %.1f ms \n', sum(abs(delta)) );
clf, plot(delta);

% from https://www.researchgate.net/publication/8889656_Separation_of_concurrent_broadband_sound_sources_by_human_listeners
itdMinPerceptiveThresh = 0.05;
itdMaxInterpError = max(abs(delta));
if( itdMaxInterpError > itdMinPerceptiveThresh )
    warning('max itd error (%.1fms) above perceptive threshold (%.1fms)', itdMaxInterpError, itdMinPerceptiveThresh);
end

% check (plot) itd interpolation
itd_v = sIn2.Data.Delay(:,1) - sIn2.Data.Delay(:,2);
itd_v = funSampToMs(itd_v, sIn.Data.SamplingRate);
scatter3(sIn2.SourcePosition(:,1), sIn2.SourcePosition(:,2), itd_v, 'o'); hold on
itd_v = sOut.Data.Delay(:,1) - sOut.Data.Delay(:,2);
itd_v = funSampToMs(itd_v, sIn.Data.SamplingRate);
scatter3(sOut.SourcePosition(:,1), sOut.SourcePosition(:,2), itd_v, '.'); hold off
legend({'original', 'interp'}); title('itd orig vs interp');
zlabel('itd (ms)');


% % error on IR

% time diff
lMin = min(sIn2.API.N, sOut.API.N);
earId = 1; % 1 is left, 2 is right
irInterp = squeeze(sOut.Data.IR(IB,earId,1:lMin)); % left
irOrigin = squeeze(sIn2.Data.IR(IA,earId,1:lMin));

subplot(311), surf(irOrigin); shading interp; view([0 90]); title('orig.')
colorbar
subplot(312), surf(irInterp); shading interp; view([0 90]); title('interp.')
colorbar
subplot(313), surf(abs(irInterp - irOrigin)); shading interp; view([0 90]); title('diff.')
colorbar

return

clf,
posId = 1;
plot(irOrigin(posId,:));
hold on 
plot(irInterp(posId,:), '--r');
hold off

plot(irInterp-irOrigin);

return;

% freq diff
Nt = lMin; Ntf = pow2(nextpow2(Nt));
Np = length(IA); % num pos in common
irInterpF = zeros(Np, Ntf/2 + 1); irOriginF = irInterpF;
for i = 1:Np % num common pos
    irOriginF(i,:) = fft_perso(irOrigin(i,:), Nt, Ntf);
    irInterpF(i,:) = fft_perso(irInterp(i,:), Nt, Ntf);
end

subplot(311), surf(real(irOriginF)); shading interp; view([0 90]); title('orig.')
colorbar
subplot(312), surf(real(irInterpF)); shading interp; view([0 90]); title('interp.')
colorbar
subplot(313), surf(real(irOriginF-irInterpF)); shading interp; view([0 90]); title('diff.')
colorbar

%% debug sofaMeanSquareError

rootPath = '/Users/pyrus/SharedData/HRTFs/listen_hrir_subset/raw/sofa/';
fileList = dir([rootPath '*.sofa']);

for iFile = 2:length(fileList)
    
    % load 
    refId = 1;
    sRef = SOFAload(fullfile(rootPath, fileList(refId).name));
    sTmp = SOFAload(fullfile(rootPath, fileList(iFile).name));
    
    % compute diff
    [mse, sd] = sofaPairwiseComp(sTmp, sRef, 0, 20e3);
    
    % log
    fprintf('%s vs. %s:\n', fileList(refId).name, fileList(iFile).name);
    fprintf('\t mse: %.1f%% \n', mse);
    fprintf('\t sd:  %.1f \n', sd);
    
end




%% Sonification trip
s = sOut;

y = squeeze(s.Data.IR(:,1,:));
y = y/(1.1*max(max(abs(y)))); y = y.'; y = y(:); y = y - mean(y);

x = y;

y = squeeze(s.Data.IR(:,2,:));
y = y/(1.1*max(max(abs(y)))); y = y.'; y = y(:); y = y - mean(y);

y = [x y];
clf
plot(y);

fs = 44100;
fs = 8000;
% soundsc(y,fs);

% clear sound
fileName = 'itdtRemoved_interp';
filePath = fullfile(pwd, [fileName '.wav'] );
audiowrite(filePath, y, fs);

