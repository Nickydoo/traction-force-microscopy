function [imOut, cellStats]=segmentSingleImage(imIn, minObjectSize)

    bkgdThisImage=imopen(imIn,strel('disk',8));
    testImage=imIn-bkgdThisImage;
    test8=uint8(testImage/max(max(testImage))*255);

    
    %% Old School
    mask0=im2bw(imadjust(test8), graythresh(imadjust(test8)));
    mask1=bwareaopen(mask0, 20);
    mask2=imclose(mask1, strel('disk', 5));
    D = -bwdist(~mask2);
    mask4 = imextendedmin(D,2);
    D2 = imimposemin(D,mask4);
    Ld2 = watershed(D2);
    mask2(Ld2 == 0) = 0;
    imOut=bwareaopen(mask2, minObjectSize);
    cellStats=struct2table(regionprops(imOut, 'Area', 'Centroid', 'PixelIdxList'));
end