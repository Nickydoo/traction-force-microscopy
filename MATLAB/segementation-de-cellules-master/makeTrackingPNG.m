
function tracks = makeTrackingPNG(rawDataDir,tracks,resDir,frames,msk,positionID)

%% test
if nargin == 0
    masterFolder = 'P:\Desktop\Dropbox (Biophotonics)\Backup Axotom';
    sample = '20190719_2.3';
    frameNum = 'Track0';
    load(fullfile(masterFolder, sample,frameNum,'trackFilterResults.mat'))
else
    % Defaults
    %if nargin < 6, trkFilter = @(x) x; end %Default is no filter
    if nargin < 5, msk       = [];     end %Default is no mask
    if nargin < 4, frames    = min(tracks(:,3)):max(tracks(:,3));    end %Default is all frames
end
%%
% Constants

colores = [1, 1, 0; 1 0, 0; 0, 1, 0; 1, 0, 1]; 

% Check if input data exist

fnIms  = dir(fullfile(rawDataDir, '*.jpg'));
if isempty(fnIms), error('Error: Images directory is empty'), end

% Create output directory
if ~exist(resDir,'dir')
    mkdir(resDir);
    disp(['Create directory: ' resDir])
end

% Ensure choosen frames are within the images set
frames = frames(ismember(frames,1:numel(fnIms)));

imDrawn = zeros([size(imread(fullfile(rawDataDir, fnIms(1).name))),3]);

% Filter tracks
% tracks = trkFilter(tracks);
% if isempty(tracks), error('Error: No trajectories'), end

% Change track Ids if needed
if any(diff(unique(tracks(:,4)))>1) || min(tracks(:,4)) ~= 1
    tracks = normalizeIds(tracks);
end

% Select tracks within mask to be drawn
if ~isempty(msk)
    plot(tracks(:,1),tracks(:,2),'.r')
    tracks = selectTracksWhithinMask(tracks,msk,true);
end

%Round positions, as it make no sense to keep superresolution to draw
tracks(:,1:2) = round(tracks(:,1:2));

% Compute trajectories properties to paint colors
idsInTimeRange = unique(tracks(ismember(tracks(:,3),min(frames):max(frames)),4));
tracksGood  = tracks(ismember(tracks(:,4),idsInTimeRange),:);

% Compute descriptors for selected tracks, and assign bins to each track
%[tracksDescriptors, ~] = getTrajectoriesPropertiesNoPattern(tracksGood, 1, size(imDrawn, 1), size(imDrawn, 2));
%[~, ~, colorBin] = histcounts(tracksDescriptors(:,14), 9); % 14 is A2?

fh = figure;
auxfname = 'auxFile.png';

% Draw tracks on last frame
clf(fh,'reset');
print(fh,auxfname,'-dpng')
im = imread(fullfile(rawDataDir, fnIms(frames(end)).name));

[rows,cols] = size(im);

imshow(im,[],'Border','Tight'), hold on


for t = 1:numel(idsInTimeRange)
    iTrack = tracksGood(ismember(tracksGood(:,4),idsInTimeRange(t)),:);
    
    msk = ismember(iTrack(:,3),frames(end));
    
    %thisColor = colores((colorBin(ismember(tracksDescriptors(:,1),idsInTimeRange(t))) + 1) * 6,:);
    thisColor = colores(unique(iTrack(:,5)),:);
    
    line(iTrack(:,1),iTrack(:,2),'Color',thisColor);
    
%     plot(iTrack(msk,1),iTrack(msk,2),'*','MarkerSize',10, 'MarkerFaceColor', 'r','MarkerEdgeColor','r')
    
    textPos = [iTrack(end,1) + 15,iTrack(end,2) - 15];
    textPos(1) = min(cols - 10,max(1,textPos(1)));
    textPos(2) = min(rows - 10,max(1,textPos(2)));
    
    text(textPos(1),textPos(2),num2str(idsInTimeRange(t)),'Color',thisColor,'FontSize',8);
    
%     text(60,120,'sr','Color','y','FontSize',16) % 'y' Yellow = Slow + Round (A2 small)
%     text(60,150,'sl','Color','r','FontSize',16) % 'r' Red = Slow + Linear (A2 big)
%     text(60,180,'fr','Color','g','FontSize',16) % 'g' Green  = Fast + Round  
%     text(60,210,'fl','Color','m','FontSize',16) % 'm' Purple = Fast + Linear

    text(60,150,'slow','Color','r','FontSize',16) % 'r' Red = Slow
    text(60,180,'fast','Color','g','FontSize',16) % 'g' Green  = Fast 
    
    
end

drawnow

print(fh,auxfname,'-dpng')
im = imread(auxfname);
[imind,cm] = rgb2ind(im,256);

imwrite(imind,cm,fullfile(resDir, ['niceTracks' num2str(positionID) '.png']),'png')

close
end


