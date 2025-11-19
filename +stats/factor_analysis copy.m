function [anova_table, stats] = factor_analysis(s2, varargin)

% t = factor_analysis(s2, 'value', 'greatCircDistance', 'groups', {'condition', 'hrtfStrCat'}, 'hrtfStrCat', 'selvect', selVect, 'display', 'off', 'displaynorm', 'off', 'model', 'fitlm')

% @todo: 
% - add statistical significance check
% - show interaction plot when there is interaction? 
% - consider replacing lillietest with swtest

% init parser
p = inputParser;
addParameter(p, 'value', '', @ischar);
addParameter(p, 'groups', '', @iscellstr);
addParameter(p, 'selvect', '', @isvector);
addParameter(p, 'display', 'off', @ischar);
addParameter(p, 'model', 'fitlm', @ischar);
addParameter(p, 'displaynorm', 'off', @ischar);

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


% anovan: init locals
modelStr = 'linear';
if( length(g) > 1 ); modelStr = 'interaction'; end
varNames = t.Properties.VariableNames(2:end).';

% anovan: run (even if table not used, results used for pairwise comparison)
[~, anova_table, stats] = anovan(t{:, 1}, g, 'model', modelStr, 'display', 'off', 'varnames', varNames);
% [results, ~, ~, gnames] = multcompare(stats, 'Dimension', dimension, 'CType', 'tukey-kramer', 'display', 'on');

% % show interactions
% If lines cross or diverge, that's your interaction — confirming that factor2's effect depends on factor1
% interactionplot(s2.greatCircDistance, {s2.condition, sTmp.regionStr});

% use linear model 
mdl = fitlm(t, fitlmStr);

% which model table to return?
if( strcmp( p.model, 'fitlm') )
    
    % extract table
    anova_table = anova(mdl);

elseif( strcmp( p.model, 'anovan') )
    
    % shape / clean data
    anova_table = clean_anovan_table(anova_table);

end

% plot (boxplot)
if( strcmp(p.display, 'on') )

    % plot
    h = boxplot(t{:, 1}, g, 'notch', 'on', 'FactorGap', 5);

    % format plot
    set(h,'LineWidth', 1.2);
    ylabel(p.value);
    grid on, grid minor, ax = gca; ax.GridAlpha = 0.5;
    % xtickangle(30);

end

% normality test
residuals = mdl.Residuals.Raw;
% [h,p1] = swtest(residuals); % from matlab file exchange
[h, p1] = lillietest(residuals);
if( h == 1 ); warning('normality test rejected'); end

if( strcmp(p.displaynorm, 'on') )
    subplot(1,2,1);
    histogram(residuals);
    title('Residuals Histogram');
    
    subplot(1,2,2);
    qqplot(residuals);
    title('QQ Plot of Residuals');
end

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