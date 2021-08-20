%  buildNnMap: BUILD NEAREST NEIGHBOR MAP
%
% Builds the function Dphy(x,y) = mmMap used to obtain the maxDisp function
% usded in trackAdaptive.m

% Parameters:
%  inPos: Detected positions of particles
%  imsz: 2D array containing the size of each image frame
%  avgSz: Size in pixels of the circular neighborhood used to average
%        maxDisp map.
%
% -------------------------------------------------------------------------
% Copyright (C) 2014 Javier Mazzaferri
% javier.mazzaferri@gmail.com
% Centre de Recherche, Hopital Maisonneuve-Rosemont
% www.biophotonics.ca
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function nnMap = buildNnMap(inPos,xysz,avgSz)

nnSum = zeros(xysz);
nnNum = zeros(xysz);

ts = unique(inPos(:,3));

%Add linear index column
ixc = sub2ind(xysz,round(inPos(:,2)),round(inPos(:,1))); 
inPos = [inPos, ixc];

%At each frame, for each position, computes the distance to the nearest
%neighbor
for k = 2:numel(ts)
    
    % Particle locations in CURRENT frame
    cPos = inPos(inPos(:,3) == ts(k),:); 
 
    if size(cPos,1) < 2, continue, end
    
    for c = 1:size(cPos,1)

        %Get nearest neighbours list
        nn = sqrt((cPos(:,1) - cPos(c,1)).^2 + (cPos(:,2) - cPos(c,2)).^2); 
        %Get rid of selfdistance
        nn(c) = []; 
        
        %Add the nnDistance to the sum
        nnSum(cPos(c,4)) = nnSum(cPos(c,4)) + min(nn); 
        %Increment the count
        nnNum(cPos(c,4)) = nnNum(cPos(c,4)) + 1;       
        
    end
    
end

%Compute the space-time average

%Builds circular mask for scanning sums
h = fspecial('disk', fix(avgSz/2) + 1);
%Make it 1 or 0
h(h(:)>0) = 1;

%Compute scanning sum
nnSum = filter2(h,nnSum,'same');
%Compute scanning number of entries
nnNum = filter2(h,nnNum,'same');

msk = nnNum ~= 0;

nnMap = inf(xysz(1:2));
nnMap(msk) = nnSum(msk) ./ nnNum(msk);

end