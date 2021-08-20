% Javier Mazzaferri 2014
% Hopital Maisonneuve-Rosemont, Centre de Recherche
% http://www.biophotonics.ca

function [outTracks] = uTracks2Matrix(tracksFinal)

% Converts tracks (tracksFinal) in the format of Danuser to the simpler 
% and compact format of time-points in four columns [x y t trackID]. 
% tracksFinal should be obtained without merge and split.
%
% INPUT:
%       tracksFinal   : Structure array where each element corresponds to a 
%                       compound track. Each element contains the following 
%                       fields:
%           .tracksFeatIndxCG: Connectivity matrix of features between
%                              frames, after gap closing. Number of rows
%                              = number of track segments in compound
%                              track. Number of columns = number of frames
%                              the compound track spans. Zeros indicate
%                              frames where track segments do not exist
%                              (either because those frames are before the
%                              segment starts or after it ends, or because
%                              of losing parts of a segment.
%           .tracksCoordAmpCG: The positions and amplitudes of the tracked
%                              features, after gap closing. Number of rows
%                              = number of track segments in compound
%                              track. Number of columns = 8 * number of
%                              frames the compound track spans. Each row
%                              consists of
%                              [x1 y1 z1 a1 dx1 dy1 dz1 da1 x2 y2 z2 a2 dx2 dy2 dz2 da2 ...]
%                              NaN indicates frames where track segments do
%                              not exist, like the zeros above.
%           .seqOfEvents     : Matrix with number of rows equal to number
%                              of events happening in a compound track and 4
%                              columns:
%                              1st: Frame where event happens;
%                              2nd: 1 = start of track segment, 2 = end of track segment;
%                              3rd: Index of track segment that ends or starts;
%                              4th: NaN = start is a birth and end is a death,
%                              number = start is due to a split, end
%                              is due to a merge, number is the index
%                              of track segment for the merge/split.

outTracks = [];

%get number of tracks
nTracks = length(tracksFinal);

for k = 1 : nTracks
    
    % Get Start and end times of the track
    startTime = tracksFinal(k).seqOfEvents(1,1);
    endTime   = tracksFinal(k).seqOfEvents(end,1);
    
    % Get the coordinates of all time-points in the track
    coords = tracksFinal(k).tracksCoordAmpCG(1,:);
    xs     = coords(1:8:end);
    ys     = coords(2:8:end);
    ts     = startTime:endTime;
    
    % Remove desapearing time-points
    validMask = ~isnan(xs) & ~isnan(ys);
    ts = ts(validMask)';
    xs = xs(validMask)';
    ys = ys(validMask)';
    
    Ids = ones(size(ts)) * k;
    
    outTracks = [outTracks;[xs,ys,ts,Ids]];    
    
end


end