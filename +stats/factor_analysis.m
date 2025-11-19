function [mdl] = factor_analysis(s2, dataName, conditionNames, subjectFieldName, varargin)

% init parser
p = inputParser;
addParameter(p, 'selvect', '', @isvector);
addParameter(p, 'display', 'off', @ischar);

% parse inputs
parse(p, varargin{:});
p = p.Results;

% shape data
[tbl, dataVect, conditionsCell] = dpq.stats.extract_data(s2, dataName, conditionNames, varargin{:});

% create fit string argument based on table inputs
fitlmStr = [dataName ' ~ ' conditionNames{1}];
if( length(conditionNames) > 1 )
    for iGroup = 2:length(conditionNames)
        fitlmStr = [fitlmStr ' * ' conditionNames{iGroup}];
    end
end
fitlmStr = [fitlmStr ' + (1|' subjectFieldName ')'];

% use linear model 
mdl = fitlme(tbl, fitlmStr);

% @todo: replace with (for more than single subject)
% lme = fitlme(t, 'attrVect ~ Expertise * Acoustics + (1|Subject)');
% Optionally add random slopes (each subject's slope can vary):
% lme = fitlme(t, 'attrVect ~ Expertise * Acoustics + (Expertise|Subject)');

% extract table
anova_table = anova(mdl);

% display table
display(anova_table);

% boxplot
if( strcmp(p.display, 'on') )

    % plot
    h = boxplot(dataVect, conditionsCell, 'notch', 'on', 'FactorGap', 5);

    % format plot
    set(h,'LineWidth', 1.2);
    ylabel(dataName);
    grid on, grid minor, ax = gca; ax.GridAlpha = 0.5;
    % xtickangle(30);

end

end
