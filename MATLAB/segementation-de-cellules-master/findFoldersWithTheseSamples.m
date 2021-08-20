function folders = findFoldersWithTheseSamples(mainFolder,samples,date)

if nargin == 0
%     mainFolder = 'P:\Desktop\Dropbox (Biophotonics)\Backup Axotom';
    mainFolder = 'C:\Users\Nicolas\Dropbox (Biophotonics)\Backup Axotom';
    samples = {'3'};
%     date = '19920305';
date = {};
end

subfolders = dir(mainFolder);
subfolders = fullfile(mainFolder,{subfolders(isfolder(fullfile(mainFolder,{subfolders.name}))).name});

ixF = 1;
folders = {};
for isub = 1 : numel(subfolders)
    if exist(fullfile(subfolders{isub},'movieSettings.m'))
        run(fullfile(subfolders{isub},'movieSettings.m'))
        
        for isample = 1:numel(samples)
            if isempty(date)
                if (  logical(sum(strcmp({settings.sampleName},samples{isample}))) )
                    folders{ixF} =  subfolders{isub};
                    ixF = ixF +1;
                end
            else
                if (  logical(sum(strcmp({settings.sampleName},samples{isample}))) && logical(sum(strcmp(settings(1).date,date)))  )
                    folders{ixF} =  subfolders{isub};
                    ixF = ixF +1;
                end
            end
        end
    end
end
      folders = unique(folders);      
end