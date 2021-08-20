inputFolder='/Volumes/users/Joannie/2016/04_2016/05Apr2016/E001290316_syncD7/';
outputFolder='/Users/santiago/Documents/Projects/Joannie/Cancer/Images/Movie5/';

filesList=dir([inputFolder '*.tif']);

for it=1:size(filesList,1)
    
    thisImage16=double(imread([inputFolder filesList(it).name]));
    
    thisImage8=uint8(thisImage16/65535*255);
    
    imwrite(thisImage8, [outputFolder filesList(it).name], 'jpg')
end