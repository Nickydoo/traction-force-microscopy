function [imOut, cellStats]=segmentSingleImageUsingCenters(varargin)
% Segment cells in a transmission microscopy image
% Argiments are [imOut, cellStats]=segmentSingleImageUsingCenters(varargin)
% 1 imIn, the image to segment
% 2 minObjectSize, objects smaller than this will be discarded
% 3 centersImage impose cell centers on this mask
% 4 gammaValue, gamma value for imadjust

if nargin==1
    imIn=varargin{1}; 
    minObjectSize=10; 
    gammaValue=1;
else
    imIn=varargin{1}; 
    minObjectSize=varargin{2};
    if length(varargin{3})~=0;
        centersImage=varargin{3}; 
    end
    gammaValue=varargin{4}; 
end

%% Detect edge
imIn=imadjust(imIn, [],[], gammaValue);
bkgdThisImage=imopen(imIn,strel('disk',8));
testImage=double(imIn-bkgdThisImage);
test8=uint8(testImage/max(max(testImage))*255);

%% Morphology operations
thresh = graythresh(test8);
mask0=im2bw(test8, thresh);
%mask0=imbinarize(test8, 'adaptive');
mask1=bwareaopen(mask0, 20);
mask2=imclose(mask1, strel('disk', 5));
mask2=imfill(mask2, 'holes');

%% Watershed
D = -bwdist(~mask2);
mask4 = imextendedmin(D,2);

if length(varargin{3})==0;
    centersImage=imextendedmin(D,2);
end
    
D2 = imimposemin(D, centersImage);
Ld2 = watershed(D2);
mask2(Ld2 == 0) = 0;

imOut=bwareaopen(mask2, minObjectSize);
cellStats=struct2table(regionprops(imOut, 'Area', 'Centroid', 'PixelIdxList'));