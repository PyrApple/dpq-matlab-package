function folderList = folders(inputPath, ignoreStartWithPattern)

% list of folders in inputPath
% 
% folderList = folder(inputPath)
% 

% if second argument not defined
skipPrefixCheck = nargin < 2;

% get folder content
folderList = dir(inputPath);

% exlude files
selVect = [folderList.isdir];

% exlude . and ..
selVect = selVect & ~ismember({folderList(:).name},{'.','..'});

% apply exclude
folderList = folderList(selVect);

% ignore folder names that start with string ignoreStartWithPattern
if( ~skipPrefixCheck )
    selVect = startsWith({folderList.name}, ignoreStartWithPattern);
    % rmIdx = cellfun(@(x) strcmp(x(1),'_'), {dirList.name});
    folderList(selVect) = [];
end