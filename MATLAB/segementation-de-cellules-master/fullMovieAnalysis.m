clear

imagesFolder='/Users/santiago/Dropbox/projects/Joannie/Cancer/Images/Movie5/'
positionInSample=[0 1 2 3];
numWorkers=10;
%%
for it=1:numel(positionInSample)
    segmentMovie(imagesFolder, positionInSample(it), numWorkers); 
    createTrackableFile(imagesFolder, positionInSample(it));
    tracksuT=trackCells(imagesFolder, positionInSample(it));
    makeTracksAvi([imagesFolder 'Results' num2str(positionInSample(it)) '/'],...
        tracksuT,[imagesFolder 'Track' num2str(positionInSample(it)) '/'],Inf,1,[], @filterTracks);
end
