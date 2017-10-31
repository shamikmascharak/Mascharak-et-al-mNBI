function [label] = labclust(img,data,nClust,option1,option2)
%% L*a*b Data Clustering: Gaussian Mixture Model 
% option1 = 1 for Variational Bayesian, otherwise default to EMGM
% option2 = 1 to run it and display segmented images

if option1 == 1
    label = vbgm(data,nClust);
else label = emgm(data,nClust);
end

if option2 == 1
    figure
    spread(data,label)
end

if option2 == 1
    nrows = size(img,1);
    ncols = size(img,2);
    
    % Generate individual colored segments
    pixel_labels = reshape(label,nrows,ncols);
    segmented_images = cell(1,nClust);
    rgb_label = repmat(pixel_labels,[1 1 3]);
   
    % Subplot the segmented images
    figure
    for k = 1:nClust
        color = img;
        color(rgb_label ~= k) = 0;
        segmented_images{k} = color;
        subplot(1,nClust,k)
        subimage(segmented_images{k})
        title(num2str(k))
    end
end
