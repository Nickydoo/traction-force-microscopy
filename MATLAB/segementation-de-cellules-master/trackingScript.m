clear

rawDir         = '/Users/santiago/Dropbox/projects/Joannie/Cancer/Images/Movie1/Results/'; % Directory with raw images to generate the tracking movie
resultsDir     = '/Users/santiago/Dropbox/projects/Joannie/Cancer/Images/Movie1/Track/'; % results directory to put the tracking movie
numberOfFrames = Inf; % Number of frame to generate the tracking movie 

trackPar.toMaxDisplacement = 30; % Maximum value of maxDisp
avgSz                      = 50;

load([rawDir 'timeData.mat']);

fnIms  = dir([rawDir '*.jpg']);
[rw,cl] = size(imread(fullfile(rawDir,fnIms(1).name)));

%% Tracking 

movieInfo   = convertDetectionToDanuser(cellCentroids); % converts vesPos in a readable file for tracking
tracksFinal = scriptTrackGeneralSpatialAverageNeutrophils(movieInfo, [rw,cl], trackPar.toMaxDisplacement, avgSz);
tracksuT    = uTracks2Matrix(tracksFinal); % converts tracksFinal in a convinient format
    
makeTracksMovie(rawDir,tracksuT,resultsDir,numberOfFrames,1,[]);




