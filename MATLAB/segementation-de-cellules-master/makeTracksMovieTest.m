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

function makeTracksMovie(rawDataDir,tracks,resDir,nframes,verbose,msk, trkFilter)

% Defaults
if nargin < 7, trkFilter = @(x) x; end %Default is no filter
if nargin < 6, msk       = [];     end %Default is no mask
if nargin < 5, verbose   = true;   end %Default is verbose
if nargin < 4, nframes   = Inf;    end %Default is all frames

% Constants
colores={[1   0   0  ]};

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
imTrack = zeros([size(im0),3]);
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
 
 
for k= 1:nframes %k= 1:nframes
    
%     if verbose, progressText(k/(nframes),'Drawing tracks'); end
    
    im = double(imread([rawDataDir fnIms(k).name]));
   
    
    % Normalizes locally
    im = (im - min(im(:))) / (max(im(:)) - min(im(:)));
    
    % Draws images in gray levels
    imDrawn(:,:,1) = im;
    imDrawn(:,:,1) = max((imTrack(:,:,1)*255),im);
    imDrawn(:,:,2) = im;
    imDrawn(:,:,3) = im;
    
    %Get tracks to Draw
    
    iTracks  = tracks(tracks(:,3) == k,:);
    %iTracks  = tracks(tracks(:,3) <= k,:); %to draw all previous tracks
    
    if isempty(iTracks), continue, end
    
    %Get tracks IDs
    iVesIx  = iTracks(:,4);
    
    %Get previous state of each track
    state = init(iVesIx);
    
    %Draw segment from last to current position
    for j=1:length(iVesIx)
        if ~state(j), continue, end
        
        % Get current track nodes
        jTrack = tracks(tracks(:,4)==iVesIx(j),:);
        
        % Restrict to up to time i
        jTrack = jTrack(jTrack(:,3) <= k,:);
        
        % Skip disapeared nodes
        jTrack = jTrack(~isnan(jTrack(:,1)),:);
%         disp([num2str(k) ' ' num2str(j) ])

        % filter for short track
        if size(jTrack,1)<10, continue, end
        
        % test to manually exclude tracks
        if any(jTrack(:,4) == 151), continue, end
      
        % Actually draw the lines
        imDrawn = drawTrack(imDrawn,jTrack,colores{mod(iVesIx(j), size(colores,2))+1});
        imTrack = drawTrack(imTrack,jTrack,colores{mod(iVesIx(j), size(colores,2))+1});
        
        % Draw a number next to current position
        %begTrack = jTrack(1,1:2);
        %imDrawn = addNumbersImage(imDrawn, iVesIx(j), [25, 25], [begTrack(2), begTrack(1)], colores{mod(iVesIx(j), size(colores,2))+1});
        
    end
    
    % Write resulting frame to disk.
    imwrite(imDrawn,[resDir 'test2_frame_' num2str(k,'%04.0f') '.tif'], 'tif')
    
    % Set track as initialized
    init(iVesIx) = 1;
    
end

% progressText(1,'Drawing tracks');

end

% ***** FILTER FUNCTION  ******
function outTracks = filterTracks(inTracks)

outTracks = [];

if isempty(inTracks), return, end

trkId = unique(inTracks(:,4));

cnt = 1;

for j =1:length(trkId)
    
    if (mod(j,100)==0)
        disp(['Filtering Tracks: ' num2str(j) ' of ' num2str(length(trkId))])
    end
    
    iTrack = inTracks(inTracks(:,4) == trkId(j),:);
    
    trkInfo = processTrack(iTrack(:,1),iTrack(:,2),iTrack(:,3));
    
    %     cnd = (trkInfo(1) <= 10) | (trkInfo(6) < 0.3) | (trkInfo(4) < 0.93) | (trkInfo(4) > 1.92) ;
    
    cnd = false;
    
    if (cnd), continue, end
    
    iTrack(:,4) = cnt;
    
    outTracks = [outTracks; iTrack];
    
    cnt = cnt + 1;
    
end

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
