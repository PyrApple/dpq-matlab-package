function sOut = interpolate(sIn, gridStep)

% Spatial interpolation of sofa IRs based on spherical harmonics.
%
% sOut = interpolate(sIn, gridStep)
%
% gridStep is the space between interpolation grid points, in degrees


% init arguments
if( nargin < 2 ); gridStep = 5; end

% sanitify check: input sofa is time aligned (itd moved to Delay sofa field)
if( size(sIn.Data.Delay,1) ~= size(sIn.Data.IR, 1) )
    error('Input sofa HRIR should be time aligned before interpolation');
end

% sanity check: source position defined in spherical coordinates
if( ~strcmp(sIn.SourcePosition_Type, 'spherical') )
    error('Input sofa source position should be defined as spherical coordinates');
end

% sanity check: algorithm not defined for varying measured distances
if( ~(length(unique(sIn.SourcePosition(:,3))) == 1 ) )
    error('Input sofa source position distance should be unique');
end

% itd interpolation
itd_v = sIn.Data.Delay(:,1) - sIn.Data.Delay(:,2);
azim_v = sIn.SourcePosition(:,1);
elev_v = sIn.SourcePosition(:,2);
[itdInterp_v, azimInterp_v, elevInterp_v] = interpHarm(itd_v, azim_v, elev_v, gridStep);

% hrir interpolation
hrirLeft_m = squeeze( sIn.Data.IR(:,1,:) );
hrirRight_m = squeeze( sIn.Data.IR(:,2,:) );
[hrirLeftInterp_m, azimInterp_v, elevInterp_v] = interpHarm(hrirLeft_m, azim_v, elev_v, gridStep);
[hrirRightInterp_m, azimInterp_v, elevInterp_v] = interpHarm(hrirRight_m, azim_v, elev_v, gridStep);

% fill in output struct
sOut = sIn;
distInterp_v = repmat(sOut.SourcePosition(1,3), length(azimInterp_v), 1);
sOut.SourcePosition = [azimInterp_v elevInterp_v distInterp_v];
sOut.Data.Delay = [max(itdInterp_v, 0), max(-itdInterp_v, 0)]; % check you had it right
sOut.Data.IR = permute(cat(3, hrirLeftInterp_m, hrirRightInterp_m), [1 3 2]);

% sOut.Data.IR = zeros(size(hrirRightInterp_m, 1), 2, size(hrirRightInterp_m, 2))
% sOut.Data.IR(:,1,:) = 

% crop tail (added during interpolation) 
sOut = dpq.sofa.crop(sOut);

% update sofa dimensions
sOut = SOFAupdateDimensions(sOut);

return 


%% debug

% load sofa 
filePath = '/Users/pyrus/SharedData/HRTFs/listen_hrir_subset/raw/sofa/listen_irc_1008.sofa';
sIn = SOFAload(filePath);

% interpolate
sOut = dpq.sofa.extractItd(sIn, 10, 5e-2);
sOut = dpq.sofa.interpolate(sOut, 20);

% debug: preprocessing that should have been done on sofa struct before
% call to sofaInterpSphHarm
% sIn = sofaExtractItd(sIn, 0, 50e-3);