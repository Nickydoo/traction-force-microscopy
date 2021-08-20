function tracksuT=trackCells(varargin)

if nargin>0
    rawDir=[varargin{1} 'Results' num2str(varargin{2}) '/'];
    resultsDir=[varargin{1} 'Track' num2str(varargin{2}) '/'];
else
    rawDir         = '/Users/santiago/Dropbox/projects/Joannie/Cancer/Images/Movie1/Results/'; % Directory with raw images to generate the tracking movie
    resultsDir     = '/Users/santiago/Dropbox/projects/Joannie/Cancer/Images/Movie1/Track/'; % results directory to put the tracking movie
end

if (~exist(resultsDir,'dir')), mkdir(resultsDir); end

numberOfFrames = Inf; % Number of frame to generate the tracking movie 

trackPar.toMaxDisplacement = 30; % Maximum value of maxDisp
avgSz                      = 50;

load([rawDir 'dataOverTime.mat']);

fnIms  = dir([rawDir '*.jpg']);
[rw,cl] = size(imread(fullfile(rawDir,fnIms(1).name)));

%% Tracking 

movieInfo   = convertDetectionToDanuser(cellCentroids); % converts vesPos in a readable file for tracking
tracksFinal = scriptTrackGeneralSpatialAverageNeutrophils(movieInfo, [rw,cl], trackPar.toMaxDisplacement, avgSz);
tracksuT    = uTracks2Matrix(tracksFinal); % converts tracksFinal in a convinient format

save([rawDir 'trackResult.mat'], 'movieInfo', 'tracksFinal', 'tracksuT');





