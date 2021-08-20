%movieSettings

settings(1).sampleName = '3';
settings(1).date = '20191105';
settings(1).thisIsForControle = false; %captures all the cells
settings(1).captureFastCells = true;
if settings(1).captureFastCells
    settings(1).pSpeed = 95; %5 for slow, 95 for fast
else
    settings(1).pSpeed = 5; %5 for slow, 95 for fast
end
settings(1).nSorting = 0; %-1 = controle    0 = parental    1,2,3,4=n tri