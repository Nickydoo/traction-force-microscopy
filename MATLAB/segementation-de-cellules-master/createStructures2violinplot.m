function [categories,dmax,velNorm,velocidad] = createStructures2violinplot(folders,samples);

if nargin==0
    %folders = {'C:\Users\Nicolas\Dropbox (Biophotonics)\Backup Axotom\20190930-3-3.1-3.1c-3.1.1'};
    folders = {'C:\Users\Nicolas\Dropbox (Biophotonics)\Backup Axotom\20190918-3-tgfb'};
    samples = {'3','3-TGFb'};
end

iStruct = 1;
dmax = [];
categories = [];
velNorm = [];
velocidad = [];

for ixf = 1:numel(folders)
    clear settings
    run(fullfile(folders{ixf},'movieSettings.m'))
    
    if exist(fullfile(folders{ixf},'results.mat'))
        clear results
        load(fullfile(folders{ixf},'results.mat'))
    elseif not(exist(fullfile(folders{ixf},'results.mat')))
        clear results
        load(fullfile(folders{ixf},'Track0','trackFilterResults.mat'))
        for iS = 1:numel({settings.sampleName})
            tracksDescriptorsTOT = cat(1,tracksDescriptors{settings(iS).frameNum(1):settings(iS).frameNum(2)});
            results(iS).name = settings(iS).sampleName;
            results(iS).dmax = tracksDescriptorsTOT(:,4);
            results(iS).velNorm = tracksDescriptorsTOT(:,6);
            results(iS).velocidad = tracksDescriptorsTOT(:,3);
        end
%         save(fullfile(folders{ixf},'results.mat'),'results');
    end

        for iRes = 1:numel(results)
            if sum(strcmp(results(iRes).name,samples))
                d = unique({settings.date});
                d = d{1};
                categories = cat(1,categories, repmat({[results(iRes).name '-' d]},size(results(iRes).dmax)));
                dmax = cat(1,dmax,results(iRes).dmax);
                velNorm = cat(1,velNorm,results(iRes).velNorm);
                velocidad = cat(1,velocidad,results(iRes).velocidad);
                iStruct = iStruct+1;
            end
        end        
end

%violinplot(dmax,categories)