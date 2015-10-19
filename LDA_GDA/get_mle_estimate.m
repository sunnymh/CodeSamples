function [ estimated_mu, estimated_sigma ] = get_mle_estimate( data )
%Q3 Returns the mle estimate of mu and sigma for a given class
%matrix
dim = size(data);
estimated_mu = transpose(sum(data) / dim(1));
sum_sigma = zeros(dim(2), dim(2));
for i = 1: dim(1),
    row = transpose(data(i, :));
    sum_sigma = sum_sigma + (row - estimated_mu) * transpose(row - estimated_mu);
end
estimated_sigma = sum_sigma / dim(1);

