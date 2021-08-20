% Analyse du 15Janvier des MDA-231-MB avec WGA pour voir si on peut
% segmenter pour pouvoir CLaPer selon la taille

clear, clc, close all
%% Change to 8 bit
%inputFolder = 'D:\Dropbox (Biophotonics)\ResultatsProjets\AnalysePourLoic';
%inputFolder = uigetdir('home/joannie/', 'Select result folder');
inputFolder = uigetdir('D:\work\loic\joannies cancer\');
outputFolder = [inputFolder filesep 'Images8bit\'];
mkdir(outputFolder)

filesList=dir([inputFolder filesep '*.TIF']);

for it=1:size(filesList,1)
    illuProfile = double(imread([inputFolder filesep 'illu' filesep 'illu.TIF']));
    im = imread([inputFolder filesep filesList(it).name]);
    imCorr = illuminationProfile(im, illuProfile); 
    thisImage16 = double(imCorr);
    %thisImage16 = double(imread([inputFolder filesep filesList(it).name]));
    thisImage8=uint8(thisImage16/65535*255);
    imwrite(thisImage8, [outputFolder filesList(it).name], 'TIF')
end

%%

filesList=dir([outputFolder '*.TIF']);

minObjectSize = 350;
maxcutoff     = 3000;

for it=1:size(filesList,1)
    
myImage = imread([outputFolder filesList(it).name]);

mask0    = imopen(myImage,strel('disk',8));
th       = graythresh(mask0(:)); % the threshold is calculated on an opened image
mask1    = im2bw(myImage, th);   % use the threshold on the original image

mask2    = imdilate(mask1,strel('disk',2)); % fills the inner holes
mask3    = bwareaopen(mask2, 100);  % get ride of small objects
mask4    = mask3;

% get ride of big objects and small&non-solid objects
cellStats_Cl = regionprops(mask3,'Area', 'Centroid', 'PixelIdxList', 'ConvexImage', 'Solidity');
aire = cellStats_Cl.Area;
tableCellStat = struct2table(cellStats_Cl);
        
for itCell=1:size(tableCellStat, 1)
    %if tableCellStat.Area(itCell)>5*mean(aire)
    if tableCellStat.Area(itCell)>maxcutoff
        mask4(tableCellStat.PixelIdxList{itCell})=0;
    end
    if tableCellStat.Area(itCell)<850 && tableCellStat.Solidity(itCell)<0.7 
        mask4(tableCellStat.PixelIdxList{itCell})=0;
    end
end
mask5 = mask4;

% split merged cells
  for itCell=1:size(tableCellStat, 1)
%        if tableCellStat.Solidity(itCell) < 0.85 && tableCellStat.Area(itCell)<5*mean(tableCellStat.Area) && tableCellStat.Area(itCell) > 15*minObjectSize
         if tableCellStat.Solidity(itCell) < 0.85 && tableCellStat.Area(itCell)<maxcutoff && tableCellStat.Area(itCell) > 1500
            gluedCells=zeros(size(myImage));
            gluedCells(tableCellStat.PixelIdxList{itCell})=1;
            myDist=-(bwdist(~gluedCells));
            %k = round(tableCellStat.Area(itCell)/10/minObjectSize);
            %k = round(tableCellStat.Area(itCell)/median(tableCellStat.Area));
            %k = round(tableCellStat.Area(itCell)/5/minObjectSize);
            k = round(tableCellStat.Area(itCell)/1500);
            if k > 1 && k <6
                cellKMeansCentroids=getCellCentroidsKmeans(gluedCells, myImage,k);
                centroidsImage=zeros(size(myImage));
                centroidsImage(sub2ind(size(myImage), round(cellKMeansCentroids(:,1)), round(cellKMeansCentroids(:,2))))=1;
                myDistExtMinima=imimposemin(myDist, imdilate(centroidsImage, strel('disk', 5)));
                wshTheseCells = watershed(myDistExtMinima);
                %wshTheseCells = watershed(myDist);
                gluedCells(wshTheseCells==0)=0;
            end
            mask5(tableCellStat.PixelIdxList{itCell})=gluedCells(tableCellStat.PixelIdxList{itCell});
        end
    end
   
mask6=bwareaopen(mask5, minObjectSize);
cellStats = regionprops(mask6, 'Area', 'Centroid', 'PixelIdxList', 'Solidity', 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength');
table = struct2table(cellStats);
        
% Save the object satistics for this image
%save(fullfile(outputFolder,['dataImage' thisTime{:} '.mat']), 'cellStats'); 
save(fullfile(outputFolder,['dataImage' filesList(it).name '.mat']), 'table'); 

% Get contours
%maskContours = mask6 - imerode(mask6, strel('disk', 3)); 
maskContours = mask6 - imerode(mask6, strel('disk', 2)); 
maskContours = maskContours*255;

% save a segmented image
imOut = myImage+uint8(maskContours);
%imwrite(imOut, [outputFolder 'seg' filesList(it).name], 'TIF')

% save a segmented image
%imwrite(imfuse(myImage, maskContours, 'blend'),fullfile(resultsFolder,['Seg' thisTime{:} '.jpg']), 'jpg'); 

%% I now need to make an histogram of different parameters. Color code
% accorgind to percentile. 

% size percentile. I will make 3 masks. 
maskS = imOut;
maskM = imOut;
maskL = imOut;

for itCell=1:size(table, 1)
    if table.Area(itCell)>prctile(table.Area,33)%33 is kept. 34 is erased
        maskS(table.PixelIdxList{itCell})=0;
    end
end

for itCell=1:size(table, 1)
    if table.Area(itCell)<prctile(table.Area,34)%33 is erased 34 is kept
        maskM(table.PixelIdxList{itCell})=0;
    end
    if table.Area(itCell)>prctile(table.Area,66)%66 kept 67 erased
        maskM(table.PixelIdxList{itCell})=0;
    end
end

for itCell=1:size(table, 1)
    if table.Area(itCell)<prctile(table.Area,67) %66 erased 67 kept
        maskL(table.PixelIdxList{itCell})=0;
    end
end

%% Nice colorful montage
maskRGB = cat(3,maskS, maskM, maskL);
imwrite(maskRGB, [outputFolder 'RGB' filesList(it).name], 'TIF')

%% I now need to make an histogram of different parameters. Color code
% accorgind to percentile. 

% size percentile. I will make 3 masks. 
maskR = imOut;% round
maskN = imOut;% normal
maskE = imOut;% elongated

for itCell=1:size(table, 1)
    if table.Eccentricity(itCell)>prctile(table.Eccentricity,33)
        maskR(table.PixelIdxList{itCell})=0;
    end
end

for itCell=1:size(table, 1)
    if table.Eccentricity(itCell)<prctile(table.Eccentricity,34)
        maskN(table.PixelIdxList{itCell})=0;
    end
    if table.Eccentricity(itCell)>prctile(table.Eccentricity,66)
        maskN(table.PixelIdxList{itCell})=0;
    end
end

for itCell=1:size(table, 1)
    if table.Eccentricity(itCell)<prctile(table.Eccentricity,67)
        maskE(table.PixelIdxList{itCell})=0;
    end
end

%% Nice colorful montage
%maskRGBecc = cat(3,maskR, maskN, maskE);
maskRGBecc = cat(3,maskR+100, maskN, maskE);
imwrite(maskRGBecc, [outputFolder 'ecc' filesList(it).name], 'TIF')

end

