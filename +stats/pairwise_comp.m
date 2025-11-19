function [pairwise_table] = pairwise_comp(mdl, conditionName, varargin)

% init parser
p = inputParser;
addParameter(p, 'p', 0, @isnumeric);
% addParameter(p, 'group', 'undefined', @ischar);
% addParameter(p, 'display', 'off', @ischar);

% parse inputs
parse(p, varargin{:});
p = p.Results;

% % find group name in stats
% dimension = find( contains(mdl.BetweenFactorNames, p.group) );
% if( isempty(dimension) ); error('cannot find group %s in stats', p.group); end

% % pairwise comparison (not functional, see factor_analysis function to understand what are mdl, p.group1)
% mm_c1 = margmean(mdl, p.group1);
% results = multcompare(mm_c1, 'ComparisonType', 'tukey-kramer');

% pairwise comparison
% stats = margmean(mdl, mdl.BetweenFactorNames);
% multcompare(mm_c1c2, 'ComparisonType', 'tukey-kramer');
pairwise_table = multcompare(mdl, conditionName, 'ComparisonType', 'tukey-kramer');

% pairwise comparison
% [results, ~, ~, gnames] = multcompare(stats, 'Dimension', dimension, 'ComparisonType', 'tukey-kramer', 'display', 'off');
% [results, ~, ~, gnames] = multcompare(stats, 'Dimension', dimension, 'CType', 'tukey-kramer', 'display', 'off');

% % share data
% pairwise_table = array2table(results,"VariableNames", ["Group","Control Group","Lower Limit","Difference","Upper Limit","P-value"]);
% pairwise_table.("Group") = gnames(pairwise_table.("Group"));
% pairwise_table.("Control Group") = gnames(pairwise_table.("Control Group"));

% filter data
if( p.p > 0 )
    selVect = pairwise_table.pValue < p.p;
    pairwise_table = pairwise_table(selVect, :);
end

% display table
display(pairwise_table);