function [ estimated_mus, estimated_sigmas ] = get_mle_estimate_classes( data, labels )
%Q3: Get mle estimate for data for each class given a training set
estimated_mus = cell(1, 10);
estimated_sigmas = cell(1, 10);
for i = 1:10,
    cat = (labels == (i-1));
    [estimated_mus{i}, estimated_sigmas{i}] = get_mle_estimate(data(cat,:));
end


