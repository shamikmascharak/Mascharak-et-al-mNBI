function [ab, txtr, data] = convert2lab(img,option1,option2,option3)
%% Convert RGB to CIE L*a*b
% option1 = 1 -> Display a*b*texture surface plot
% option2 = 1 -> Display a*b*texture scatter plot
% option3 = 1 -> Include texture values in data

% Remove bright spots
img = SpotFixer(img);

% Convert image to L*a*b form, where L is luminosity, a is red-green
% position, and b is blue-yellow position. 
cform = makecform('srgb2lab');
lab_img = applycform(img,cform);
ab = double(lab_img(1:end,1:end,2:3));

% Calculate entropy value in 5-by-5 neighborhoods
J = entropyfilt(lab_img(1:end,1:end,1),true(5));
txtr = double(J(1:end,1:end));

% If user wants to display a*b*texture surface plot
if option1 == 1
    figure
    surf(ab(:,:,1),ab(:,:,2),txtr)
end

nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
txtr = reshape(txtr,nrows*ncols,1); 

% If user wants to display a*b*scatter plot (Figure 2)
if option2 == 1
    figure
    scatter3(ab(:,1),ab(:,2),txtr)
end

% If user wants to include texture values in the classification model
if option3 == 1
    data = [ab';txtr'];
else data = ab';
end

% Output the color (ab) and texture (txtr) information
ab = ab';
txtr = txtr';
