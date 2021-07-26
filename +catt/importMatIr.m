function [ir, fs] = importMatIr(filePath)

% load CATT .MAT RIR file.
%  
% [ir, fs] = importMatIr(filePath)
% 
% ir is a matrix of irs, fs is the sampling frequency.

% extract file name
[~, fileName, ~] = fileparts(filePath);

% get rcv / src ids
fileNameSplit = strsplit(fileName, '_');
rcvIdStr = fileNameSplit{end-1};
srcIdStr = fileNameSplit{end-2};
% fprintf('%s: src %s rcv %s \n', fileName, srcIdStr, rcvIdStr);

% load file
s = load(filePath);

% save locals
fs = s.TUCT_fs;

% indiv variables to single ir
cattFmtStr = 'h_%s_%s_BF_%s';
ir = [];

% same channel ordering as that of wav file exported from CATT
ambiChStr = {'W','X','Y','Z','R','S','T','U','V','K','L','M','N','O','P','Q'};

for iCh = 1:length(ambiChStr)

    % get variable name
    fieldName = sprintf(cattFmtStr, srcIdStr, rcvIdStr, ambiChStr{iCh});

    % discard if doesn't exist (order < 3)
    if( ~isfield(s, fieldName) )
        ir = ir(:, 1:(iCh-1));
        break
    end

    % get variable from name
    irTmp = s.(fieldName);

    % first time init
    if( isempty( ir ) )
        ir = zeros(length(irTmp), length(ambiChStr));
    end

    % save to locals
    ir(:, iCh) = irTmp;

end
    
end
