function sOut = extractItd(sIn, requiredNumPointsBeforeOnset, onsetThresh)

% Return a time-aligned version of IR sofa struct. 
% 
% sOut = extractItd(sIn, requiredNumPointsBeforeOnset, onsetThresh)
% 
% The extracted ITD is stored in the sofa "Delay" field. ITD extraction is 
% based on onset threshold (onsetThresh). requiredNumPointsBeforeOnset defines
% the number of samples kept in the IR before onset threshold.

% init arguments
if( nargin < 2 ); onsetThresh = 1e-3; end
if( nargin < 3 ); requiredNumPointsBeforeOnset = 20; end

% skip if delay already extracted in Data.Delay field
if( size(sIn.Data.Delay, 1) == size(sIn.Data.IR, 1) )
    warning('hrir already aligned, itd alignement operation discarded \n');
    sOut = sIn;
    return
end

% define output
sOut = sIn;
sOut.Data.Delay = zeros( size(sIn.Data.IR,1), size(sIn.Data.IR,2) );

% get min num samples before onsetThresh in whole IR
minDelayBeforeOnset = dpq.sofa.getMinFirstOnset(sOut, onsetThresh);
if( minDelayBeforeOnset <= requiredNumPointsBeforeOnset)
    numSampPadding = requiredNumPointsBeforeOnset - minDelayBeforeOnset + 1;
    sOut.Data.IR = zeros(size(sOut.Data.IR, 1), size(sOut.Data.IR, 2), size(sOut.Data.IR, 3) + numSampPadding);
    warning('padding IR beginning with %ld zeros to match requiredNumPointsBeforeOnsetHead criteria (current min delay before onset is %ld samp)', numSampPadding, minDelayBeforeOnset);
    for iPos = 1:size(sOut.Data.IR,1)
    for iCh = 1:size(sOut.Data.IR,2)
        sOut.Data.IR(iPos, iCh, :) = cat(3, zeros(1,1,numSampPadding), sIn.Data.IR(iPos, iCh, :));
    end
    end
end

% loop over IR to extract delay values
for iPos = 1:size(sOut.Data.IR,1)
for iCh = 1:size(sOut.Data.IR,2)
    
    % get IR delay
    ir = squeeze( sOut.Data.IR(iPos, iCh, :) );
    delaySampTmp = dpq.ir.firstOnset(ir, onsetThresh);
    
    % safety (few samples before)
    delaySamp = delaySampTmp - requiredNumPointsBeforeOnset;
    
    % align IR and add delay to struct
    if( delaySamp > 0 )
        % save delay in sofa struct
        sOut.Data.Delay(iPos, iCh) = delaySamp;
        % 'circular' shift (with zero at the end) not changing hrir length
        ir = [ ir(delaySamp:end); zeros(delaySamp-1, 1)];
        % save back ir to sofa struct
        sOut.Data.IR(iPos, iCh, :) = ir;
    % skip, usualy because requiredNumPointsBeforeOnsetHead is too big
    else
        plot(ir);
        line([delaySampTmp delaySampTmp], [min(ir), max(ir)], 'Linestyle', '--', 'Color', 'r');
        error('negative delay, requiredNumPointsBeforeOnsetHead to big or thresh too low.'); 
    end
end
end

% update SOFA dimensions
sOut = SOFAupdateDimensions(sOut);

return 


%% debug

% load sofa 
filePath = '/Users/pyrus/SharedData/HRTFs/listen_hrir_subset/raw/sofa/listen_irc_1008.sofa';
s1 = SOFAload(filePath);

% test method
s2 = dpq.sofa.extractItd(s1, 10, 3e-2);

% plot
% ir = s1.Data.IR;
ir = s2.Data.IR;
ir = squeeze([ir(:, 1, :); ir(:, 2, :)]);
ir = abs(ir);
% ir(ir > 0.01) = 1;
surf(ir);
shading interp, rotate3d on,
view([0 90]);
