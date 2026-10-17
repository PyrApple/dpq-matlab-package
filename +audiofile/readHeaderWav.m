function h = readHeaderWav(filePath)

% useful? links:
% - https://tech.ebu.ch/docs/tech/tech3285.pdf
% - https://sourceforge.net/p/bwfmetaedit/code/HEAD/tree/BWF_MetaEdit/trunk/Source/Riff/Riff_Chunks_WAVE_bext.cpp

% init locals
h = audioinfo(filePath);

% open file
fid = fopen(filePath);

% read data
chunkId = fread(fid, 4, 'uint8=>char')';

% discard if container format is not "RIFF"
if( ~strcmp(chunkId, 'RIFF') ); return; end

% read data
chunkSize = fread(fid, 1, 'uint32');
h.format = fread(fid, 4, 'uint8=>char')';

% discard if format is not WAVE
if( ~strcmp(h.format, 'WAVE') ); return; end

% read data
subchunkId = fread(fid, 4, 'uint8=>char')';

% discard if subchunk is not BWF
if( ~strcmp(subchunkId, 'bext') ); return; end

% read data
subChunkSize = fread(fid, 1, 'uint32');
h.bext_description = fread(fid, 256, 'uint8=>char')';
h.bext_originator = fread(fid, 32, 'uint8=>char')';
h.bext_originatorRef = fread(fid, 32, 'uint8=>char')';
h.bext_originationDate = fread(fid, 10, 'uint8=>char')';
h.bext_originationTime = fread(fid, 8, 'uint8=>char')';
h.bext_timeReference = fread(fid, 1, 'uint32');
h.bext_timeReferenceHigh = fread(fid, 1, 'uint32');
h.bext_version = fread(fid, 1, 'uint16')';

% BWF v1
if( h.bext_version == 1 )

    h.bext_umid = fread(fid, 1, 'uint8')';

% BWF v2
elseif ( h.bext_version == 2 )
        h.bext_loudnessValue = fread(fid, 1, 'uint16')';
        h.bext_loudnessRange = fread(fid, 1, 'uint16')';
        h.bext_maxTruePeakLevel = fread(fid, 1, 'uint16')';
        h.bext_maxMomentaryLoudness = fread(fid, 1, 'uint16')';
        h.bext_maxShortTermLoudness = fread(fid, 1, 'uint16')';

% version not supported
else
    warning ('unsupported BWF version %d', h.bext_version)
end

% close file
fclose(fid);

return 


%% test

% define path
filePath = '/Users/pyrus/Workspace/Matlab/zoom_timecode_access/inputs/01/240923-T001.WAV';

% read header (vanilla matlab)
headerMatlab = audioinfo(filePath)

% read header (ref eac lib)
headerEac = eac.audiofiles.ReadAudioFileHeader(filePath)

% read header (pers)
headerPers = dpq.audiofile.readHeaderWav(filePath)

% log time code
offsetInSamples = headerPers.bext_timeReference;
offsetInSec = offsetInSamples / headerPers.SampleRate;
fprintf('timecode: %.1f sec \n', offsetInSec);




