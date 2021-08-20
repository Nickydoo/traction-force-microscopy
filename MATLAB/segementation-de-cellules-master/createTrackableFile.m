function createTrackableFile(varargin)

if nargin>0
    myFolder = fullfile(varargin{1},['Results' num2str(varargin{2})]);
else
    myFolder ='/Users/santiago/Dropbox/projects/Joannie/Cancer/Images/Movie1/Results/';
end

myFiles = dir(fullfile(myFolder,'data*.mat'));

%% Read and analyze
%thisPool=parpool(10);

cellCentroids  = [];
cellAreas      = [];
% cellPixelLists = [];

for it= 1:numel(myFiles)
    
    load(fullfile(myFolder, myFiles(it).name));
    cellCentroids = [cellCentroids; cellStats.WeightedCentroid it*ones(size(cellStats, 1), 1)];
    cellAreas     = [cellAreas;     cellStats.Area     it*ones(size(cellStats, 1), 1)];
    
end

save(fullfile(myFolder,'dataOverTime.mat'), 'cellCentroids', 'cellAreas');