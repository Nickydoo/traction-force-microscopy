% Joannie Roy. I am making changes on December 23rd 2016
% clear all
% Note: You can either set the time at which the tracking should start or
% drag a file call <listo> in the imagesFolder. 

clear getNewFiles

try
    
minSizeCell  = 150; %minimum area that can be considered a cell for segmentation
imagesFolder = uigetdir(pwd, 'Select the file where images will be stored');
numPositions = inputdlg('Enter the number of positions in the movie', 'numPositions', 1);
numPositions = str2double(numPositions{1});

%% Create Results and Track folders
for itPosition = 1:numPositions
    if (~exist([imagesFolder filesep 'Results' num2str(itPosition-1)],'dir')), mkdir([imagesFolder filesep 'Results' num2str(itPosition-1)]); end
    if (~exist([imagesFolder filesep 'Track' num2str(itPosition-1)],'dir')), mkdir([imagesFolder filesep 'Track' num2str(itPosition-1)]); end
end

choice=questdlg('Ready for drawing all masks?','MASKS');

prompt = {'Enter the HOUR at which tracking should start:','Enter the MINUTES at which tracking should start:'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'25','00'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
finishHour    = str2num(answer{1,1});
finishMinutes = str2num(answer{2,1});


%% Segmentation loop
while true
   
    % check what time it is   
    if hour(datetime) == finishHour && minute(datetime) >= finishMinutes, break, end
    
    % Ask for new files
    [~,rawDir] = getNewFiles(imagesFolder);
    
    % Draws mask
    if strcmp(choice,'Yes')
        for it = 1:numPositions
            createPolygonMask(imagesFolder, it-1);
        end
        close gcf
    end
    
    % Find files ready to segment
    theseFileNames = dir(fullfile(rawDir,'N*T*.*'));
    theseFileNames = fullfile(rawDir,{theseFileNames(:).name});
    
    % Loop over images 
    for it = 1:numel(theseFileNames);
        
        % Parse position from filename
        thisPosition  = regexp(theseFileNames{it},['(?<=\' filesep 'N)([0-9]+?)(?=\T)'],'match'); 
        
        % Parse the time label from the filename
        thisTime = regexp(theseFileNames{it},'(?<=\N[0-9]+T)([0-9]+?)(?=\.)','match');
        
        % Results folder for this position
        resultsFolder = fullfile(imagesFolder,['Results' num2str(str2double(thisPosition{:}))]); 
        
        % If file is already segmented skips
        if exist(fullfile(resultsFolder,['dataImage' thisTime{:} '.TIF']),'file') %.jpg
            continue
        end
        
        % Read image
        if ~exist(theseFileNames{it},'file'), break, end
        myImage = double(imread(theseFileNames{it})); 
        maskedImage = myImage;
        
        % if there's a mask, load it
        if exist(fullfile(resultsFolder, 'roiMask.mat'),'file')
            load(fullfile(resultsFolder, 'roiMask.mat'));   
            maskedImage = maskedImage .* double(poligonMask);
        end
        
        % Segment image
        %[thisMask, cellStats] = segmentSingleImage(maskedImage, minSizeCell); 
        [thisMask, cellStats] = segmentSingleImageUsingCenters(maskedImage, minSizeCell, [], 0.4);
        
        % Save the object satistics for this image
        save(fullfile(resultsFolder,['dataImage' thisTime{:} '.mat']), 'cellStats'); 
    
        % Get contours
        maskContours = thisMask - imerode(thisMask, strel('disk', 1)); 
        
        % save a segmented image
        imwrite(imfuse(myImage, maskContours, 'blend'),fullfile(resultsFolder,['dataImage' thisTime{:} '.jpg']), 'jpg'); 
        
        disp(['Segmentation done: ' theseFileNames{it}])
    end
    
    % check whether the movie has finished to terminate the segmentation loop
    if exist(fullfile(imagesFolder, 'listo'), 'file'), break, end
    
    % Slow down loop to 500 ms
    pause(1);
    
    disp(logit(imagesFolder,'Idle . . .'))

end

disp('Finished segmentation')

%% Create one file to track per position
for itPosition = 1:numPositions
    createTrackableFile(imagesFolder, itPosition-1); 
end

%% Track and create a movie per position
disp('Start tracking')
for itPosition = 1:numPositions
    tracksuT = trackCells([imagesFolder filesep], itPosition-1);

    % Make movie
    resDir   = fullfile(imagesFolder, ['Results' num2str(itPosition-1)]);
    trackDir = fullfile(imagesFolder, ['Track'   num2str(itPosition-1)]);
    frames = 1:10:max(tracksuT(:,3)); % old version
    %frames = 1:1:max(tracksuT(:,3));   % for Fev 2017 version
    

    %% filtering tracks
    
    minTL     = 50   ; % minimum track lenght in frames.
    maxA2     = 0.8  ; % this is to remove fake tracks of dust moving straight.
    maxSp     = 6.75 ; % in pixels/fr. This is the equivalent of 5 um/min / 0.74 um/pixel
    frTimeInt = 60   ; % in seconds
     
    tracks = filterTracksJR(tracksuT, minTL);
    [tracksDescriptors, ~] = getPropertiesSpeedA2(tracks, frTimeInt, size(myImage, 1), size(myImage, 2), minTL, maxA2, maxSp);
    
    
    
%% Sub categories

%C = intersect(slow,round);

slow   = tracksDescriptors(tracksDescriptors(:,4)<nanmean(tracksDescriptors(:,4)),1); 
fast   = tracksDescriptors(tracksDescriptors(:,4)>nanmean(tracksDescriptors(:,4)),1); 
round  = tracksDescriptors(tracksDescriptors(:,6)<nanmean(tracksDescriptors(:,6)),1); 
linear = tracksDescriptors(tracksDescriptors(:,6)>nanmean(tracksDescriptors(:,6)),1); 

phenSR = intersect(slow,round);  % 'y' Yellow = Slow + Round (A2 small)
mskSR  = ismember(tracks(:,4),phenSR(:,1));
tr_sr  = tracks(mskSR,:);
tr_sr5 = [tr_sr, ones(size(tr_sr,1),1)]; 

phenSL = intersect(slow,linear); % 'r' Red = Slow + Linear (A2 big)
mskSL  = ismember(tracks(:,4),phenSL(:,1));
tr_sl  = tracks(mskSL,:);
tr_sl5 = [tr_sl, ones(size(tr_sl,1),1)+1]; 

phenFR = intersect(fast,round);  % 'g' Green  = Fast + Round  
mskFR  = ismember(tracks(:,4),phenFR(:,1));
tr_fr  = tracks(mskFR,:);
tr_fr5 = [tr_fr, ones(size(tr_fr,1),1)+2]; 

phenFL = intersect(fast,linear); % 'm' Purple = Fast + Linear
mskFL  = ismember(tracks(:,4),phenFL(:,1));
tr_fl  = tracks(mskFL,:);
tr_fl5 = [tr_fl, ones(size(tr_fl,1),1)+3]; 

colorTr =  [tr_sr5;tr_sl5;tr_fr5;tr_fl5];

save([trackDir filesep 'trackFilterResults.mat'], 'tracks', 'tracksDescriptors', 'colorTr');

makeTrackingGIF_JR(fullfile(imagesFolder,'rawData'), colorTr,trackDir,frames,[], itPosition); % new version

end

catch exception
    disp(reportException(imagesFolder, exception));
end
    