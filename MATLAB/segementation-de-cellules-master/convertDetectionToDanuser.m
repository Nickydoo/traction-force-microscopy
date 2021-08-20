%JM 2013
%http://www.biophotonics.ca

function movieInfo = convertDetectionToDanuser(inPos)
% Converts the positions in inPos to the format needed by function
% trackCloseGapsKalmanSparse.m, from u-track
%
%OUTPUT FORMAT
% movieInfo    : Array of size equal to the number of frames in a
%                      movie, containing at least the fields:
%             .xCoord      : x-coordinates of detected features. 
%                            1st column: value, 2nd column: standard
%                            deviation (zeros if not available).
%             .yCoord      : y-coordinates of detected features.
%                            1st column: value, 2nd column: standard
%                            deviation (zeros if not available).
%             .zCoord      : z-coordinates of detected features.
%                            1st column: value, 2nd column: standard
%                            deviation (zeros if not available).
%                            Optional. Skipped if problem is 2D. Default: zeros.
%             .amp         : "Intensities" of detected features.
%                            1st column: values (ones if not available),
%                            2nd column: standard deviation (zeros if not
%                            available).

ts = unique(inPos(:,3));
N = numel(ts); %Number of frames

% prealocate memory
movieInfo = repmat(struct('xCoord',[],'yCoord',[],'amp',[]),1,N);

for k=1:N
    
    kPos = inPos(inPos(:,3) == ts(k),[1,2]);
    aux = ones(size(kPos,1),1);
    
    movieInfo(k).xCoord = [kPos(:,1), 0 * aux];
    movieInfo(k).yCoord = [kPos(:,2), 0 * aux];
    movieInfo(k).amp    = [aux      , 0 * aux];
    
end

end

%~~~ this is the end ~~~ my only friend, the end.