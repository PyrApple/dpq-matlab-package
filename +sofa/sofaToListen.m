function [l_hrir_S, r_hrir_S] = sofaToListen(s)

% Converts Sofa struct to listen struct
% 
% [l_hrir_S, r_hrir_S] = sofaToListen(Obj)


% load data
l_hrir_S.type_s = s.GLOBAL_DataType;
l_hrir_S.elev_v = s.SourcePosition(:, 2);
l_hrir_S.azim_v = s.SourcePosition(:, 1);
l_hrir_S.sampling_hz = s.Data.SamplingRate;
l_hrir_S.content_m = squeeze(s.Data.IR(:, 1, :));

r_hrir_S.type_s = s.GLOBAL_DataType;
r_hrir_S.elev_v = s.SourcePosition(:, 2);
r_hrir_S.azim_v = s.SourcePosition(:, 1);
r_hrir_S.sampling_hz = s.Data.SamplingRate;
r_hrir_S.content_m = squeeze(s.Data.IR(:, 2, :));

return 


%% debug

% load sofa 
filePath = '/Users/pyrus/SharedData/HRTFs/listen_hrir_subset/raw/sofa/listen_irc_1008.sofa';
s = SOFAload(filePath);

[l_hrir_S, r_hrir_S] = dpq.sofa.sofaToListen(s)