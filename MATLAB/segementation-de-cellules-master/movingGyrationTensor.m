function [movR12,movR22,movRG2,movang,mova2,movA2,R12,R22,RG2,ang,a2,A2] = movingGyrationTensor(tracksIn, nbTracks, period, dt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function calculates the gyration tensor of a track for multiple
% overlaping periods 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nbPts = period/dt;

iout=1;
for it = 1:length(nbTracks)
for idx = 1:nbTracks(it)
    iTrack = tracksIn{it}(:,end) == idx;
    track = tracksIn{it}(iTrack,1:2);
    x = track(:,1);
    y = track(:,2);
    [R12_tmp,R22_tmp,RG2_tmp,ang_tmp,a2_tmp,A2_tmp] = compute_gyration_tensor(x,y);
    R12(iout) = R12_tmp;
    R22(iout) = R22_tmp;
    RG2(iout) = RG2_tmp;
    ang(iout) = ang_tmp;
    a2(iout) = a2_tmp;
    A2(iout) = A2_tmp;
    
    for idxAv = 1:length(track)-nbPts  
        movx = track(idxAv:idxAv+nbPts-1,1);
        movy = track(idxAv:idxAv+nbPts-1,2);
        [movR12_tmp,movR22_tmp,movRG2_tmp,movang_tmp,mova2_tmp,movA2_tmp] = compute_gyration_tensor(movx,movy);
        movR12{iout}(idxAv) = movR12_tmp;
        movR22{iout}(idxAv) = movR22_tmp;
        movRG2{iout}(idxAv) = movRG2_tmp;
        movang{iout}(idxAv) = movang_tmp;
        mova2{iout}(idxAv) = mova2_tmp;
        movA2{iout}(idxAv) = movA2_tmp;
    end
     iout = iout+1;
     iTrack = [];
     track = [];
end
end




