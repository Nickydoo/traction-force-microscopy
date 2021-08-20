function [imOut, cellStats]=segmentDarkField(imInMt, minObjectSize)
    %I = adapthisteq(mat2gray(imInMt));
    I = mat2gray(imInMt);
    Imed = medfilt2(I);
    fact = 15;
    Imed = imflatfield(Imed,[size(Imed,1)/fact size(Imed,1)/fact]);
    Imed = imgaussfilt(Imed,2);
    Imed = mat2gray(Imed);
%     Ih = histeq(Imed);
%     low_inH = prctile(Ih,0.1,'all');
%     high_inH = prctile(Ih,99.9,'all');
    low_inM = prctile(Imed,90,'all');
    high_inM = prctile(Imed,99.9,'all');
    %Iad = imadjust(Ih,[low_inH high_inH],[0 1],50);
    Iad = imadjust(Imed,[low_inM high_inM],[0 1],0.5);
    mask = imbinarize(Iad);
    mask = bwareaopen(mask, minObjectSize);
    mask = imfill(mask,'holes');
    imOut=bwareaopen(mask, minObjectSize);
    cellStats=regionprops('table',imOut,Imed, 'Area', 'WeightedCentroid');
    
    % pour le test
%     contour = bwperim(imOut);
%     contour = cat(3,I+contour,I,I);
%     figure(1); imshow(contour)
%     figure(2); imhist(I); title('I')
%     figure(3); imhist(Imed); title('med')
%     %figure(4); imhist(Ih); title('histeq')
%     figure(5); imhist(Iad); title('ad')
end
    