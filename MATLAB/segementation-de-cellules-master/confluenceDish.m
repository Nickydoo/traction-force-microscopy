%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% title : confluenceDish.m
% author : Nicolas Desjardins-L.
% edition : june 13th 2019
% Description : segment darkfield images of a folder and returns de average
% confluence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Folder = 'P:\Desktop\Dropbox (Biophotonics)\Backup Axotom\dishscan';
files = dir(fullfile(Folder,'*.tif'));

for idx = 1:size(files,1)
    I = imread(fullfile(Folder,files(idx).name));
    [mask,stats] = segmentDarkField(I,250);
    nbPixels = size(I,1)*size(I,2);
    confluence_tmp(idx) = sum(sum(mask))/nbPixels;
end

%%
not = [1:14 24:45 60:76 96:109 132:142 167:175 202:208 237:242 271:274];
yes = [15:23 46:59 77:95 108:131 141:166 174:201 209:236 241:270];

confluence = mean(confluence_tmp(yes));