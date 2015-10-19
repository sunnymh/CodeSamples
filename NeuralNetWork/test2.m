xtrain = [4 5 3 1 2 2];
ytrain = [0 1 0 0];

mnn = nn_train(xtrain, ytrain, [4, 4, 4], 5, ones(1, 5) * 1e-3, true, '../data/test.mat');
load('../data/test.mat')
test_error_rates = get_error_rate(xtrain, ytrain, all_weights);
training_mses = get_mses(xtrain, ytrain, all_weights);