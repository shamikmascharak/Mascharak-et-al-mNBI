%% Detecting Oropharyngeal Carcinoma using Multispectral, Narrow-Band Imaging and Machine-Learning
% Shamik Mascharak, Brandon J. Baird, F. Christopher Holsinger
% October 30th, 2017
%% Load training images and generate training set (open "Training Images" folder)

clear
clc
close all

% Get list of all PNG files in the directory
imagefiles = dir('*.png');
nfiles = length(imagefiles);
training_images = {};
target_class = {};

% Read in training images
for i = 1:nfiles
    currentfilename = imagefiles(i).name;
    currentimage = imread(currentfilename);
    training_images{i} = currentimage;
    
    if contains(currentfilename,'H') == 0 % i.e., if image is tumor
        target_class{i} = 'Tumor';
    end
    if contains(currentfilename,'H') == 1 % i.e., if image is healthy
        target_class{i} = 'Normal';
    end
end

target_class = target_class';

nClust = 1; % 1 GMM cluster
%reshaper = 3; % Set to 3 if texture values included; otherwise set to 2
reshaper = 2; % Set to 3 if texture values included; otherwise set to 2
training = {};

% Gather color (a,b) and texture (J) values from training images
for i = 1:length(training_images)
    img = training_images{i};
    %[ab,txtr,data] = convert2lab(img,0,0,1); % Set last value to 1 to include texture
    [ab,txtr,data] = convert2lab(img,0,0,0); % Set last value to 1 to include texture
    label = labclust(img,data,nClust,0,0);
    [clustered,centers,spreads] = clustparam(data,label,nClust);
    training{i} = reshape([centers{:}],1,nClust*reshaper);
end

training = cell2mat(training');

sprintf('Done!')

%% Naive Bayes Classification (open "Test Images" folder)

clc

% Get list of all PNG files in the directory
imagefiles = dir('*.png');
nfiles = length(imagefiles);
image_names = {};
test_images = {}; 

predictions = {};
stored_test = {};

% Read in test images 
for i = 1:nfiles
    currentfilename = imagefiles(i).name;
    image_names{i} = currentfilename;
    currentimage = imread(currentfilename);
    test_images{i} = currentimage;
end

progress = 0;
detected = zeros(1,nfiles);
actual = {};
stored_posterior = zeros(nfiles,2);

true_pos = 0;
false_pos = 0;

true_neg = 0;
false_neg = 0;

% Gather color (a,b) and texture (J) values for each test image. Then,
% classify by NB or LDA and assign as true/false positive or negative. 
for i = 1:nfiles
    img = test_images{i};
    img_name = image_names{i};
    %[ab,txtr,data] = convert2lab(img,0,0,1); % Set last value to 1 to include texture
    [ab,txtr,data] = convert2lab(img,0,0,0); % Set last value to 1 to include texture
    label = labclust(img,data,nClust,0,0);
    [clustered,centers,spreads] = clustparam(data,label,nClust);
    test = reshape([centers{:}],1,nClust*reshaper); 
    stored_test{i} = test;
    
    [class, err, posterior, logp, coeff]  = classify(test,training,target_class,'diagLinear'); % NB Classification

    stored_posterior(i,:) = posterior;
    predictions{i} = class;
    
    if strcmp(class,'Tumor') == 1 % If machine learning classifies as tumor
        
        detected(1,i) = 1;
        
        if contains(img_name,'H') == 0 % If image is actually tumor
            actual{i} = 'Tumor';
            true_pos = true_pos + 1; % Then this is a true positive
        end
        if contains(img_name,'H') == 1 % If image is actually healthy
            actual{i} = 'Normal';
            false_pos = false_pos + 1; % Then this is a false positive
        end
        
    end
    
    if strcmp(class,'Normal') == 1 % If machine learning classifies as healthy
        
        if contains(img_name,'H') == 0 % If image is actually tumor
            actual{i} = 'Tumor';
            false_neg = false_neg + 1; % Then this is a false negative
        end
        if contains(img_name,'H') == 1 % If image actually healthy
            actual{i} = 'Normal';
            true_neg = true_neg + 1; % Then this is a true negative
        end
        
    end
    
    % Display the % progress
    progress = progress + 1;
    percent_complete = 100*(progress/nfiles)
    
end

actual = actual';
predictions = predictions';
stored_test = cell2mat(stored_test');

clc

sensitivity = true_pos/(true_pos + false_neg)
specificity = true_neg/(true_neg + false_pos)
accuracy = (true_pos + true_neg)/(true_pos + false_pos + true_neg + false_neg)
PPV = true_pos/(true_pos + false_pos)
NPV = true_neg/(true_neg + false_neg)

% Calculate ROC metrics
[x,y,t,AUC] = perfcurve(actual,stored_posterior(:,2),'Tumor');
