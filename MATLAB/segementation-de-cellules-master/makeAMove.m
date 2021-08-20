masterFolder = 'C:\Users\Transformer\Dropbox (Biophotonics)\Backup Axotom\20190807_35mm_1.7.2\rawData';
whereToMove = 'C:\Users\Transformer\Dropbox (Biophotonics)\Backup Axotom\20190807_35mm_1.7.2\supplmentary images';
allFiles = dir(masterFolder);
allFilesName = {allFiles.name}';

for idx =62:100
    toMove = {allFilesName{contains(allFilesName,num2str(idx))}}';
    for idx2 = 1:numel(toMove)
        move(fullfile(masterFolder,toMove{idx2}), whereToMove)
    end
end