% Get Subset of tracks at least 20 frames long

function outTracks = filterTracksJR(inTracks, minTrackLength,maxDmax,start,jump,smoothFactor)

%minTrackLength = 20;

outTracks = [];
if isempty(inTracks), return, end

% take few frames
pos = logical(sum(inTracks(:,3) == start:jump:length(inTracks(:,3)),2));
inTracks = inTracks(pos,:);

%smooth the track and filter dmax
for ii = unique(inTracks(:,4)')
    idx = inTracks(:,1) == ii;
    x = smooth(inTracks(idx,1));
    y = smooth(inTracks(idx,2));
    dmax = sqrt( max(max( (x-x').^2+(y-y').^2) ) );
    
    if dmax < maxDmax
        inTracks(idx,1) = x;
        inTracks(idx,2) = y;
    else
        inTracks(idx,:) = [];
    end
end



% Get track IDs and their number of frames
[id,idCnt,~] = countEntries(inTracks(:,4),0, 0);

% Select IDs
goodIDs = id( idCnt >= minTrackLength );

% Get tracks with selected IDs
outTracks  = inTracks(ismember(inTracks(:,4),goodIDs),:);

% smooth tracks
% for idx = goodIDs'
%     posi = outTracks(:,4)==idx;
%     outTracks(posi,1)  = smooth(outTracks(posi,1),smoothFactor);
%     outTracks(posi,2)  = smooth(outTracks(posi,2),smoothFactor);
% end

end