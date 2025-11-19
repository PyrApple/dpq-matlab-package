function [bufferBin] = ambi2bin(bufferAmbi, fs, varargin)

% ambi2bin(bufferAmbi, fs, 'format', 'ambix', 'hrtf', 'kemar');

% parse inputs
p = inputParser;
addRequired(p, 'bufferAmbi', @ismatrix);
addRequired(p, 'fs', @isscalar);
expectedFormats = {'ambix', 'catt'};
addOptional(p, 'format', 'ambix', @(x) any(validatestring(x,expectedFormats)));
addOptional(p, 'hrtf', 'kemar', @ischar);
parse(p, bufferAmbi, fs, varargin{:});
params = p.Results;

% init locals
nCh = size(bufferAmbi, 2);
nSpeaker = nCh + 4; warning('need to fix arbitrary num speakers here');
ambiOrder = sqrt( nCh ) - 1;

% define speaker grid
[ xyz_S ] = eac.geometry.GenerateGrid( sprintf('nearlyuniform-%d', nSpeaker) );
[ ~, xyzList] = eac.geometry.ConvertCoordinates( xyz_S, 'xyz' );

% % plot speaker grid
% xyz = points_S.content_m;
% plot3(xyz(:,1), xyz(:,2), xyz(:,3), 'o');
% grid on, grid minor, axis equal, rotate3d on,

% transpose (from matlab audio matrix to spat)
bufferAmbi = bufferAmbi.';

% ambisonic convert
switch params.format
    case 'catt'
        % bufferAmbi = hoaCatt2Ambix(bufferAmbiIn.');
        % bufferAmbi = bufferAmbi.';
        bufferAmbi = eac.hoa.HoaSorting( bufferAmbi, '/dimension', 3, '/order', ambiOrder, '/sorting/input', 'FMH', '/sorting/output', 'ACN' );
        bufferAmbi = eac.hoa.HoaConverter( bufferAmbi, '/dimension', 3, '/order', ambiOrder, '/norm/input', 'FuMa', '/norm/output', 'SN3D' );
end

% ambisonic rotate (to compensate for spat convention where user faces y)
% see spat5.tuto-hoa-2.maxpat and https://discussion.forum.ircam.fr/t/spat5-acn-order-incorrect/21772/4
bufferAmbi = eac.hoa.HoaRotate( bufferAmbi, '/dimension', 3, '/order', ambiOrder, '/yaw', 90, '/pitch', 0 );

% ambisonic decode
bufferSPeakers = eac.hoa.HoaDecoder( bufferAmbi, '/norm', 'SN3D', '/order', ambiOrder, '/dimension', 3, '/method', 'energy-preserving', '/type', 'basic', '/crossover', 700, '/speaker/number', nSpeaker, '/speakers/xyz', xyzList);

% virtual speaker
bufferBin = eac.spat.VirtualSpeakers( bufferSPeakers, '/dsp/samplerate', fs, '/speaker/number', nSpeaker, '/speakers/xyz', xyzList, '/hrtf', params.hrtf );

% un-transpose
bufferBin = bufferBin.';

return 


%% debug

% fs = 44100;
% hrtfFile = '/Users/pyrus/SharedData/HRTFs/KU100_ClubFritz/ClubFritz1.sofa';
% [bufferBin] = ambi2bin(zeros(100, 1), fs, 'hrtf', hrtfFile, 'format', 'catt');












