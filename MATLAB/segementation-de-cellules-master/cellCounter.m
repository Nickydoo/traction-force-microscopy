%cell counter
clear
folder = '\\AXOTOM\work\Nicolas\20190914-3.1-controle-dishscan';
files=dir(folder);
imagesFileNames = regexp({files(:).name}','\w*.tif','match');
imagesFileNames = [imagesFileNames{:}];

Areas = [];
count = [4:7 13:19 22:30 32:40 42:50 52:60]; 
for idx = 1:numel(imagesFileNames)
disp( [num2str(idx) ' images on ' num2str(numel(imagesFileNames))])
    I = mat2gray(imread(fullfile(folder,imagesFileNames{idx})));
    [mask, cellStats] = segmentDarkField(I, 250);
    Isave = cat(3,uint8((2^8-1)*mask),uint8((2^8-1)*I),uint8((2^8-1)*I));
    %imshow(Isave)
    %imwrite(Isave,fullfile(folder,['results-' imagesFileNames{idx}]))
    Areas = [Areas;cellStats.Area];
    coverage(idx) = sum(cellStats.Area)/prod(size(I)) ;
end

count = [4:7 13:19 22:30 32:40 42:50 52:60]; 
numCell = length(Areas);
totalCoverage = mean(coverage);