% This is a shorter version of the getTrajectroiesPropertiesNoPattern
% There is a filter for maximum allowed A2 and maximum allowed Speed
% J Roy Feb 2017

function [tracksDescriptors, stepDescriptors] = getPropertiesSpeedA2(trackResult, frameTimeInterval, rw, cl, minTL, maxA2, maxSp)
% this is a version of getProperties where I use a cutoff for jumps

tracksDescriptors = []; %Descriptors for each trajectory
stepDescriptors   = []; %Descriptors for each step of a trajectory
msk               = [];
d                 = [1; 0];
%distancePixel     = 7.4 / 10;  %um/pixel  Camera on axotom since summer 2016.
distancePixel     = 6.47/10; % with new 10x objective 0.25 NA.
%distancePixel     = distancePixel/10; %um/pixel 10 correspond to the objective

if isempty(trackResult), return, end

%Sorts tracks: first by ID, then by time
trackResult = sortrows(trackResult,[4 3]);

%left over from old function
trackResult = [trackResult,zeros(size(trackResult(:,1)))]; %Append zeros column to tracks array

tkIds   = unique(trackResult(:,4)); %Track IDs
nTracks = numel(tkIds);

%% Initialize arrays

%Initialize stepDescriptors arrays
step                    = []; % [um]
stepLag                 = []; % [second]
stepSpeed               = []; % [um / second]
stepDirSpeed            = []; % [um / second]
stepAngle               = []; 
stepInFlag              = []; % 0 = not in the pattern, 1 = in the pattern
stepTrackID             = []; % parent track ID

%Preallocate tracksDescriptors arrays
viaje                   = NaN(nTracks,1); % [um]
velocidad               = NaN(nTracks,1); % [um / second]
velNorm                 = NaN(nTracks,1); % [um / second]
MSD                     = NaN(nTracks,1); % [um^2 / second]
chemotaxisIndex         = NaN(nTracks,1); % adimensional
directionalVelocity     = NaN(nTracks,1); % [um / second]
antiDirectionalVelocity = NaN(nTracks,1); % [um / second]
lag                     = NaN(nTracks,1); % seconds
orientProgress          = NaN(nTracks,1); % slope of linear fit of cos(q) vs time.
meanPos                 = NaN(nTracks,1); % Central position of the Trajectory (normalized)
meanTime                = NaN(nTracks,1); % Central time of the Trajectory [seconds]
inTime                  = NaN(nTracks,1); % [%} Percentage of the tracks inside the pattern
RG2Tr                   = NaN(nTracks,1); % Squared Gyration Radius
angTr                   = NaN(nTracks,1); % Net angle of the track
A2Tr                    = NaN(nTracks,1); % Shape parameter within [0,1]. 0:Round, 1:line shaped
dmax                    = NaN(nTracks,1); % maximum distance in the track, comparing all the points


%%  Evaluate current track

for k = 1:nTracks
    
    kTrack = trackResult(trackResult(:,4) == tkIds(k),:); %Current track
    
    %Remove NaN steps
    kTrack = kTrack(~isnan(kTrack(:,1)) & ~isnan(kTrack(:,2)),:);
    
    %Remove short tracks
    if size(kTrack,1)<minTL, continue, end 
    
    x = kTrack(:,1); %Array of x(i+1) - x(i)
    y = kTrack(:,2); %Array of y(i+1) - y(i)
    t = kTrack(:,3); %Array of t(i+1) - t(i)
    
    dx = diff(kTrack(:,1)); %Array of x(i+1) - x(i)
    dy = diff(kTrack(:,2)); %Array of y(i+1) - y(i)
    dt = diff(kTrack(:,3)); %Array of t(i+1) - t(i)
    
    dd = sqrt(dx.^2 + dy.^2); %Array of distances from frame i to frame i+1
    phi = atan(dy./dx);
    
    %Central position of the Trajectory in the coordinate frame of the pattern
    trackCenter = [mean(kTrack(:,1));mean(kTrack(:,2))]; 
    
    %descriptors for steps in current track
    kdistStartEnd          = sqrt((kTrack(end,1) - kTrack(1,1)).^2 + (kTrack(end,2) - kTrack(1,2)).^2);
    ktravelDistance        = nansum(dd);
    kinstantVel            = dd ./ dt; 
    %kinstantVel            = dd ./ dt .* exp(1i*phi);
    kangs                  = atan2(dy,dx); % Array of Orientation angle of each step
    kinstantDirectionalVel = ([dx,dy] * d) ./ dt;
    inFlag                 = logical(kTrack(1:end-1,5)); %Flag for steps with first point in msk
    currentID              = (kTrack(1:end-1,4));
    
    %for chemotactic index (according to Iglesias 2013)
    posRot = [kTrack(:,1)'; kTrack(:,2)']; 
    posRot = posRot';
    dxRot  =  diff(posRot(:,1));
    dyRot  =  diff(posRot(:,2));
    ddRot  =  sqrt(dxRot.^2 + dyRot.^2);
 
    CI     =  (nansum(dxRot))/(nansum(ddRot));
    
    if sum(inFlag) > 0
      inTimes =  kTrack([logical(kTrack(1:end-1,5));true],3);
      inPos   =  [kTrack([logical(kTrack(1:end-1,5));true],1)';kTrack([logical(kTrack(1:end-1,5));true],2)']; 
      inX     =  (inPos(1,:)' - xPmin) / (xPmax - xPmin);
    else
      inTimes = [0];  
      inX     = [0];
    end
    
    % compute slope of orientation vs time
    cs = kinstantDirectionalVel ./ kinstantVel; %Cosine of orientation angle
    ts = kTrack(1:end-1,3);
      
    if length(ts(~isnan(cs))) > 1
       p = polyfit(ts(~isnan(cs)),cs(~isnan(cs)),1);
       orientProgress(k)          = p(1);
    end
    
   [~,~,RG2,ang,~,A2] = compute_gyration_tensor(kTrack(:,1),kTrack(:,2));

    sqGyrRad = RG2 ;
    netAng   = ang ;
    shapeA2  = A2 ;
    
    % Remove abberante tracks
    %if shapeA2 > maxA2, continue, end 
    
    % Avoiding calculating jumps
    %kinstantVelnoNAN = kinstantVel(~isnan(kinstantVel));
    velNorm(k) = nanmean(kinstantVel(kinstantVel<maxSp));
    %velNorm(k) = median(kinstantVelnoNAN(kinstantVelnoNAN<maxSp));
    
%% Write down descriptors for current steps or track

% Step descritors to global arrays
step         = [step;         dd];
stepLag      = [stepLag;      dt];
stepSpeed    = [stepSpeed;    kinstantVel];
stepDirSpeed = [stepDirSpeed; kinstantDirectionalVel];
stepAngle    = [stepAngle;    kangs];
stepInFlag   = [stepInFlag;   inFlag];
stepTrackID  = [stepTrackID;  currentID];
    
% Track descriptors for current track 
%viaje(k)                   = ktravelDistance;
viaje(k)                   = kdistStartEnd;
velocidad(k)               = nanmean(kinstantVel);
velNorm(k)                 = nanmean(kinstantVel(kinstantVel<maxSp));
MSD(k)                     = nanmean(kinstantVel.^2);
%velNorm(k)                 = abs(nanmean(kinstantVel));
chemotaxisIndex(k)         = CI;
directionalVelocity(k)     = nanmean(    kinstantDirectionalVel(kinstantDirectionalVel > 0));
antiDirectionalVelocity(k) = abs(nanmean(kinstantDirectionalVel(kinstantDirectionalVel < 0)));
lag(k)                     = kTrack(end,3) - kTrack(1,3);            
meanPos(k)                 = trackCenter(1);
meanTime(k)                = (kTrack(end,3) + kTrack(1,3)) / 2;
inTime(k)                  = (sum(inFlag)/numel(inFlag).*100);
RG2Tr(k)                   = sqGyrRad;
angTr(k)                   = netAng;
A2Tr(k)                    = shapeA2;
dmax(k)                    = sqrt( max(max( (x-x').^2+(y-y').^2) ) ); %maximum distance over all the points


end

%% Apply calibration

step                   = step         * distancePixel;
stepLag                = stepLag      * frameTimeInterval *60;% *60 to get um per minutes. 
stepSpeed              = stepSpeed    * distancePixel / frameTimeInterval *60;
stepDirSpeed           = stepDirSpeed * distancePixel / frameTimeInterval *60;
stepAngle              = stepAngle    * 180 / pi;

viaje                   = viaje * distancePixel;
lag                     = lag   * frameTimeInterval;
velocidad               = velocidad               * distancePixel / frameTimeInterval *60;
directionalVelocity     = directionalVelocity     * distancePixel / frameTimeInterval *60;
antiDirectionalVelocity = antiDirectionalVelocity * distancePixel / frameTimeInterval *60;
orientProgress          = orientProgress           / frameTimeInterval*60;
meanTime                = meanTime * frameTimeInterval*60; 

%% Create output arrays

stepDescriptors   = [step, stepLag, stepSpeed, stepDirSpeed, stepAngle, stepTrackID];
tracksDescriptors = [tkIds, viaje, velocidad, dmax, MSD, velNorm, chemotaxisIndex,RG2Tr, A2Tr];

end


