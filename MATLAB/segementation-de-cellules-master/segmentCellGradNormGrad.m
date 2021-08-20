
function [maskOut, cellStats] = segmentCellGradNormGrad(I,minObjectSize);
%1. créer un mask avec filtre std + grad et treshold
%2. active contour 

%% pour le test
I = mat2gray(I); %normalisation
Imedian = medfilt2(I,[15 15]);

%% ATTENTION LE 
    
    %filtre médian du background
    GRAD_tmp = mat2gray(imgradient(I,'prewitt'));
    maskGRADglobal   = imbinarize(GRAD_tmp, 'global');
    maskBackNorm = imclose(maskGRADglobal, strel('disk', 20));
    maskBackNorm = bwareaopen(maskBackNorm,250);
    
    IBackNorm = I.*maskBackNorm + Imedian.*(~maskBackNorm);
    
    %détecter les contours
    sensitivity = 0;
    GRAD = mat2gray(imgradient(IBackNorm,'prewitt'));
    
    %binarisation et imclose
    maskGRADadapt   = imbinarize(GRAD, 'adaptive','sensitivity',sensitivity);
    maskGRADadapt = maskGRADadapt.*maskBackNorm;
    maskGRADadapt = imfill(maskGRADadapt,'holes');
    maskOut=bwareaopen(maskGRADadapt, minObjectSize);
    cellStats=struct2table(regionprops(maskOut, 'Area', 'Centroid'));
%%
% contours = bwperim(maskGRADadapt);
%cellStats = regionprops('table', maskGRADadapt, 'Area', 'Centroid','Eccentricity','Orientation','PixelIdxList');
% Xout = cellStats.Centroid(:,1);
% Yout = cellStats.Centroid(:,2);
% %Iout = cat(3,I,contours,zeros(size(I)));
% Iout = I+contours;
end