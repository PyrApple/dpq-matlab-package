function [Obj] = listen2sofa(l_hrir_S, r_hrir_S, subjectID)
% converts LISTEN format HRTFs to the SOFA format

%% Get an empty conventions structure
Obj = SOFAgetConventions('SimpleFreeFieldHRIR');

%% Fill Data in with data
Obj.Data.IR = zeros(size(l_hrir_S.content_m,1),2,size(l_hrir_S.content_m,2));
Obj.Data.IR(:,1,:)=l_hrir_S.content_m;
Obj.Data.IR(:,2,:)=r_hrir_S.content_m;
Obj.Data.SamplingRate =l_hrir_S.sampling_hz;

%% Fill with attributes
Obj.GLOBAL_ListenerShortName = subjectID;
Obj.GLOBAL_History='Converted from the LISTEN format';

%% Fill the mandatory variables
Obj.ListenerPosition = [0 0 0];
Obj.ListenerView = [1 0 0];
Obj.ListenerUp = [0 0 1];
Obj.SourcePosition = [l_hrir_S.azim_v, l_hrir_S.elev_v, 1.95*ones(size(l_hrir_S.elev_v,1),1)];

%% Update dimensions
Obj=SOFAupdateDimensions(Obj);