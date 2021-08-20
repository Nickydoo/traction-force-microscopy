%JM 2013
%http://www.biophotonics.ca

function oPos = convertDetectionFromDanuser(movieInfo)
% Converts the positions in movieInfo, in u-track fromat, to a plain list of
% coordinates and times [x, y, t];
%
%INPUT FORMAT
% movieInfo    : Array of size equal to the number of frames in a
%                      movie, containing at least the fields:
%             .xCoord      : x-coordinates of detected features. 
%                            1st column: value, 2nd column: standard
%                            deviation (zeros if not available).
%             .yCoord      : y-coordinates of detected features.
%                            1st column: value, 2nd column: standard
%                            deviation (zeros if not available).
%             .zCoord      : z-coordinates of detected features.
%                            1st column: value, 2nd column: standard
%                            deviation (zeros if not available).
%                            Optional. Skipped if problem is 2D. Default: zeros.
%             .amp         : "Intensities" of detected features.
%                            1st column: values (ones if not available),
%                            2nd column: standard deviation (zeros if not
%                            available).

oPos = [];

for k=1:numel(movieInfo)
    
    x = movieInfo(k).xCoord(:,1);
    y = movieInfo(k).yCoord(:,1);
    
    sizeX = length(x);
    sizeY = length(y);

    if (sizeX ~= sizeY)
        
        sizeAll = min(sizeX, sizeY);
        x = x(1:sizeAll); 
        y = y(1:sizeAll); 
        
        warning(['Uncompatible sizes at Frame ' num2str(k)])
        
    end
    
    t = ones(size(x)) * k;
    
    oPos = [oPos; [x, y, t]];
    
end

end

%~~~ this is the end ~~~ my only friend, the end.