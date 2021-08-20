%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% title : trackAnalysis
% description : takes tracks from SegmentOnline and analyses them
% author : Nicolas Desjardins-Lecavalier
% last edition : 2019-02-08
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc;

addpath('C:\work\nicolas\segementation-de-cellules-master\kakearney-boundedline-pkg-50f7e4b\Inpaint_nans')
addpath('C:\work\nicolas\segementation-de-cellules-master\kakearney-boundedline-pkg-50f7e4b\boundedline')
addpath('C:\work\nicolas\segementation-de-cellules-master\kakearney-boundedline-pkg-50f7e4b\catuneven')
addpath('C:\work\nicolas\segementation-de-cellules-master\kakearney-boundedline-pkg-50f7e4b\singlepatch')
addpath('C:\work\nicolas\segementation-de-cellules-master\kakearney-boundedline-pkg-50f7e4b\boundedline')

% imagesFolder = fullfile('G:' , 'Nicolas' , '20190212darkfield35mmON');
% numPositions = 12;
imagesFolder = fullfile('G:' , 'Nicolas' , '20190127scan35mm');
numPositions = 100;

tmin = [0.5 1 2 3 6 8 12]; %durée d'une track minimale (h)
ttotal = 12; %durée totale du film (h)
dt = 2/60; %durée entre deux acquisition (h)
ntvect = tmin/dt;
period = 2;
ntperiod = period/dt + 1; %nombre de frames pour la période d'intérêt
nttotal = ttotal/dt + 1; %nombre de frames pour le film total
idxNT = 1:nttotal;
p = 80; %percentile des tracks choisies
p2 = 95;
%theseFileNames = fullfile(rawDir,{theseFileNames(:).name});
for iPos = 1:numPositions
    resultsFolder{iPos} = fullfile(imagesFolder,['Results' num2str(iPos-1)],'trackResult.mat');
    if ~exist(resultsFolder{iPos})
        tracks_raw = [];
        tracksCellArray{iPos} = tracks_raw;
    else
        tracks_raw = load(resultsFolder{iPos});
        tracks_tmp{iPos} = tracks_raw.tracksuT;
        N1(iPos) = tracks_tmp{iPos}(end,end); %nombre de tracks initiale
        list1 = 1:N1(iPos);
        L{iPos} = sum(tracks_tmp{iPos}(:,end) == list1,1)'; %longueur des tracks
        %tracks{iPos} = tracks_tmp.tracksuT;
        
        for it = 1:length(ntvect)
            selectPos_tmp = L{iPos}>ntvect(it); %tracks plus longue
            NperH(iPos,it) = sum(selectPos_tmp); %nombre de tracks plus longues que nt
        end
        
        selectPos1 = L{iPos}>ntperiod; %tracks plus longue
        N2(iPos) = sum(selectPos1); %nombre de tracks plus longues que la période d'intérêt
        selectedTrackNb{iPos} = list1(selectPos1); %numéro des tracks conservées
        selectPos2 = sum(tracks_tmp{iPos}(:,end) == selectedTrackNb{iPos},2); %positions des tracks conservées
        
        tracks_tmp{iPos}(~selectPos2,:) = []; %supression des tracks trop courtes
        
        tracksCellArray{iPos} = NaN(N2(iPos)* nttotal, 4);% déf de tracks
        
        %renumérotation des tracks et remplissage
        for idx2 = 1:N2(iPos)
            if iPos == 1
                number = 0;
            else
                number = sum(N2(1:iPos-1));
            end
            pos2Chn = [];
            pos2Chn = tracks_tmp{iPos}(:,end) == selectedTrackNb{iPos}(idx2);
            posT = [];
            posT = tracks_tmp{iPos}(pos2Chn,3)+nttotal*(idx2-1);
            tracksCellArray{iPos}(idxNT+nttotal*(idx2-1),3) = idxNT;
            tracksCellArray{iPos}(idxNT+nttotal*(idx2-1),end)=number+idx2;
            tracksCellArray{iPos}(posT,1:2)=tracks_tmp{iPos}(pos2Chn,1:2);
            tracksCellArray{iPos}(posT,1:2)=tracks_tmp{iPos}(pos2Chn,1:2);
        end
    end
end

% créer une seule matrice pour tracks
tracks = tracksCellArray{1};
for iMatrix = 2:length(tracksCellArray)
    if isnumeric(tracksCellArray{iMatrix})
    tracks = [tracks ; tracksCellArray{iMatrix}];
    end   
end

%% analyse des tracks

% pour la track totale
[speed,vx,vy,averageSpeed,stdSpeed,maxSpeed,lengthTrack,d,dtot,dnet,dmax,MSD,MI,OR,vAC,alpha,phi,DA] = totalTrackProperties(tracks, sum(N2), dt);
[selectAverageSpeed,selectMaxSpeed,selectMSD,selectDtot,selectDnet,selectDmax,selectMI,selectOR,nbSelect] = selectTrack(averageSpeed',maxSpeed',MSD',dtot',dnet',dmax',MI',OR',p);


%% figures pour analyse des tracks

%% pour différentes longueur d'analyse
periodmov = [1 2 3 4];
for iPeriod = 1:length(periodmov)

[MOVaverageSpeed,MOVstdSpeed,MOVdtot,MOVdnet,MOVdmax,MOVMSD,MOVMI,MOVOR] = partialTrackProperties(tracks, sum(N2), dt, periodmov(iPeriod));
%[movR12,movR22,movRG2,movang,mova2,movA2,R12,R22,RG2,ang,a2,A2] = movingGyrationTensor(tracksCellArray, N2, periodmov(iPeriod), dt);
[MOVselectAverageSpeed{iPeriod},MOVselectMSD,MOVselectDtot,MOVselectDnet,MOVselectDmax,MOVselectMI,MOVselectOR,MOVnbSelect] = selectTrack(MOVaverageSpeed,MOVMSD,MOVdtot,MOVdnet,MOVdmax,MOVMI,MOVOR,p2);

for iinter = 1:size(MOVselectAverageSpeed{iPeriod},2)
intersectAverageSpeed{iPeriod}(iinter) = sum(sum(selectAverageSpeed'==MOVselectAverageSpeed{iPeriod}(:,iinter)))/size(MOVselectAverageSpeed{iPeriod},1);
intersectMSD{iPeriod}(iinter) = sum(sum(selectMSD'==MOVselectMSD(:,iinter),1))/size(MOVselectMSD,1);
intersectDtot{iPeriod}(iinter) = sum(sum(selectDtot'==MOVselectDtot(:,iinter),1))/size(MOVselectDtot,1);
intersectDnet{iPeriod}(iinter) = sum(sum(selectDnet'==MOVselectDnet(:,iinter),1))/size(MOVselectDnet,1);
intersectDmax{iPeriod}(iinter) = sum(sum(selectDmax'==MOVselectDmax(:,iinter),1))/size(MOVselectDmax,1);
intersectMI{iPeriod}(iinter) = sum(sum(selectMI'==MOVselectMI(:,iinter),1))/size(MOVselectMI,1);
intersectOR{iPeriod}(iinter) = sum(sum(selectOR'==MOVselectOR(:,iinter),1))/size(MOVselectOR,1);
end


[consMOVaverageSpeed,consMOVstdSpeed,consMOVdtot,consMOVdnet,consMOVdmax,consMOVMSD,meanCons, EMcons] = PropertyConservation(MOVaverageSpeed,MOVstdSpeed,MOVdtot,MOVdnet,MOVdmax,MOVMSD,sum(N2));

figure
subplot(1,2,1)
errorbar(meanCons,EMcons,'o')
title(['<conservation> + équart moyen '])
xticks(1:length(meanCons))
xticklabels({'<Speed>','std(Speed)','d_{tot}','d_{net}','d_{max}','MSD'})

subplot(1,2,2)
hold on
plot(intersectMSD{iPeriod})
plot(intersectDtot{iPeriod})
plot(intersectDnet{iPeriod})
plot(intersectDmax{iPeriod})

plot(intersectAverageSpeed{iPeriod})
legend('MSD','d_{tot}','d_{net}','d_{max}','<speed>')

ylabel('proportion des tracks sélectionnées qui sont les mêmes que pour 12h')
title(['période de ' num2str(periodmov(iPeriod)) 'h  ' num2str(length(selectAverageSpeed)) 'tracks choisies' ])
ylim([0 1])


%% évaluation du tracking

%% figures

%analyse de la longueur des tracks
% lnplot = 2;
% for it2 = 1:length(ntvect)
%     nameLeg{it2} = ['plus longues que' num2str(tmin(it2)) 'h'];
% end

% figure
% subplot(1,2,1)
% bar([N1',NperH])
% xlabel('position')
% ylabel('nombre de tracks')
% legend(['initial',nameLeg])
% subplot(1,2,2) 
% bar(NperH./N1')
% xlabel('position')
% ylabel('proportion de tracks conservées')
% legend(nameLeg)

% figure;
% subplot(2,2,1)
% plot(averageVelocity,stdVelocity,'o')
% xlabel('average Velocity')
%  ylabel('std')
%  
% subplot(2,2,2)
% plot(lengthTrack,averageVelocity,'o')
% ylabel('<v>')
%  xlabel('length (h)')
% 
%  subplot(2,2,3)
% [avePlot,iav] = sort(averageVelocity);
%  errorbar(1:sum(N2),avePlot,stdVelocity(iav),'o')
%  ylabel('average Velocity + std')
%  xlabel('movie frame')
%  
%  subplot(2,2,4)
%  plot(averageVelocity,A2,'o')
%  xlabel('<v>')
%  ylabel('A2')
%  
%  title(['periodmov = ' num2str(periodmov(iPeriod))])
 
%  
%  figure
%   for iplot = 1:sum(N2)
%     boundedline(1:length(MovAverageVelocity{iplot}),MovAverageVelocity{iplot}, MovStdVelocity{iplot},'alpha','cmap',rand(1,3))
%   end
%  
%  ylabel('Ave vel 2h')


% figure
%  for iplot = 1:sum(N2)
%      
%      subplot(1,4,1)
%      hold on
%      plot(MOVaverageSpeed{iplot})
%      ylabel('<v> 2h')
%      title(['periodmov = ' num2str(periodmov(iPeriod))])
%      legend(cellfun(@num2str,mat2cell(1:sum(N2),1,ones(1,sum(N2))),'UniformOutput',0))
%      
%      subplot(1,4,2)
%      hold on
%      plot(movA2{iplot})
%      ylabel('A2 2h')
%      title(['periodmov = ' num2str(periodmov(iPeriod))])
%      
%     subplot(1,4,3)
%     hold on
%     plot(MOVaverageSpeed{iplot},movA2{iplot},'o')
%     xlabel('<v> 2h')
%     ylabel('A2 2h')
%     title(['periodmov = ' num2str(periodmov(iPeriod))])
%     
%     subplot(1,4,4)
%     hold on
%     plot(conservationA2,'o')
%     plot(conservationSpeed,'o')
%     legend('conserv A2','conserv V')
%     title(['periodmov = ' num2str(periodmov(iPeriod))])
%  end
 


%clear  MovAverageVelocity MovStdVelocity MovMaxVelocity velocity vx vy averageVelocity stdVelocity lengthTrack conservationA2  conservationV
end
%figure des moyennes
