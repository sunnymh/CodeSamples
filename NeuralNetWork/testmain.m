% Load data
load('../data/train_small.mat');
load('../data/test.mat');

% Preproces data
[xtrain, ytrain] = preprocess_image(train{5});
[xtest, ytest] = preprocess_image(test);
%xtrain = xtrain(1:3,:);
%ytrain = ytrain(1:3,:);

mnn = nn_train(xtrain, ytrain, [300, 100, 10], 10, ones(1, 500) * 1e-3, true, '../data/all_weights.mat');
load('../data/all_weights.mat');
%training_error_rates = get_error_rate(xtrain, ytrain, all_weights);
test_error_rates = get_error_rate(xtest, ytest, all_weights);
train_error_rates = get_error_rate(xtrain, ytrain, all_weights);
training_mses = get_mses(xtrain, ytrain, all_weights);