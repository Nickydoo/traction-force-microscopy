% Joannie Roy. 
% version July 2017 (include segmentation with morpho + STD + kmean +
% watershed)

% clear all
% Note: You can either set the time at which the tracking should start or
% drag a file call <listo> in the imagesFolder. 

clear getNewFiles settings 

try
    
    %inputs
    minSizeCell  = 250; %minimum area that can be considered a cell for segmentation
    oneCell = 1000; %average area in pixel for a cell
    
    d = dir('D:\Nicolas\scMOCa');
    fn = {d.name};
    [indx,tf] = listdlg('PromptString',{'Select a file.',...
    'Only one file can be selected at a time.',''},...
    'SelectionMode','single','ListString',fn);
    imagesFolder = fullfile('D:\Nicolas\scMOCa',fn{indx});
    syncfolder = 'D:\Nicolas\scMOCa\syncFolder';
    syncfiles = dir(fullfile(syncfolder,"*.*"));
    if not(exist(fullfile(imagesFolder,'movieSettings.m')))
        writeMovieSettings(imagesFolder)
    end
    
    %vider le sync folder
%     for isync = 1:numel(syncfiles)
%         if not(syncfiles(isync).isdir)
%             delete(fullfile(syncfolder,syncfiles(isync).name))
%         end
%     end
    
    run(fullfile(imagesFolder,'movieSettings.m'))

%% Create Results and Track folders

if (~exist([imagesFolder filesep 'Tracks' ,'dir'])), mkdir([imagesFolder filesep 'Tracks']); end
if (~exist([imagesFolder filesep 'Tracks GIF' ,'dir'])), mkdir([imagesFolder filesep 'Tracks GIF']); end

for idx = 1:numel(settings) 
    if (~exist([imagesFolder filesep settings(idx).sampleName ,'dir'])), mkdir([imagesFolder filesep settings(idx).sampleName]); end
end

trackDirTot = fullfile(imagesFolder, 'Tracks');
GIFDir = fullfile(imagesFolder, 'Tracks GIF');


%% Segmentation loop
syncAcquisition = 2;
while syncAcquisition == 2  
    
    % Ask for new files
    [~,rawDir] = getNewFiles(imagesFolder);
    
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
        if (~exist(resultsFolder,'dir')); mkdir(resultsFolder); end
        if (~exist([imagesFolder filesep 'Track' num2str(str2double(thisPosition{:}))],'dir')); mkdir([imagesFolder filesep 'Track' num2str(str2double(thisPosition{:}))]); end
        
        
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
        end
        
        % Segment image
        [thisMask, cellStats]=segmentDarkField(maskedImage, minSizeCell, oneCell);
        
        % Save the object satistics for this image
        save(fullfile(resultsFolder,['dataImage' thisTime{:} '.mat']), 'cellStats'); 
    
        % Get contours
        maskContours = bwperim(thisMask);        
        
        % save a segmented image AND make GIF
        imOut = cat(3,uint8((mat2gray(myImage)+maskContours)*255), uint8(mat2gray(myImage)*255),uint8(mat2gray(myImage)*255));
        imwrite(imOut,fullfile(resultsFolder,['dataImage' thisTime{:} '.jpg']), 'jpg'); 
        [imForGIF,map] = rgb2ind(imOut,256);
        GIFname = [GIFDir '\Results' thisPosition{:} '.gif'];
%         
%             if ~str2num(thisTime{:})
%                 imwrite(imForGIF,map,GIFname,'gif','LoopCount',Inf,'DelayTime',0);
%             else
%                 imwrite(imForGIF,map,GIFname,'gif','WriteMode','append','DelayTime',0);
%             end
%         
        disp(['Segmentation done: ' theseFileNames{it}])
    end
 %%  
    if ~exist(fullfile(theseFileNames{it},'*.tif*'))
        syncAcquisition = syncread(fullfile(syncfolder,'syncAcquisition.txt'));
    end
    % Slow down loop to 500 ms
    pause(1);
    
    disp(logit(imagesFolder,'Idle . . .'))

end

disp('Finished segmentation')

%% Create one file to track per position

start = 1; % beginning frame
jump = 1; % jump between frames
smoothFactor = 1;
numPositions = numel(dir(fullfile(imagesFolder,'Results*')));


for itPosition = 1:numPositions
    createTrackableFile(imagesFolder, itPosition-1,jump); 
    disp(['created ' num2str(itPosition) ' trackable files over ' num2str(numPositions)])
end

%% Track and create a movie per position

for itPosition = 1:numPositions
    tracksuT = trackCells([imagesFolder filesep], itPosition-1);
    % Make movie
    resDir   = fullfile(imagesFolder, ['Results' num2str(itPosition-1)]);
    trackDir{itPosition} = fullfile(imagesFolder, ['Track'   num2str(itPosition-1)]);
    frames{itPosition} = 1:jump:max(tracksuT(:,3));
    

    %% filtering tracks
    
    minTL     = 20/jump   ; % minimum track lenght in frames.
    maxA2     = 0.8  ; % this is to remove fake tracks of dust moving straight.
    maxSp     = 6.75*jump ; % in pixels/fr. This is the equivalent of 5 um/min / 0.74 um/pixel
    frTimeInt = 120*jump  ; % in seconds
    maxDmax   = 100/1.1; %pixels
    minDmax   = 5; %pixels
    tracks{itPosition} = filterTracksND(tracksuT, minTL,maxDmax,minDmax,start,jump);
    
    %[tkIds, viaje, velocidad, dmax, MSD, velNorm, chemotaxisIndex,RG2Tr, A2Tr]
    [tracksDescriptors{itPosition}, ~] = getPropertiesSpeedA2(tracks{itPosition}, frTimeInt, size(myImage, 1), size(myImage, 2), minTL, maxA2, maxSp);
end    
    
%% Sub categories
for iSample = 1:numel(settings)
    frameNums = 1:numPositions;
    tracksDescriptorsTOT = cat(1,tracksDescriptors{frameNums});

    %filtres
    pA2 = 60;
    A2_lim = prctile(tracksDescriptorsTOT(:,7),pA2);
    pSpeed_travel = 100;
    speed_travel_lim = prctile(tracksDescriptorsTOT(:,4)./tracksDescriptorsTOT(:,2),pSpeed_travel);


    %C = intersect(slow,round);
    pSpeed = settings.pSpeed; %5 for slow, 95 for fast;
    speed_lim = prctile(tracksDescriptorsTOT(:,4),pSpeed);
    %A2_lim = nanmean(tracksDescriptorsTOT(:,7));

    iMotor = 1;
    for itPosition = frameNums
           disp(['analysing position ' num2str(itPosition) ' over ' num2str(numPositions)]) 
        pos_criteria = (tracksDescriptors{itPosition}(:,4)./tracksDescriptors{itPosition}(:,2))<speed_travel_lim;
        slow   = tracksDescriptors{itPosition}(tracksDescriptors{itPosition}(pos_criteria,4)<speed_lim,1); 
        fast{itPosition}   = tracksDescriptors{itPosition}(tracksDescriptors{itPosition}(pos_criteria,4)>=speed_lim,1); 

        % 'r' Red = Slow + Linear (A2 big)
        mskS  = ismember(tracks{itPosition}(:,4),slow(:,1));
        tr_s  = tracks{itPosition}(mskS,:);
        tr_s5 = [tr_s, ones(size(tr_s,1),1)+1]; 

        phenF = fast{itPosition};  % 'g' Green  = Fast + Round  
        mskF  = ismember(tracks{itPosition}(:,4),phenF(:,1));
        tr_f  = tracks{itPosition}(mskF,:);
        tr_f5 = [tr_f, ones(size(tr_f,1),1)+2]; 

        colorTr{itPosition} =  [tr_s5;tr_f5];

        % positions to clap
        if settings(iSample).thisIsForControle
            trackForPoints = tracks{itPosition};
        else
            if settings.captureFastCells
                trackForPoints = tr_f;
            else
                trackForPoints = tr_s;
            end
        end

        %make stim masks
        oneStimMask = false(size(myImage));
            for iTrack = unique(trackForPoints(:,4))'
                 oneTrack = trackForPoints(trackForPoints(:,4)==iTrack,[1 2]);
                 ImPtsOneTrack= round(oneTrack(end,:));
                 oneStimMask(ImPtsOneTrack(2),ImPtsOneTrack(1))=true;
            end
            fileID = fopen(fullfile(imagesFolder,settings(iSample).sampleName,'cellPos.txt'),'w');
            %fprintf(fileID,'%f\t%f\r\n',ImPtsOneTrack);
            fclose(fileID);
            maskname = ['mask' sprintf('%03d',itPosition) '.tif'];
            imwrite(oneStimMask,fullfile(imagesFolder, maskname),'resolution',96);
            disp([maskname ' written'])
            
            
            

        % save
        %[tkIds, viaje, velocidad, dmax, MSD, velNorm, chemotaxisIndex,RG2Tr, A2Tr]
        results(iSample).name = settings(iSample).sampleName;
        results(iSample).dmax = tracksDescriptorsTOT(:,4);
        results(iSample).velNorm = tracksDescriptorsTOT(:,6);
        results(iSample).velocidad = tracksDescriptorsTOT(:,3);
        
        save([trackDir{itPosition} filesep 'trackFilterResults.mat'], 'tracks', 'tracksDescriptors', 'colorTr');
        save(fullfile(imagesFolder,settings(iSample).sampleName,'trackDescriptorsTOT.mat'),'tracksDescriptorsTOT')
        
    end
end
save(fullfile(imagesFolder,'results.mat'),'results')
disp(['results saved to : ' imagesFolder])

catch exception
    disp(reportException(imagesFolder, exception));
end


%% sync with Nikon
syncwrite(fullfile(syncfolder,'syncAcquisition.txt'))

pause(5)
syncMask = 2;
for idx = 1:numPositions
    
    while syncMask == 2;
        syncMask = syncread(fullfile(syncfolder,'syncMask.txt'));
    end
    
    maskname = ['mask' sprintf('%03d',idx) '.tif'];
    mask = imread(fullfile(imagesFolder, maskname));
    imwrite(mask,fullfile(syncfolder,'mask.tif'))
    
    syncwrite(fullfile(syncfolder,'syncMask.txt'));
    
    syncMask = 2;
    disp(idx)
    pause(1)
end
%%
figure
for iSample = 1:numel(settings)
    load(fullfile(imagesFolder,settings(iSample).sampleName,'trackDescriptorsTOT.mat'))
    dmax{iSample} = tracksDescriptorsTOT(:,4);
    hold on
    histogram(log10(dmax{iSample}))
    disp([results(iSample).name ' median(dmax) = ' num2str(median(results(iSample).dmax,'omitnan'))])
    disp([results(iSample).name ' mean(dmax) = ' num2str(mean(results(iSample).dmax,'omitnan'))])
end
legend({settings(:).sampleName})
xlabel('log(dmax)')

%% GIF and tracking fig
for itPosition = frameNums
    disp(['making tracking GIF and PNG ' num2str(itPosition)])
      makeTrackingPNG(fullfile(imagesFolder,['Results' num2str(itPosition-1)]), colorTr{itPosition},trackDirTot,frames{itPosition},[], itPosition); % new version
      makeTrackingGIF_ND(fullfile(imagesFolder,['Results' num2str(itPosition-1)]), colorTr{itPosition},GIFDir,frames{itPosition},[], itPosition,tracksDescriptors{itPosition}(:,4),tracksDescriptors{itPosition}(:,3)); % new version

end


    