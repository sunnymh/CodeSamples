function [ batch_sum ] = calc_gradient( xtrain_batch, ytrain_batch, weights, is_mse )
%UNTITLED update weight for neutral network inside a minibatch
%   Detailed explanation goes here

% delta = cell(size(X))
% for each data point:
%     [S, X] = apply_forward(xtrain_point, weight);
%    delta = apply_backward(X, ytrain_point, weight)
% batch_sum += delta * xi

nlayers = size(weights, 2);
batch_sum = cell(1, nlayers);
for i=1:nlayers,
    batch_sum{i} = zeros(size(weights{i}));
end

for i=1:size(xtrain_batch, 1),
    [S, X] = apply_forward(xtrain_batch(i,:), weights);
    deltas = apply_backward(S, X, ytrain_batch(i,:), weights, is_mse); 
    
    gradient = cell(1, nlayers);
    gradient{1} = transpose(xtrain_batch(i,:)) * transpose(deltas{1});
    for j=2:nlayers,
        gradient{j} = X{j-1} * transpose(deltas{j});
    end
    
    batch_sum = cellfun(@plus, batch_sum, gradient, 'UniformOutput', false);
end
end
