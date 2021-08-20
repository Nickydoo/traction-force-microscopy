
function tracks = makeTrackingGIF_JR(rawDataDir,tracks,resDir,frames,msk,positionID)
%% test
if nargin == 0
    masterFolder = 'P:\Desktop\Dropbox (Biophotonics)\Backup Axotom';
    sample = '20190618';
    positionID = 0;
    load(fullfile(masterFolder, sample,['Track' num2str(positionID)],'trackFilterResults.mat'))
    rawDataDir = fullfile(masterFolder, sample,['Results' num2str(positionID)]);
    resDir = fullfile(masterFolder, sample, 'Tracks');
    frames    = min(colorTr(:,3)):max(colorTr(:,3)); 
    msk = [];
else
    % Defaults
    %if nargin < 6, trkFilter = @(x) x; end %Default is no filter
    if nargin < 5, msk       = [];     end %Default is no mask
    if nargin < 4, frames    = min(tracks(:,3)):max(tracks(:,3));    end %Default is all frames
end
%%

% Constants
colores = [1, 1, 0; 1 0, 0; 0, 1, 0; 1, 0, 1]; 
linewidth = 1;
fontsize = 16;

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

imDrawn = zeros([size(imread(fullfile(rawDataDir, fnIms(1).name))),3]);

% Filter tracks
% tracks = trkFilter(tracks);
% if isempty(tracks), error('Error: No trajectories'), end

auxfname = 'auxFile.png';

fastTracksPos = colorTr(:,5) == 3;
slowTracksPos  = colorTr(:,5) == 2; 
    
for k = frames(1:end)
    
    % creates tracks lines for insertShape
    timePos = colorTr(:,3) <= k;
    
    tracksLineFast = {};
    tracksLineSlow = {};
    
    if k > 1
        for idxTr = unique(colorTr(:,4))'
            trackPos = (colorTr(:,4) == idxTr);
            trackLength = 1:sum(trackPos & timePos);

            fastPos = trackPos & fastTracksPos & timePos;
            slowPos = trackPos & slowTracksPos & timePos;

            if logical(sum(fastPos)) & length(trackLength) > 1
                singleLineFast = zeros(1,2*length(trackLength));
                singleLineFast(2*trackLength-1) = colorTr(fastPos,1);
                singleLineFast(2*trackLength) = colorTr(fastPos,2);
                tracksLineFast = {tracksLineFast{:},singleLineFast};
                clear singleLineFast
            end
            if logical(sum(slowPos)) & length(trackLength) > 1
                singleLineSlow = zeros(1,2*length(trackLength));
                singleLineSlow(2*trackLength-1) = colorTr(slowPos,1);
                singleLineSlow(2*trackLength) = colorTr(slowPos,2);
                tracksLineSlow = {tracksLineSlow{:},singleLineSlow};
            end
            
        end
    end 
    im = imread(fullfile(rawDataDir, fnIms(k).name));
    
    
%    imshow(im,[],'Border','Tight'), hold on
    
    im = insertText(im,[20,50],num2str(k,'%03.0f'),'TextColor','yellow','FontSize',36);
    if ~isempty(tracksLineFast); im = insertShape(im, 'Line', tracksLineFast, 'LineWidth',linewidth,'Color','green'); end;
    if ~isempty(tracksLineSlow); im = insertShape(im, 'Line', tracksLineSlow, 'LineWidth',linewidth,'Color','red'); end;
    im = insertText(im,[60,150],'S','TextColor','red','FontSize',fontsize); % 'r' Red = Slow
    im = insertText(im,[60,180],'F','TextColor','green','FontSize',fontsize); % 'g' Green  = Fast 
    
%     print(fh,auxfname,'-dpng')
%     im = imread(auxfname);
    [imind,cm]=rgb2ind(im,256);
    
    if k == frames(1)
        imwrite(imind,cm,fullfile(resDir,'niceTracks.gif'),'gif','Loopcount',inf)
    else
        imwrite(imind,cm,fullfile(resDir, 'niceTracks.gif'),'gif','Writemode','append','DelayTime',0.1)
    end
disp(['frame ' num2str(k) ' complété'])    
end

end


