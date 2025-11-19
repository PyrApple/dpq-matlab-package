function [bufferAmbiOut] = hoaCatt2Ambix(bufferAmbiIn)

% channel ordering
bufferAmbiOut = convert_N3D_FuMa(bufferAmbiIn, 'fuma2n');

% normalisation
bufferAmbiOut = convert_N3D_SN3D(bufferAmbiOut, 'n2sn');

end