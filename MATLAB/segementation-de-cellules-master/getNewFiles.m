function [newFileNames, rawDir] = getNewFiles(dname)
 
persistent doneFiles dataDir

if isempty(doneFiles)
    doneFiles = {''};
end

newFileNames = []; % Default output
rawDir       = dataDir;

currentList = dir(fullfile(dname,'*.TIF*'));

msk = ~ismember({currentList(:).name},doneFiles);

newDates = {currentList(msk).date};
newFiles = {currentList(msk).name};

% Create rawData folder
if isempty(dataDir)
    dataDir = fullfile(dname,'rawData');
    mkdir(dataDir);
    rawDir = dataDir;
end

if isempty(newFiles), return, end

% Compute new names, including path
newFileNames   = fullfile(dataDir,cellfun(@renameFile,newFiles,'UniformOutput',false));
thisDoneFiles = {''};

for k = 1:numel(newFiles)

%     if seconds(datetime - datetime(newDates{k})) < 60
%         errString = [mfilename ': Skipping moving a file that is too new: ' newFiles{k}];
%         logit(dname,errString);
%       continue
%     end

    disp(logit(dname,['Moving: ' newFiles{k} ' to ' newFileNames{k}]))
    
    try    
        im   = imread(fullfile(dname,newFiles{k}));
        imMt = im2uint8(mat2gray(im)); 
        imwrite(imMt,newFileNames{k});
        
        while ~exist(newFileNames{k},'file')
            pause(0.05)
            disp('getNewFiles: Waiting while file is moving')
        end
        
        delete(fullfile(dname,newFiles{k}))
        
    catch exception
        disp(reportException(dname, exception))
        continue
    end
    
    % Add successfully moved files to the list
    thisDoneFiles = [thisDoneFiles; newFiles{k}];
    
end

% Updates doneFiles
doneFiles = unique([doneFiles;thisDoneFiles]);
doneFiles = doneFiles(~logical(cellfun(@isempty,doneFiles)));

end

