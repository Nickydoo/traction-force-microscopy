%create mask
function maskOut = createStimulationMask

size = [1608 1608];
n = 3; %nombre de points
calibration10x = 1.099; %um/px

mask = false(size);

for idx = 1:n
    line = round(rand(1,1)*size(1));
    col = round(rand(1,1)*size(2));
    CenterX(idx,1) = round((col-1)*calibration10x,2,'decimals');
    CenterY(idx,1) = round((line-1)*calibration10x,2,'decimals');
    mask(line,col) = true;
end

%imwrite(mask,'mask3pts.tif')

% varnames = {'CentreX','CentreY'};
% T = table(CenterX,CenterY,'VariableNames',varnames);
% 
% writetable(T,'positions.txt','Delimiter','tab')

maskOut = mask;
