function [ mses ] = get_mses( xtrain, ytrain, all_weights )
%GET_MSES Summary of this function goes here
%   Detailed explanation goes here
nweights = size(all_weights, 2);
mses = zeros(1, nweights);
for i=1:nweights,
    if  isempty(all_weights{i}),
        return
    end
    mses(i) = loss_mse(xtrain, ytrain, all_weights{i});
end

