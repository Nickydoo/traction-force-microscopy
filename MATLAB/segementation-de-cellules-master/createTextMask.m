function tmask = createTextMask(sizeIm,fontsize,theString,position)

if nargin == 0
    % Read example image 
    load('clown.mat'); 
    im = uint8(255*ind2rgb(X,map));
    sizeIm = size(im);
    fontsize = 30;
    theString = 'caca';
    position = [100 100];
end

%%Create the text mask 
% Make an image the same size and put text in it 
hf = figure('color','white','units','normalized','position',[.1 .1 .8 .8],'visible','off'); 
image(ones(sizeIm)); 
set(gca,'units','pixels','position',[1 1 sizeIm(2) sizeIm(1)],'visible','off')
% Text at arbitrary position 
text('units','pixels','position',position,'fontsize',fontsize,'string',theString) 
% Capture the text image 
% Note that the size will have changed by about 1 pixel 
tim = getframe(gca); 
close(hf) 
% Extract the cdata
tim2 = tim.cdata;
% Make a mask with the negative of the text 
tmask = tim2==0; 

%% test the mask
% Place white text 
% Replace mask pixels with UINT8 max 
% im(tmask) = uint8(255); 
% image(im);
% axis off