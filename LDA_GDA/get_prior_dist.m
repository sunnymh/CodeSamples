function [ prior_dist ] = get_prior_dist( labels )
%Q3: Return the prior distribution of the data
prior_dist = zeros(1, 10);
length = size(labels, 1);
for i = 1:10,
    prior_dist(i) = sum(labels == (i -1)) / length;
end

