% Joannie Roy. 
% version July 2017 (include segmentation with morpho + STD + kmean +
% watershed)
% clear all
% Note: You can either set the time at which the tracking should start or
% drag a file call <listo> in the imagesFolder. 

clear getNewFiles

try
    
minSizeCell  = 250; %minimum area that can be considered a cell for segmentation
imagesFolder = uigetdir(pwd, 'Select the file where images will be stored');
numPositions = inputdlg('Enter the number of positions in the movie', 'numPositions', 1);
numPositions = str2double(numPositions{1});

%% Create Results and Track folders
for itPosition = 1:numPositions
    if (~exist([imagesFolder filesep 'Results' num2str(itPosition-1)],'dir')), mkdir([imagesFolder filesep 'Results' num2str(itPosition-1)]); end
    if (~exist([imagesFolder filesep 'Track' num2str(itPosition-1)],'dir')), mkdir([imagesFolder filesep 'Track' num2str(itPosition-1)]); end
end
if (~exist([imagesFolder filesep 'Tracks' ,'dir'])), mkdir([imagesFolder filesep 'Tracks']); end
if (~exist([imagesFolder filesep 'Tracks GIF' ,'dir'])), mkdir([imagesFolder filesep 'Tracks GIF']); end

trackDirTot = fullfile(imagesFolder, 'Tracks');
GIFfolder = fullfile(imagesFolder, 'Tracks GIF');

%choice=questdlg('Ready for drawing all masks?','MASKS'); % 'if ready to draw masks or if already drawn, click yes'

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
    %[~,rawDir, rawDirAd] = getNewFiles(imagesFolder);
    [~,rawDir] = getNewFiles(imagesFolder);
    
    % Draws mask
%     if strcmp(choice,'Yes')
%         for it = 1:numPositions
%             createPolygonMask(imagesFolder, it-1);
%         end
%         close gcf
%     end
    
    % Find files ready to segment
    theseFileNames = dir(fullfile(rawDir,'N*T*.*'));
    theseFileNames = fullfile(rawDir,{theseFileNames(:).name});
    
    %% Loop over images 
    for it = 1:numel(theseFileNames);
        
        % Parse position from filename
        thisPosition  = regexp(theseFileNames{it},['(?<=\' filesep 'N)([0-9]+?)(?=\T)'],'match'); 
        
        % Parse the time label from the filename
        thisTime = regexp(theseFileNames{it},'(?<=\N[0-9]+T)([0-9]+?)(?=\.)','match');
        
        % Results folder for this position
        resultsFolder = fullfile(imagesFolder,['Results' num2str(str2double(thisPosition{:}))]); 
        
        
        % If file is already segmented skips
        if exist(fullfile(resultsFolder,['dataImage' thisTime{:} '.jpg']),'file') %.jpg
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
            %maskedImageAd = maskedImageAd .*double(poligonMask);
        end
        
        % Segment image
        %[thisMask, cellStats] = segmentSingleImage(maskedImage, minSizeCell); 
        %[thisMask, cellStats] = segmentSingleSTD(maskedImage,maskedImageAd, minSizeCell, []); 
        %[thisMask, cellStats] = segmentCellGradNormGrad(maskedImage,minSizeCell);
        [thisMask, cellStats]=segmentDarkField(maskedImage, minSizeCell);
        
        % Save the object satistics for this image
        save(fullfile(resultsFolder,['dataImage' thisTime{:} '.mat']), 'cellStats'); 
    
        % Get contours
        maskContours = bwperim(thisMask);        
        
        % save a segmented image AND make GIF
        imOut = cat(3,uint8((mat2gray(myImage)+maskContours)*255), uint8(mat2gray(myImage)*255),uint8(mat2gray(myImage)*255));
        imwrite(imOut,fullfile(resultsFolder,['dataImage' thisTime{:} '.jpg']), 'jpg'); 
        [imForGIF,map] = rgb2ind(imOut,256);
        GIFname = [GIFfolder '\Results' thisPosition{:} '.gif'];
        
            if ~str2num(thisTime{:})
                imwrite(imForGIF,map,GIFname,'gif','LoopCount',Inf,'DelayTime',0);
            else
                imwrite(imForGIF,map,GIFname,'gif','WriteMode','append','DelayTime',0);
            end
        
        disp(['Segmentation done: ' theseFileNames{it}])
    end
 %%   
    % check whether the movie has finished to terminate the segmentation loop
    if exist(fullfile(imagesFolder, 'listo'), 'file'), break, end
    
    % Slow down loop to 500 ms
    pause(1);
    
    disp(logit(imagesFolder,'Idle . . .'))

end

disp('Finished segmentation')

%% Create one file to track per position
for itPosition = 1:numPositions
    createTrackableFile(imagesFolder, itPosition-1,jump); 
end

%% Track and create a movie per position
disp('Start tracking')

start = 1; % beginning frame
jump = 5; % jump between frames
smoothFactor = 5;

for itPosition = 1:numPositions
    tracksuT = trackCells([imagesFolder filesep], itPosition-1);
    % Make movie
    resDir   = fullfile(imagesFolder, ['Results' num2str(itPosition-1)]);
    trackDir{itPosition} = fullfile(imagesFolder, ['Track'   num2str(itPosition-1)]);
    %frames = 1:10:max(tracksuT(:,3)); % old version
    frames{itPosition} = 1:jump:max(tracksuT(:,3));   % for Fev 2017 version
    

    %% filtering tracks
    
    minTL     = 20/jump   ; % minimum track lenght in frames.
    maxA2     = 0.8  ; % this is to remove fake tracks of dust moving straight.
    maxSp     = 6.75*jump ; % in pixels/fr. This is the equivalent of 5 um/min / 0.74 um/pixel
    frTimeInt = 120*jump  ; % in seconds
     
    tracks{itPosition} = filterTracksJR(tracksuT, minTL,start,jump,smoothFactor);
    
    %[tkIds, viaje, velocidad, velNorm, chemotaxisIndex,RG2Tr, A2Tr]
    [tracksDescriptors{itPosition}, ~] = getPropertiesSpeedA2(tracks{itPosition}, frTimeInt, size(myImage, 1), size(myImage, 2), minTL, maxA2, maxSp);
end    
    
    
%% Sub categories

tracksDescriptorsTOT = cat(1,tracksDescriptors{:});
%C = intersect(slow,round);
pSpeed = 90;
pA2 = 60;
pSpeed_travel = 90;
speed_lim = prctile(tracksDescriptorsTOT(:,4),pSpeed);
%A2_lim = nanmean(tracksDescriptorsTOT(:,7));
A2_lim = prctile(tracksDescriptorsTOT(:,7),pA2);
speed_travel_lim = prctile(tracksDescriptorsTOT(:,4)./tracksDescriptorsTOT(:,2),pSpeed_travel);

for itPosition = 1:numPositions
   
pos_criteria = (tracksDescriptors{itPosition}(:,4)./tracksDescriptors{itPosition}(:,2))<speed_travel_lim;
slow   = tracksDescriptors{itPosition}(tracksDescriptors{itPosition}(pos_criteria,4)<speed_lim,1); 
fast{itPosition}   = tracksDescriptors{itPosition}(tracksDescriptors{itPosition}(pos_criteria,4)>=speed_lim,1); 
round  = tracksDescriptors{itPosition}(tracksDescriptors{itPosition}(pos_criteria,7)<A2_lim,1); 
linear = tracksDescriptors{itPosition}(tracksDescriptors{itPosition}(pos_criteria,7)>A2_lim,1); 
% 
% phenSR = intersect(slow,round);  % 'y' Yellow = Slow + Round (A2 small)
% mskSR  = ismember(tracks{itPosition}(:,4),phenSR(:,1));
% tr_sr  = tracks{itPosition}(mskSR,:);
% tr_sr5 = [tr_sr, ones(size(tr_sr,1),1)]; 
% % 
% phenSL = intersect(slow,linear); % 'r' Red = Slow + Linear (A2 big)
% mskSL  = ismember(tracks{itPosition}(:,4),phenSL(:,1));
% tr_sl  = tracks{itPosition}(mskSL,:);
% tr_sl5 = [tr_sl, ones(size(tr_sl,1),1)+1]; 
% % 
% phenFR = intersect(fast{itPosition},round);  % 'g' Green  = Fast + Round  
% mskFR  = ismember(tracks{itPosition}(:,4),phenFR(:,1));
% tr_fr  = tracks{itPosition}(mskFR,:);
% tr_fr5 = [tr_fr, ones(size(tr_fr,1),1)+2]; 
% % 
% phenFL = intersect(fast{itPosition},linear); % 'm' Purple = Fast + Linear
% mskFL  = ismember(tracks{itPosition}(:,4),phenFL(:,1));
% tr_fl  = tracks{itPosition}(mskFL,:);
% tr_fl5 = [tr_fl, ones(size(tr_fl,1),1)+3]; 

% colorTr =  [tr_sr5;tr_sl5;tr_fr5;tr_fl5];

phenS = slow; % 'r' Red = Slow + Linear (A2 big)
mskS  = ismember(tracks{itPosition}(:,4),phenS(:,1));
tr_s  = tracks{itPosition}(mskS,:);
tr_s5 = [tr_s, ones(size(tr_s,1),1)+1]; 

phenF = fast{itPosition};  % 'g' Green  = Fast + Round  
mskF  = ismember(tracks{itPosition}(:,4),phenF(:,1));
tr_f  = tracks{itPosition}(mskF,:);
tr_f5 = [tr_f, ones(size(tr_f,1),1)+2]; 

colorTr =  [tr_s5;tr_f5];


save([trackDir{itPosition} filesep 'trackFilterResults.mat'], 'tracks', 'tracksDescriptors', 'colorTr');

% makeTrackingGIF_JR(fullfile(imagesFolder,['Results' num2str(itPosition-1)]), colorTr,trackDir{itPosition},frames{itPosition},[], itPosition); % new version
makeTrackingPNG(fullfile(imagesFolder,['Results' num2str(itPosition-1)]), colorTr,trackDirTot,frames{itPosition},[], itPosition); % new version
% makeTrackingGIF_JR(fullfile(imagesFolder,'rawData'), colorTr,trackDir,frames,[], itPosition); % new version

end


catch exception
    disp(reportException(imagesFolder, exception));
end
    