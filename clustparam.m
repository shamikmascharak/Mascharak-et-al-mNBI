function [clustered, centers, spreads] = clustparam(data,label,nClust)
%% Set cluster distribution parameters

% Break up data by GMM labels from emgm.m
clustered = {};
centers = {};
spreads = {};
for i = 1:nClust
    col = find(label == i);
    cluster = data(:,col);
    clustered{i} = cluster;
    centers{i} = mean(cluster,2);
    spreads{i} = det(cov(cluster'));
end
