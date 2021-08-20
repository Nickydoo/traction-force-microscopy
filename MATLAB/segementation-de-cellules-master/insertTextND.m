function imOut = insertLineND(imIn,x,y,txt,color,ftsize)

%insertText(im,singleLineSlow(1:2),sprintf('1) %0.5g',dmaxPos),'TextColor','red','FontSize',fontsize,'BoxOpacity',0)
if nargin == 0
    load('clown.mat'); 
    imIn = uint8(255*ind2rgb(X,map));
    ftsize = 30;
    txt = 'yext';
    position = [100 100];
    x = position(1); y = position(2);
    color = 'r';
end

hf = figure('units','pixels','visible','off','Position',[0 0 size(imIn,2) size(imIn,1)]);
axes('Units', 'normalized', 'Position', [0 0 1 1])
imshow(imIn)
text(x,y,txt,'units','pixels','FontSize',ftsize,'Color',color)

imOut = print('-RGBImage');
close(hf)

% figure;imshow(imOut)