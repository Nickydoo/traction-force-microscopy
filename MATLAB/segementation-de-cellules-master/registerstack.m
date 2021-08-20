function registered_stack = registerstack(stack)
% optimizer = registration.optimizer.RegularStepGradientDescent;
% metric= registration.metric.MeanSquares;
depth = size(stack, 3);
xsize = size(stack, 1);
ysize = size(stack, 2);
registered_stack = zeros(xsize, ysize, depth);
registered_stack(:, :, 1) = stack(:, :,1);
for i = 2:depth
    fprintf('Registering image #%d\n', i);
%     registered_stack(:, :, i) = imregister(stack(:,:,i), stack(:,:,i-1), "translation", optimizer, metric);
    [~, fftimg] = dftregistration(fft2(stack(:,:,i)), fft2(stack(:,:,i-1)), 1);
    regimg = real(ifft2(fftimg));
    registered_stack(:, :, i) = regimg;
end

