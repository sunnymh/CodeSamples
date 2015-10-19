function [ weights ] = nn_train( xtrain, ytrain, layer, nepoch, learning_rates, is_mse, file_to_save, ini_weight)
%NN_TRAIN Train a Neural Network model
%INPUT: layer information and error rate calcualation function
%RETURN: weights

% initialized weight matrices, weight in each layer as a matrix in a cell
% for each epoch:
%       weight = update_weight_epoch(xtrain, ytrain, weight, ...)

all_weights = cell(1, nepoch + 1);

% initialize learning rate
if iscell(ini_weight)
    weights = ini_weight;
else
    weights = cell(1, size(layer, 2));
    weights{1} = (rand(size(xtrain,2), layer(1)) *2 - 1) * 1e-3;
    nlayers = size(layer, 2);
    for i=2:nlayers,
         weights{i} = (rand(layer(i-1), layer(i)) - 0.5) * 1e-3;
    end
end

all_weights{1} = weights;
save(file_to_save, 'all_weights');

for i=1:nepoch,
    disp(strcat(['Running epoch: ', num2str(i)]));
    indices = randperm(size(xtrain, 1));
    weights = update_weight_epoch(xtrain(indices,:), ytrain(indices,:), weights, learning_rates(i), is_mse);
    all_weights{i+1} = weights;

    %if rem(i, 5) == 0,
    save(file_to_save, 'all_weights');
    %end
end
save(file_to_save, 'all_weights');
end
