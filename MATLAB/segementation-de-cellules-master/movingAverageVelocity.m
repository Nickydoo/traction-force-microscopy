function [MovAverageVelocity,MovStdVelocity,MovMaxVelocity,velocity,vx,vy,averageVelocity,stdVelocity,lengthTrack] = movingAverageVelocity(tracksIn, nbTracks, period, dt)

nbPts = period/dt;

iout=1;
for it = 1:length(nbTracks)
for idx = 1:nbTracks(it)
    iTrack = tracksIn{it}(:,end) == idx;
    track = tracksIn{it}(iTrack,1:2);
        vx{iout} = diff(track(:,1))/dt;
        vy{iout} = diff(track(:,2))/dt;
        velocity{iout} = sqrt(vx{iout}.^2+vy{iout}.^2);
        averageVelocity(iout) = mean(velocity{iout});
        stdVelocity(iout) = std(velocity{iout});
        lengthTrack(iout) = length(track)*dt;
    for idxAv = 1:length(track)-nbPts  
        MovAverageVelocity{iout}(idxAv) = mean(velocity{iout}(idxAv:idxAv+nbPts-1));
        MovStdVelocity{iout}(idxAv) = std(velocity{iout}(idxAv:idxAv+nbPts-1));
        MovMaxVelocity{iout}(idxAv) = max(velocity{iout}(idxAv:idxAv+nbPts-1));
    end
    iout = iout+1;
     iTrack = [];
     track = [];
end
end
    