function segmentMovie(varargin)

if nargin>0
    myFolder=varargin{1};
    position=varargin{2};
    numWorkers=varargin{3};
else
    myFolder='/Users/santiago/Dropbox/projects/Joannie/Cancer/Images/Movie1/';
    position=0;
    numWorkers=0;
end

resultsFolder=[myFolder 'Results' num2str(position) '/'];
trackFolder=[myFolder 'Track' num2str(position) '/'];

if (~exist(resultsFolder,'dir')), mkdir(resultsFolder); end
if (~exist(trackFolder,'dir')), mkdir(trackFolder); end

myFiles=dir([myFolder 'N' num2str(position,'%03.0f') '*.tif'])

if (exist([resultsFolder 'roiMask.mat'],'file'))
    load([resultsFolder 'roiMask.mat']);
    poligonMask=double(poligonMask);
    haveMask=true;
end


%% Read and analyze


for it=1:size(myFiles, 1)
    
    myImage=double(imread([myFolder myFiles(it).name]));
    
    if haveMask
        [thisMask, cellStats]=segmentSingleImage(myImage.*poligonMask, 150); %minimum surviving object is 150 pixels of area
    else
        [thisMask, cellStats]=segmentSingleImage(myImage, 150); %minimum surviving object is 150 pixels of area
    end
   
    
    
    %% Get info on objects
    
    doSave([resultsFolder 'dataImage' num2str(sprintf('%04d',it)) '.mat'], cellStats);
    
    %% Get contours
    maskContours=thisMask-imerode(thisMask, strel('disk', 1));
        
    imwrite(imfuse(myImage, maskContours, 'blend'),[resultsFolder 'oldSchool' num2str(sprintf('%04d',it)) '.jpg'], 'jpg');
end





