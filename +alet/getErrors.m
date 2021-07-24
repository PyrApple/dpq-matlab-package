function [s] = getErrors(spawn, hit)

% xyzA and xyzB are Nx3 cartesian coordinates

% sanity check
if( ~isequal( size(spawn), size(hit) ) ); error('different input sizes'); end
if( size(spawn, 2) ~= 3 ); error('expected Nx3 vector'); end

% init locals
s = struct();

% coordinate convert
spawnInter = cart2interVect( spawn ); spawnSph = cart2sphVect( spawn );
hitInter = cart2interVect( hit ); hitSph = cart2sphVect( hit );

% interaural error
errorInter = spawnInter(:,1:2) - hitInter(:,1:2);
errorInter = wrapTo180(errorInter);
s.errorInter = abs( errorInter );

% signed interaural error
s.errorInterSigned = errorInter;

% signed interaural error + folding to ease overshoot / undershoot analysis
%
% define regions
front = spawn(:,1) > 0; up = spawn(:,3) > 0; left = spawn(:,2) > 0;
back = ~front; down = ~up; % right = ~left;
%
% fold lateral angle (so that >0 is overshoot for both left and right)
% errorInter(left, 1) = -errorInter(left, 1);
%
% % fold polar angle (so that >0 is overshoot wrt 0° everywhere) DISCARDED
% errorInter(front & up, 2) = -errorInter(front & up, 2);
% errorInter(back & down, 2) = -errorInter(back & down, 2);
%
% save to locals
s.errorInterSignedFolded = abs(hitInter(:,1:2)) - abs(spawnInter(:,1:2));

% spherical error
errorSph = spawnSph(:,1:2) - hitSph(:,1:2);
errorSph = wrapTo180(errorSph);
s.errorSph = abs(errorSph);

% signed spherical error
s.errorSphSigned = errorSph;

% signed spherical error + folding to ease overshoot / undershoot analysis
% errorSph(up, 2) = -errorSph(up, 2);
% s.errorSphSignedFolded = errorSph;
s.errorSphSignedFolded = abs(hitSph(:,1:2)) - abs(spawnSph(:,1:2));

% confusions
confusion = struct(); confusionStr = struct();
confusionMethods = getConfusionType();
for iMethod = 1:length(confusionMethods)
    method = confusionMethods{iMethod};
    [typeId, typeStr] = getConfusionType( spawn, hit,method );
    confusion.(method) = typeId;
    confusionStr.(method) = typeStr;
end
s.confusion = confusion;
s.confusionStr = confusionStr;
% [s.confusionType, s.confusionTypeStr] = getConfusionType( spawn, hit, 'interaural' );

% great circle error
s.greatCircAngle = getGreatCircleAngle( spawn, hit );

% folded (based on confusions) hit error
hitFolded = hit;
confusionStr = s.confusionStr.(confusionMethods{1}); % based on first method, arbitrary for now
%
% up-down confusions: z symmetry
selVect = contains( confusionStr, 'up-down' );
hitFolded( selVect, 3 ) = - hitFolded( selVect, 3 );
%
% front-back confusions: x symmetry
selVect = contains( confusionStr, 'front-back' );
hitFolded( selVect, 1 ) = - hitFolded( selVect, 1 );
%
% compute folded interaural error 
hitFoldedInter = cart2interVect( hitFolded );
spawnInter = cart2interVect( spawn );
tmp = spawnInter(:,1:2) - hitFoldedInter(:,1:2);
s.errorInterFolded = abs( wrapTo180(tmp ) );

% compute sphere regions for spawned source
region = struct(); regionStr = struct();
regionMethods = getSphereRegions();
for iMethod = 1:length(regionMethods)
    method = regionMethods{iMethod};
    [typeId, typeStr] = getSphereRegions( spawn, method );
    region.(method) = typeId;
    regionStr.(method) = typeStr;
end
s.region = region;
s.regionStr = regionStr;


