function makeGIF(myFolder, pos, 

for pos = 4:18
    myFolder = ['\\AXOTOM\work\Nicolas\20190321no3\Results' num2str(pos) '\'];
    myFiles = dir([myFolder '*.jpg']);
    filename = ['Results' num2str(pos) '.gif'];
    
    for idx = 1:numel(myFiles)
        im = imread([myFolder myFiles(idx).name]);
        [A,map] = rgb2ind(im,256);
    if idx == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
    end
    end
end
end