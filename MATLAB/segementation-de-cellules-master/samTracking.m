stack = tifRead(char("D:\Sam\July 29\Processed\timelapse 40x.nd2 - timelapse 40x.nd2 (series 4).tif_processed.tif"));
depth = size(stack,3);
x = [];
y = [];
time = [];
for i = 1:depth
    beadsimg = stack(:,:,i);
    % beadsimg = medfilt2(mat2gray(stack(:,:,i)));
    %beadsimg = differenceOfGaussians(beadsimg, 1, 10); % Filtering image
    % beadsimg = bpass(beadsimg, 1, 10);
    pkfnd_out = pkfnd(beadsimg, prctile(beadsimg, 99.9), 5);
    cnt = cntrd(beadsimg, pkfnd_out, 3,0);
    beadsx = cnt(:, 1);
    beadsy = cnt(:, 2);
    imshow(mat2gray(beadsimg))
    hold on
    plot(beadsx, beadsy, 'r.')
    hold off
    drawnow;
    % pause(1)
    t = ones(length(cnt), 1).*i;
    x = [x ;beadsx];
    y = [y ;beadsy];
    time = [time; t];
end

data = [x y time];