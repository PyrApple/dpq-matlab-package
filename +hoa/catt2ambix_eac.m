function [bufferAmbiOut] = hoaCatt2Ambix_eac(bufferAmbiIn)

% init locals
nCh = size(bufferAmbiIn, 2);
ambiOrder = sqrt( nCh ) - 1;

% transpose (from matlab audio matrix to spat)
bufferAmbiOut = bufferAmbiIn.';

% ambisonic convert
bufferAmbiOut = eac.hoa.HoaSorting( bufferAmbiOut, '/dimension', 3, '/order', ambiOrder, '/sorting/input', 'FMH', '/sorting/output', 'ACN' );
bufferAmbiOut = eac.hoa.HoaConverter( bufferAmbiOut, '/dimension', 3, '/order', ambiOrder, '/norm/input', 'FuMa', '/norm/output', 'SN3D' );

% un-transpose
bufferAmbiOut = bufferAmbiOut.';
