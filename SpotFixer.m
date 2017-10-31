function [rgbImage] = SpotFixer(img)

rgbImage = img;

% Get the dimensions of the image.  numberOfColorBands should be = 3.
[rows, columns, numberOfColorBands] = size(rgbImage);

% Convert to gray scale.
grayImage = rgb2gray(rgbImage);

% Threshold to get binary image
binaryImage = grayImage > 225;

% Dilate the binary image to tell it what pixels should be used to fill in holes.
binaryImage = imdilate(binaryImage, true(11));

% Extract the individual red, green, and blue color channels.
redChannel = rgbImage(:, :, 1);
greenChannel = rgbImage(:, :, 2);
blueChannel = rgbImage(:, :, 3);
% Fill holes
redChannel = roifill(redChannel, binaryImage);
greenChannel = roifill(greenChannel, binaryImage);
blueChannel = roifill(blueChannel, binaryImage);

% Recombine separate color channels into a single, true color RGB image.
rgbImage = cat(3, redChannel, greenChannel, blueChannel);
