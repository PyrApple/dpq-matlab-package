function [s] = listen2sofa(l_hrir_S, r_hrir_S, subjectId)

% Convert LISTEN format HRTFs to SOFA format
% 
% s = listen2sofa(l_hrir_S, r_hrir_S, subjectID)
% 
% s is sofa struct, *_hrir_S are directly loaded from listen .mat file,
% subjectId is the number of the listen hrtf

% get an empty conventions structure
s = SOFAgetConventions('SimpleFreeFieldHRIR');

% fill Data field in with data
s.Data.IR = zeros(size(l_hrir_S.content_m,1),2,size(l_hrir_S.content_m,2));
s.Data.IR(:,1,:) = l_hrir_S.content_m;
s.Data.IR(:,2,:) = r_hrir_S.content_m;
s.Data.SamplingRate = l_hrir_S.sampling_hz;

% save attributes
s.GLOBAL_ListenerShortName = subjectId;
s.GLOBAL_History = 'Converted from the LISTEN format';
s.GLOBAL_DataType = l_hrir_S.type_s;

% ensure pos are column vectors
if( isrow(l_hrir_S.azim_v) )
    l_hrir_S.azim_v = l_hrir_S.azim_v.';
    l_hrir_S.elev_v= l_hrir_S.elev_v.';
end

% fill mandatory fields
s.ListenerPosition = [0 0 0];
s.ListenerView = [1 0 0];
s.ListenerUp = [0 0 1];
LISTEN_RADIUS = 1.95; % in m
s.SourcePosition = [l_hrir_S.azim_v, l_hrir_S.elev_v, LISTEN_RADIUS*ones(size(l_hrir_S.elev_v,1),1)];

% Update dimensions
s = SOFAupdateDimensions(s);

return


%% debug

% init locals
filePath = '/Users/pyrus/SharedData/HRTFs/listen_hrir_subset/raw/mat/listen_irc_1008.mat';
load(filePath);
subjectID = 1;

% listen to sofa
s = dpq.sofa.listen2sofa(l_hrir_S, r_hrir_S, subjectID);

% plot
posId = 1; chId = 1;
ir = squeeze(s.Data.IR(posId, chId, :));
t = (0:(length(ir)-1))/fs;
plot(t, ir);







