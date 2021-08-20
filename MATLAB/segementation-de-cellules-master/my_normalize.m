function img = my_normalize(img)
%MY_NORMALIZE Summary of this function goes here
%   Detailed explanation goes here
img = img - prctile(img, 1);
img = img ./ prctile(img, 99.99);
img(img < 0) = 0.0;
img(img > 1) = 1.0;
end

