% Modify Ids so they are consecutive numbers
function outTracks = normalizeIds(inTracks)

   outTracks = sortrows(inTracks,[4 3]);
   oldIds    = unique(outTracks(:,4));
   
   % Create a map of Ids
   idMap = zeros(max(oldIds),1);
   idMap(oldIds) = 1:numel(oldIds);
   
   % Map new ids to old ids
   outTracks(:,4) = idMap(outTracks(:,4));
   
end