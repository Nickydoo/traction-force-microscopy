nx = 100;
ny = 100;

sigma = 0.5;

A = 1;

x0 = rand(1,100)*nx;
y0 = rand(1,100)*ny;

[X,Y] = meshgrid(1:nx,1:ny);

gauss = zeros(size(X));
for idx = 1:nx
    gauss = gauss + A*exp(-((X - x0(idx)).^2 + (Y-y0(idx)).^2)./(2*sigma.^2));
end

figure;
imshow(gauss,[])

