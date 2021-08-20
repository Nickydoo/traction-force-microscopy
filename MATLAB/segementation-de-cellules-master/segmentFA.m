function [lap] = segmentFA(Iin,FAwidth)
%% testing
if not(nargin)
    folder = 'C:\Users\Nicolas\Dropbox (Biophotonics)\Nicolas\Confocal\FA quantification\fast 6 avril\a647_005';
    name = 'maxProjection.tif';
    Iin = imread(fullfile(folder,name));
end

% FAwidth = 3;
% lamellipodiaWidth = 7;

% disk = strel('disk',lamellipodiaWidth);
% disk = disk.Neighborhood;

Iin = mat2gray(Iin);
% Ismooth = imgaussfilt(Iin,3);
denoisedIm=medfilt2(Iin);

kernel = fspecial('log',3*FAwidth*[1 1],FAwidth/2);
lap = -conv2(Iin,kernel,'same');
lap(lap<0) = 0;

% Itophat = mat2gray(imtophat(Ismooth,strel('disk',round(FAwidth))));
% % Itophat = Iin - Ismooth;
contrastMask = mat2gray(imgaussfilt(stdfilt(denoisedIm),4*FAwidth));
% 
% maskedIm = Itophat.*contrastMask;

% mask = imbinarize(mat2gray(maskedIm));
% mask = bwareaopen(mask,5);
% mask = imfill(mask,'holes');

maskedIm = contrastMask.*lap;
mask = imbinarize(mat2gray(maskedIm));
mask = bwareaopen(mask,3);

%  figure;imshow(cat(3,mat2gray(Iin)+0.5*mask,mat2gray(Iin),mat2gray(Iin)))


%%

% figure
% imshow(Ilowpass,[])
% 
% figure
% imshow([Istd, lamellipodiaMask],[])
% 
% figure
% imshow([Iin mask])


% test = cat(3,Iin+mask,Iin,Iin);
% imshow(test)

%%