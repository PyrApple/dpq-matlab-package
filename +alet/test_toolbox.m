%% init

% addpath (folder and subfolders)
addpath(genpath(fullfile(pwd, 'externals')));

% load data
filePath = fullfile(pwd, 'test_data.mat');
load(filePath);
s = test_data;

% compute errors
sTmp = getErrors(s.spawn, s.hit);
fieldNames = fieldnames( sTmp );
for iField = 1:length( fieldNames )
    s.(fieldNames{iField}) = sTmp.(fieldNames{iField});
end


%% exemple plot

% compute stats
[tmp_mean, tmp_meanci, tmp_gname] = grpstats(s.greatCircAngle, {s.session}, {'mean', 'meanci', 'gname'});
session = cellfun(@(x) str2num(x), tmp_gname);

% plot
errorbar(session, tmp_mean, tmp_mean-tmp_meanci(:, 1), tmp_meanci(:, 2) - tmp_mean, 'o-', 'Color', 'k', 'MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 1.0);

% format
grid on, grid minor, 
o = 1; xlim([min(session)-o, max(session)+o]);
xlabel('session id'); ylabel('gc error (deg)');


%% compute space occupation 

spawn = unique(s.spawn, 'rows');
spawnSph = cart2sphVect(spawn);
[cellAngles, cellShapeIndices] = getSphereVoronoiAngles(spawnSph);
fprintf('sc_angle %.1f +/- %.1f \n', mean(cellAngles), std(cellAngles));
fprintf('sc_index %.2f +/- %.2f \n', mean(cellShapeIndices), std(cellShapeIndices));




