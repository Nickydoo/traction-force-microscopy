
function makeTrackingGIF_ND(rawDataDir,colorTr,resDir,frames,msk,positionID,dmax,speed)
%% test
% nargin = 0
% for positionID = 1:31
if nargin == 0
    distancePixel     = 6.47/10;
    %masterFolder = '\\AXOTOM\work\Nicolas'; %Machine Learning
    masterFolder = 'P:\Desktop\Dropbox (Biophotonics)\Backup Axotom';
    %masterFolder = 'C:\Users\Nicolas\Dropbox (Biophotonics)\Backup Axotom'; %ordi perso
    sample = '20190906-3.2';
    %sample = '20190820_35mm_1.7.2';
    %positionID = 5;
    load(fullfile(masterFolder, sample,['Track' num2str(positionID-1)],'trackFilterResults.mat'))
    rawDataDir = fullfile(masterFolder, sample,['Results' num2str(positionID-1)]);
    resDir = fullfile(masterFolder, sample, 'Tracks GIF');
    frames    = min(colorTr(:,3)):max(colorTr(:,3)); 
    msk = [];
   dmax = tracksDescriptors{positionID}(:,4)*distancePixel ; %um
   speed = tracksDescriptors{positionID}(:,3); %um per min
   tkIds = tracksDescriptors{positionID}(:,1); 
else
    tkIds = unique(colorTr(:,4));
    distancePixel     = 6.47/10;
    dmax = dmax*distancePixel;
    % Defaults
    %if nargin < 6, trkFilter = @(x) x; end %Default is no filter
    if nargin < 5, msk       = [];     end %Default is no mask
    if nargin < 4, frames    = min(colorTr(:,3)):max(colorTr(:,3));    end %Default is all frames
end
%%

% Constants
colores = [1, 1, 0; 1 0, 0; 0, 1, 0; 1, 0, 1]; 
linewidth = 3;
fontsize = 14;

% Check if input data exist
%fnIms  = dir(fullfile(rawDataDir,['N' num2str(positionID-1,'%03.0f') 'T*.TIF']));
fnIms  = dir(fullfile(rawDataDir, '*.jpg'));
if isempty(fnIms), error('Error: Images directory is empty'), end

% Create output directory
if ~exist(resDir,'dir')
    mkdir(resDir);
    disp(['Create directory: ' resDir])
end

% Ensure choosen frames are within the images set
frames = frames(ismember(frames,1:numel(fnIms)));

% Filter tracks
% tracks = trkFilter(tracks);
%if isempty(tracks), error('Error: No trajectories'), end

auxfname = 'auxFile.png';

fastTracksPos = colorTr(:,5) == 3;
slowTracksPos  = colorTr(:,5) == 2; 
    
for k = frames(1:end)
    
    % creates tracks lines for insertShape
    timePos = colorTr(:,3) <= k;
    
    tracksLineFast = {};
    tracksLineSlow = {};
    
    im = imread(fullfile(rawDataDir, fnIms(k).name));
    
hf = figure('units','pixels','Position',[0 0 size(im,2) size(im,1)],'visible','off');
axes('Units', 'normalized', 'Position', [0 0 1 1]);
imshow(im);

    
    if k > 1    
        ifast = 1;
        islow = 1;
        for idxTr = unique(colorTr(:,4))' %loop over every track
            trackPos = (colorTr(:,4) == idxTr);
            descriptorPos = (tkIds == idxTr);
            trackLength = 1:sum(trackPos & timePos);

            fastPos = trackPos & fastTracksPos & timePos;
            slowPos = trackPos & slowTracksPos & timePos;
            
            fastCoord = colorTr(fastPos,2) + (colorTr(fastPos,1)-1)*size(im,1);
            slowCoord = colorTr(slowPos,2) + (colorTr(slowPos,1)-1)*size(im,1);
            
            dmaxOneTrack = dmax(descriptorPos);
            speedOneTrack = speed(descriptorPos);
            
            
                %imOut = insertTextND(imIn,x,y,txt,color,ftsize)
            if logical(sum(fastPos)) & length(trackLength) > 1
                
                XLineFast = colorTr(fastPos,1);
                YLineFast = colorTr(fastPos,2);

                text(XLineFast(1),YLineFast(1),sprintf('1) %0.5g',dmaxOneTrack),'units','pixels','FontSize',fontsize,'Color','g','Units','data')
                text(XLineFast(1)+1,YLineFast(1)+fontsize,sprintf('2) %0.5g',speedOneTrack),'units','pixels','FontSize',fontsize,'Color','g','Units','data')
                line(colorTr(fastPos,1),colorTr(fastPos,2),'LineWidth',linewidth,'Color','g')
            end
            if logical(sum(slowPos)) & length(trackLength) > 1
               
                XLineSlow= colorTr(slowPos,1);
                YLineSlow = colorTr(slowPos,2);
                
                text(XLineSlow(1),YLineSlow(1),sprintf('1) %0.5g',dmaxOneTrack),'units','pixels','FontSize',fontsize,'Color','r','Units','data')
                text(XLineSlow(1)+1,YLineSlow(1)+fontsize,sprintf('2) %0.5g',speedOneTrack),'units','pixels','FontSize',fontsize,'Color','r','Units','data')
                line(colorTr(slowPos,1),colorTr(slowPos,2),'LineWidth',linewidth,'Color','r')
            end
        end
    end 
%     imOut = insertLineND(imIn,xy,color,linewidth)
    text(20,50,num2str(k,'%03.0f'),'Color','y','FontSize',30);
%     if ~isempty(tracksLineFast); im = insertLineND(im,tracksLineFast,'g',linewidth); end;
%     if ~isempty(tracksLineSlow); im = insertLineND(im,tracksLineSlow,'r',linewidth); end;
    text(60,150,'Slow','Color','r','FontSize',fontsize); % 'r' Red = Slow
    text(60,180,'Fast','Color','g','FontSize',fontsize); % 'g' Green  = Fast 
    text(60,210,'1) dmax (um)','Color','w','FontSize',fontsize); % 'r' Red = Slow
    text(60,240,'2) speed(mu/min)','Color','w','FontSize',fontsize); % 'g' Green  = Fast 
    
    frame = getframe(gcf);
    [imind,cm]=rgb2ind(frame.cdata,256);
    
    if k == frames(1)
        imwrite(imind,cm,fullfile(resDir,['niceTracks' num2str(positionID-1) '.gif']),'gif','Loopcount',inf)
    else
        imwrite(imind,cm,fullfile(resDir, ['niceTracks' num2str(positionID-1) '.gif']),'gif','Writemode','append','DelayTime',0.1)
    end
    close(hf)
end

end


