% stack = registerstack(tifRead(char("D:\Sam\August 13\location 1_beads.tif")));
stack = tifRead(char("D:\Sam\August 18\location 3 registered.tif"));
depth = size(stack,3);
x = [];
y = [];
time = [];
beadsperframe = [];
for i = 1:depth
    beadsimg = mat2gray(stack(:,:,i));
    beadsimg = bpass(beadsimg,1, 7);
%     beadsimg = segmentFA(beadsimg, 5);
    %beadsimg = differenceOfGaussians(beadsimg, 1, 10); % Filtering image
    % beadsimg = bpass(beadsimg, 1, 10);
    pkfnd_out = pkfnd(beadsimg,0.03, 5);
    cnt = cntrd(beadsimg, pkfnd_out, 5,0);
    %cnt = locate_beads_sabass_2(beadsimg, 4, 15, 1.25);
    beadsx = cnt(:, 1);
    beadsy = cnt(:, 2);
    imshow(mat2gray(beadsimg))
    hold on
    plot(beadsx, beadsy, 'r.')
    hold off
    drawnow;
    % pause(1000)
    t = ones(length(cnt), 1).*i;
    x = [x ;beadsx];
    y = [y ;beadsy];
    time = [time; t];
    beadsperframe = [beadsperframe; size(beadsx)];
end
avg = mean(beadsperframe(:, 1));
dev = std(beadsperframe(:, 1));
data = [x y time];
save("bead_locations.mat", "data");
rw = size(stack,1);
cl = size(stack, 2);
search_radius = 5;
disp("locating done")
movieInfo = convertDetectionToDanuser(data);
tracksFinal = scriptTrackGeneralSpatialAverageNeutrophils(movieInfo, [rw, cl], search_radius, 3); % movieinfo, imsize, search radius, avgsize
tracksUt = uTracks2Matrix(tracksFinal); %[x y t trackid]
minTL     = 3   ; % minimum track lenght in frames.
maxA2     = 100  ; % this is to remove fake tracks of dust moving straight.
maxSp     = 100 ; % in pixels/fr. This is the equivalent of 5 um/min / 0.74 um/pixel
% frTimeInt = 120*jump  ; % in seconds
maxDmax   = 100/1.1; %pixels
minDmax   = 3; %pixels
tracks = filterTracksND(tracksUt, minTL, maxDmax, minDmax, 1, 1);
disp("filtered")
% tracks{itPosition} = filterTracksND(tracksuT, minTL,maxDmax,minDmax,start,jump);
%[tkIds, viaje, velocidad, dmax, MSD, velNorm, chemotaxisIndex,RG2Tr, A2Tr]
[tracksDescriptors, ~] = getPropertiesSpeedA2(tracks, 120, size(stack,1), size(stack, 2), minTL, maxA2, maxSp);
% save("tracking_descriptors.mat", "tracksDescriptors");
disp("got properties")
makeTrackingPNG_sb(tracks, 'ww', mat2gray(stack(:,:,end)));





