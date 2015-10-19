function [ mse ] = loss_mse( xtrain, ytrain, weights )
%FUNC_MSE Summary of this function goes here
%   Detailed explanation goes here
ndata = size(xtrain, 1);
ytrain_predicted = zeros(ndata, size(ytrain, 2));
for i=1:ndata,
    [S, X] = apply_forward(xtrain(i,:), weights);
    ytrain_predicted(i,:) = X{size(weights, 2)};
end
mse = 0.5 * sum(sum((ytrain - ytrain_predicted) .* (ytrain - ytrain_predicted)));
end

