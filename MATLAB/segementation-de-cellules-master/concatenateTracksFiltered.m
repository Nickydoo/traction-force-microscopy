function [tracks,N2] = concatenateTracksFiltered(imagesFolder, ttotal, tmin, dt) 

%% test
if nargin == 0
    %imagesFolder = 'C:\Users\Nicolas\Dropbox (Biophotonics)\Backup Axotom\20190710_2.3';
    imagesFolder = 'P:\Desktop\Dropbox (Biophotonics)\Backup Axotom\20190710_2.3';
    ttotal = 2;
    tmin = 1.5;
    dt = 2/60;
end

%% main 
info = dir(imagesFolder);
numPositions = sum(contains({info.name},'Results'));
nt = tmin/dt + 1; %nombre de frames pour la période d'intérêt
nttotal = ttotal/dt + 1; %nombre de frames pour le film total
idxNT = 1:nttotal;
resultsFolder = cell(numPositions);
tracks_tmp = cell(numPositions);
load(fullfile(imagesFolder,['Track' num2str(0)],'trackFilterResults.mat'));
    
    for iPos = 1:numPositions

            tracks_tmp{iPos} = tracks{iPos};
            N1(iPos) = tracks_tmp{iPos}(end,end); %nombre de tracks initiale
            list1 = 1:N1(iPos);
            L{iPos} = sum(tracks_tmp{iPos}(:,end) == list1,1)'; %longueur des tracks
            %tracks{iPos} = tracks_tmp.tracksuT;

            selectPos1 = L{iPos}>nt; %tracks plus longue
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

    % créer une seule matrice pour tracks
    tracks = tracksCellArray{1};
    for iMatrix = 2:length(tracksCellArray)
        if isnumeric(tracksCellArray{iMatrix})
        tracks = [tracks ; tracksCellArray{iMatrix}];
        end   
    end
end