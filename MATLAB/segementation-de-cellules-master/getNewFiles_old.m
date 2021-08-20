function newFileNames = getNewFiles(dname)

persistent lastList;
currentList = dir(fullfile(dname,'*.tif'));
currentList = {currentList(:).name};


newFiles = setdiff(currentList,lastList);

%% Check for Metamorph names
if numel(newFiles)>0
    if strfind(newFiles{1},'_')>0
        newFileNames=renameFiles(newFiles);
        for it=1:numel(newFiles)
            movefile([dname filesep newFiles{it}],[dname filesep newFileNames{it}])
        end
        lastList = [lastList newFileNames];
    else
        lastList = currentList;
        newFileNames=newFiles;
    end
else
    newFileNames=[];
end

%lastList = [lastList newFileNames];

end