
function tracks = makeTrackingPNG_sb(tracks,resDir, img)



msk = [];
frames = min(tracks(:,3)):max(tracks(:,3));
% Constants

colores = [1, 1, 0; 1 0, 0; 0, 1, 0; 1, 0, 1]; 

% Check if input data exist


% Create output directory
if ~exist(resDir,'dir')
    mkdir(resDir);
    disp(['Create directory: ' resDir])
end

% Ensure choosen frames are within the images set
imDrawn = zeros([size(img),3]);

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

[rows,cols] = size(img);

imshow(img,[],'Border','Tight'), hold on


for t = 1:numel(idsInTimeRange)
    iTrack = tracksGood(ismember(tracksGood(:,4),idsInTimeRange(t)),:);
    
    msk = ismember(iTrack(:,3),frames(end));
    line(iTrack(:,1),iTrack(:,2), 'Color', 'r');
end

drawnow

print(fh,auxfname,'-dpng')
im = imread(auxfname);
[imind,cm] = rgb2ind(im,256);

imwrite(imind,cm,fullfile('niceTracks.png'),'png')

end


