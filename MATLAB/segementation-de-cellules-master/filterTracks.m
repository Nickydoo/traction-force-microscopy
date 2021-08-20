% Get Subset of tracks at least 20 frames long
function outTracks = filterTracks(inTracks)

minTrackLength = 20;

outTracks = [];
if isempty(inTracks), return, end

% Get track IDs and their number of frames
[id,idCnt,~] = countEntries(inTracks(:,4),0, 0);

% Select IDs
goodIDs = id(idCnt >= minTrackLength);

% Get tracks with selected IDs
outTracks  = inTracks(ismember(inTracks(:,4),goodIDs),:);

end