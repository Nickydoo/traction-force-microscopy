for itCell=1:size(cellStats_Cl, 1)
        if cellStats_Cl.Solidity(itCell) < 0.85 && cellStats_Cl.Area(itCell)<5*mean(cellStats_Cl.Area)
            gluedCells=zeros(size(imInAd));
            gluedCells(cellStats_Cl.PixelIdxList{itCell})=1;
            myDist=-(bwdist(~gluedCells));
            k = round(cellStats_Cl.Area(itCell)/10/minObjectSize);
            if k == 0
                k = 1;
            end
            cellKMeansCentroids=getCellCentroidsKmeans(gluedCells, imInAd,k);
            centroidsImage=zeros(size(imInAd));
            centroidsImage(sub2ind(size(imInAd), round(cellKMeansCentroids(:,1)), round(cellKMeansCentroids(:,2))))=1;
            myDistExtMinima=imimposemin(myDist, imdilate(centroidsImage, strel('disk', 5)));
            wshTheseCells = watershed(myDistExtMinima);
%             wshTheseCells = watershed(myDist);
            gluedCells(wshTheseCells==0)=0;
            maskClean(cellStats_Cl.PixelIdxList{itCell})=gluedCells(cellStats_Cl.PixelIdxList{itCell});
        end
    end