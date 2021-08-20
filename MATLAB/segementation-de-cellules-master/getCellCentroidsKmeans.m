function outCentroids=getCellCentroidsKmeans(gluedCells, imIn, numCells)

myData=gluedCells.*stdfilt(imIn, ones(5));

%dData=discretize(myData, 10);
edges = min(myData(:)):max(myData(:))/9:max(myData(:)); %v Matlab R2015b
dData = discretize(myData, edges); %v Matlab R2015b

wData=[];

for it=2:10
    [theseX, theseY]=find(dData==it);
    thisDataSet=repmat([theseX, theseY], [it-1 1]);
    wData=[wData; thisDataSet];
end

% opts = statset('Display','final');

[idx,outCentroids] = kmeans(wData,numCells,'Replicates',1);

