function createPolygonMask(varargin)

if nargin>1
    myFolder=varargin{1};
    positionInSample=varargin{2};
elseif nargin == 0
    myFolder='/Users/santiago/Dropbox/projects/Joannie/Cancer/Images/Movie5/';
    positionInSample=3;
else
    error('Do not admit only one parameter.')
end


resultsFolder = fullfile(myFolder, ['Results' num2str(positionInSample)]);

if exist(fullfile(resultsFolder,'roiMask.mat'),'file'), return, end

if ~exist(resultsFolder,'dir'), mkdir(resultsFolder); end

myFiles = dir(fullfile(myFolder,'rawData', ['N' num2str(positionInSample,'%03.0f') '*.*']));

myImage = imread(fullfile(myFolder,'rawData', myFiles(1).name));
myImage = double(myImage);
myImage = myImage/max(max(myImage));

poligonMask = roipoly(myImage);

save(fullfile(resultsFolder, 'roiMask.mat'), 'poligonMask');
