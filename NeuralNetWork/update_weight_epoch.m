function [ weights ] = update_weight_epoch( xtrain_permute, ytrain_permute, weights, learning_rate, is_mse )
%UPDATE_WEIGHT_EPOCH update weights for nueral network in a epoch
%   Detailed explanation goes here

% permute indices
% initialize delta
% for each 200 indices:
%       batch_sum = update_weight_minibatch(xtrain_batch, ytrain_batch, weights)
%       weight = weight - learning_rate * batch_sum

ndata = size(xtrain_permute, 1);
start_indices = 1:200:ndata;
end_indices = start_indices(2:end)-1;
end_indices = [end_indices ndata];

for i=1:size(start_indices, 2),
    disp(strcat(['Running minibatch: ', num2str(i)]));
    x_train_batch = xtrain_permute(start_indices(i):end_indices(i),:);
    y_train_batch = ytrain_permute(start_indices(i):end_indices(i),:);
    batch_sum = calc_gradient(x_train_batch, y_train_batch, weights, is_mse);
    weights = cellfun(@(w_layer, b_layer) w_layer - learning_rate * b_layer, weights, batch_sum, 'UniformOutput', false);
end

