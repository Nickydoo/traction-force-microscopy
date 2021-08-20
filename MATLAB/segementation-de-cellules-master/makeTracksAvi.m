% makeTracksMovie: Create a movie from raw images and trajectories.


% -------------------------------------------------------------------------
% Copyright (C) 2014 Joannie Roy | Javier Mazzaferri
% javier.mazzaferri@gmail.com
% Centre de Recherche, Hopital Maisonneuve-Rosemont
% www.biophotonics.ca
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function makeTracksAvi(rawDataDir,tracks,resDir,nframes,verbose,msk, trkFilter)


% Defaults
if nargin < 7, trkFilter = @(x) x; end %Default is no filter
if nargin < 6, msk       = [];     end %Default is no mask
if nargin < 5, verbose   = true;   end %Default is verbose
if nargin < 4, nframes   = Inf;    end %Default is all frames

% Constants

colores=parula;
% colores={...
%     [0.5 0   0  ],[1   0   0  ],[0   0.5 0  ],[0   1   0  ],[0   0   0.5],...
%     [0   0   0.5],[0   0   1  ],[1   0.5 0  ],[1   0   0.5],[0   1   0.5],...
%     [0.5 0.5 1  ],[0.5 1   0.5],[1   0.5 0.5],[1   1   0.5],[1   0.5 1  ],...
%     [0.5 1   1  ],[1   1   1]};

% Check if input data exist
fnIms  = dir([rawDataDir '*.jpg']);
if isempty(fnIms)
    disp('Error: Images directoy is empty')
    return
end

if ischar(tracks)
    if ~exist([tracks 'tracking.mat'], 'file')
        disp(['Error: ''tracking.mat'' file not found in ' tracksDir])
        return
    else
        load([tracks 'tracking.mat'],'tracks'); 
    end
end

% Create output directory
if (~exist(resDir,'dir')), mkdir(resDir); end
disp(['Create directory: ' resDir])

% Initializations

nframes = min(numel(fnIms),nframes);

im0     = imread([rawDataDir fnIms(1).name]);
imDrawn = zeros([size(im0),3]);
clear im0

tracks = trkFilter(tracks); %won't do nothing if no filter is set

if isempty(tracks)
    disp('Error: No trajectories')
    return
end

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

%Array keeping track ids that have been started to draw
init = zeros(length(unique(tracks(:,4))),1);

%In each frame, draws all the tracks already started.

% progressText(0,'Drawing tracks');

vidObj = VideoWriter([resDir 'niceTracks.avi']);
open(vidObj);

%% Compute trajectories properties to paint colors

[tracksDescriptors, stepDescriptors] = getTrajectoriesPropertiesNoPattern(tracks, 1, size(imDrawn, 1), size(imDrawn, 2));

[N, edges, colorBin]=histcounts(tracksDescriptors(:,14), 10);


%%


for k= 1:nframes
    
%     if verbose, progressText(k/(nframes),'Drawing tracks'); end
    
    im = imread([rawDataDir fnIms(k).name]);
    
    
    %Get tracks to Draw
    
    iTracks  = tracks(tracks(:,3) == k,:);
    
    if isempty(iTracks), continue, end
    
    %Get tracks IDs
    iVesIx  = iTracks(:,4);
    
    %Get previous state of each track
    state = init(iVesIx);
    
    numbersImage=zeros(size(imDrawn));
    
    %Draw segment from last to current position
    for j=1:length(iVesIx)
        if ~state(j), continue, end

        % Get current track nodes
        jTrack = tracks(tracks(:,4)==iVesIx(j),:);

        % Restrict to up to time i
        jTrack = jTrack(jTrack(:,3) == k,:);
        
            % Skip disapeared nodes
            jTrack = jTrack(~isnan(jTrack(:,1)),:);
    %         disp([num2str(k) ' ' num2str(j) ])
            % Actually draw the lines
            
            % thisColor=colores(mod(iVesIx(j),64)+1,:);
            thisColor=colores(colorBin(iVesIx(j))*6,:);
            
            imDrawn(jTrack(1,2)-1:jTrack(1,2)+1,jTrack(1,1)-1:jTrack(1,1)+1,:)=...
                cat(3,ones(3)*thisColor(1),ones(3)*thisColor(2),ones(3)*thisColor(3));

            % Draw a number next to current position
            if or(mod(k,10)==0, k==nframes)
                begTrack = jTrack(1,1:2);
                %numbersImage = addNumbersImage(numbersImage, iVesIx(j), [25, 25], [begTrack(2), begTrack(1)], colores(mod(iVesIx(j),64)+1,:));
                numbersImage = addNumbersImage(numbersImage, iVesIx(j), [25, 25], [begTrack(2), begTrack(1)], thisColor);
            end

        end
    
    % Write resulting frame to disk.
    
    % Draws images in gray levels
    fuseImage(:,:,1) = im.*uint8(sum(imDrawn, 3)==0)+uint8(imDrawn(:,:,1)*255)+uint8(numbersImage(:,:,1)*255);
    fuseImage(:,:,2) = im.*uint8(sum(imDrawn, 3)==0)+uint8(imDrawn(:,:,2)*255)+uint8(numbersImage(:,:,2)*255);    
    fuseImage(:,:,3) = im.*uint8(sum(imDrawn, 3)==0)+uint8(imDrawn(:,:,3)*255)+uint8(numbersImage(:,:,3)*255);
 
   
    writeVideo(vidObj, fuseImage);
    
    % Set track as initialized
    init(iVesIx) = 1;
    
end

% progressText(1,'Drawing tracks');

end



% Actually draws tracks
function imDrawn = drawTrack(im,pTrack,color)

for i = 2:size(pTrack,1)
    sPos = pTrack(i-1,1:2);
    ePos = pTrack(i,1:2);
    
    cPos = sPos;
    
    while sum((cPos - ePos).^2) ~= 0
        
        m = double(ePos(2)-cPos(2)) / double(ePos(1)-cPos(1));
%         disp(i)
        im(cPos(2),cPos(1),:) = color;
        
        if (ePos(1) - cPos(1) ~= 0)
            
            dx = round(1      / sqrt(1+m*m)) * sign(ePos(1)-cPos(1));
            dy = round(abs(m) / sqrt(1+m*m)) * sign(ePos(2)-cPos(2));
            
        else
            dx = 0;
            dy = sign(ePos(2)-cPos(2));
        end
        
        cPos = cPos + [dx,dy];
        
    end
    
    im(cPos(2),cPos(1),:) = color;
    
end

imDrawn = im;

end


%Selects the tracks in tracks input that are withing msk.
%if wholeReq = false: All the tracks that have any position within msk are kept.
%if wholeReq = true: Only the tracks completelly included within msk are kept.
function [resTracks] = selectTracksWhithinMask(tracks,msk,wholeReq)

resTracks = [];

%Use only no NaN coordinate parts of the tracks because we need to know where the
%tracks are.
testTracks = tracks(~isnan(tracks(:,1)) & ~isnan(tracks(:,2)),:);

if isempty(testTracks), return, end

%Tracks positions that are within msk
idx = ismember(sub2ind(size(msk),testTracks(:,2),testTracks(:,1)),find(msk));
if ~any(idx), return, end

%Labels of tracks included in msk (there could be repeated values, but doesn't matter)
tracksIn = testTracks(idx,4);

if wholeReq
    %Labels of tracks NOT icluded in msk
    tracksOut = testTracks(~idx,4);
    
    %Tracks positions with labels within tracksIn and NOT in tracksOut
    resTracks = tracks(ismember(tracks(:,4),tracksIn) &...
        ~ismember(tracks(:,4),tracksOut),:);
    
else
    
    %Tracks positions with labels within trackLabels
    resTracks = tracks(ismember(tracks(:,4),tracksIn),:);
    
end

end
