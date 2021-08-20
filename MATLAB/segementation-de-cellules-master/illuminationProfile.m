function [imCorrected] = illuminationProfile(im, myIlluProfile) 
% The concept is to find the maximum intensity in the illumination profile.
% Then, for each position in the matrix, deviding the max by the value of this
% position. This matrix of ratio is multiplied by the image to be adjusted. 

%% analysis of the Illumination Profile
newIlluProfile = double(myIlluProfile);
[m, ix]        = (max(newIlluProfile(:)));
[col, row]     = ind2sub(size(newIlluProfile), ix);
b              = m./newIlluProfile;
mask           = newIlluProfile==0;
c              = newIlluProfile.*b; %proof of concept. This should be completely saturated

%% applying analysis to im
myImage        = im;
myImage        = double(myImage);
newImage       = b.*myImage;
newImage(mask) = 0;
imCorrected    = uint16(newImage);



