function [tableOut, dataVect, conditionsCell] = extract_data(s2, dataName, conditionNames, varargin)

% init parser
p = inputParser;
addParameter(p, 'selvect', '', @isvector);
addParameter(p, 'display', '', @ischar); % not used, makes other function calls easier

% parse inputs
parse(p, varargin{:});
p = p.Results;

% create table
tableOut = table;
tableOut.(dataName) = s2.(dataName);
for iGroup = 1:length(conditionNames)
    tableOut.(conditionNames{iGroup}) = s2.(conditionNames{iGroup});
end

% filter data
if( ~isempty(p.selvect) )
    tableOut = tableOut(p.selvect, :);
end

% shape data (from table columns to group cell)
dataVect = tableOut{:, 1};
conditionsCell = {}; 
for iCol = 1:size(tableOut, 2) - 1
    conditionsCell{iCol} = tableOut{:, 1+iCol};
end


end
