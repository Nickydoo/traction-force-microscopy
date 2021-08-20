function imOut = insertLineND(imIn,xy,color,linewidth)

%insertText(im,singleLineSlow(1:2),sprintf('1) %0.5g',dmaxPos),'TextColor','red','FontSize',fontsize,'BoxOpacity',0)
if nargin == 0
    load('clown.mat'); 
    imIn = uint8(255*ind2rgb(X,map));
    linewidth = 3;
    xy = 1:1000;
    color = 'r';
end


hf = figure('units','pixels','visible','off','Position',[0 0 size(imIn,2) size(imIn,1)]);
axes('Units', 'normalized', 'Position', [0 0 1 1])
imshow(imIn)

for idx = 1:numel(xy)
n = 1:length(xy{idx})/2;
x = xy{idx}(2*n-1);
y = xy{idx}(2*n);
line(x,y,'LineWidth',linewidth,'Color',color)
end

imOut = print('-RGBImage');

close(hf)
figure;imshow(imOut)