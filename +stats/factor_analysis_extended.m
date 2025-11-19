function [] = factor_analysis_extended(s2, varargin)

%% shape data

% init parser
p = inputParser;
addParameter(p, 'value', '', @ischar);
addParameter(p, 'groups', '', @iscellstr);
addParameter(p, 'selvect', '', @isvector);

% parse inputs
parse(p, varargin{:});
p = p.Results;

% create table
t = table;
t.(p.value) = s2.(p.value);
fitlmStr = [p.value ' ~'];
for iGroup = 1:length(p.groups)
    gname = (p.groups{iGroup});
    t.(gname) = s2.(gname);
    if( iGroup == 1 )
        fitlmStr = [p.value ' ~ ' gname];
    else
        fitlmStr = [fitlmStr ' * ' gname];
    end
    
end

% filter data
if( ~isempty(p.selvect) )
    t = t(p.selvect, :);
end

% shape data (form group cell from table columns)
g = {}; 
for iCol = 1:size(t, 2) - 1
    g{iCol} = t{:, 1+iCol};
end


%% anovan

% anovan: init locals
modelStr = 'linear';
if( length(g) > 1 ); modelStr = 'interaction'; end
varNames = t.Properties.VariableNames(2:end).';

% anovan: run (even if table not used, results used for pairwise comparison)
[~, anovan_table, stats] = anovan(t{:, 1}, g, 'model', modelStr, 'display', 'off', 'varnames', varNames);
% [results, ~, ~, gnames] = multcompare(stats, 'Dimension', dimension, 'CType', 'tukey-kramer', 'display', 'on');

% shape / clean data
anovan_table = clean_anovan_table(anovan_table);
display(anovan_table);


%% fit linear model 

% use linear model 
mdl = fitlm(t, fitlmStr);
fitlm_table = anova(mdl);
display(fitlm_table);


%% fit repeated measure model 

% Prepare data for repeated measures ANOVA
mdl = fitrm(t, fitlmStr);
fitrm_table = anova(mdl);
display(fitrm_table);


end


%% local functions

% format anovan table so it's clean and looks like the one returned by anova(mdl)
function anova_table = clean_anovan_table (tbl)

    % % Run ANOVAN
    % [p, tbl, stats, terms] = anovan(y, group, varargin{:});
    
    % Extract header and data
    header = tbl(1,:);
    data = tbl(2:end-1,:);   % Exclude header and 'Total' row
    
    % Convert numeric cells to doubles
    data_clean = cell(size(data));
    for j = 1:size(data,2)
        col = data(:,j);
        if all(cellfun(@(x) isnumeric(x) || isempty(x), col))
            data_clean(:,j) = cellfun(@(x) double(x), col, 'UniformOutput', false);
        else
            data_clean(:,j) = col;
        end
    end
    
    % Convert to table
    anova_table = cell2table(data_clean, 'VariableNames', header);
end