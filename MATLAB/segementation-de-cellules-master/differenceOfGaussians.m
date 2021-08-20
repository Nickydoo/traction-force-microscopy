function img = differenceOfGaussians(origimg,low_sigma, high_sigma)
%DIFFERENCEOFGAUSSIANS Summary of this function goes here
%   Detailed explanation goes here
im1 = imgaussfilt(origimg, low_sigma);
im2 = imgaussfilt(origimg, high_sigma);
img = im1 - im2;
end

