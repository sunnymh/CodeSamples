% Load data
load('../data/train.mat');
load('../data/test.mat');

% Preproces data
[xtrain, ytrain] = preprocess_image(train);
[xtest, ytest] = preprocess_image(test);


% Get single layer neural network for mse
start_time = clock();
snn_mse = nn_train(xtrain, ytrain, 10, 400, ones(1, 400) * 1e-2, true, '../data/weights_single_mse.mat', 0);
elapsed_time = etime(clock(), start_time);
fprintf('it took %d seconds\n', elapsed_time);  
%4841.986 seconds

% Compute error rate
load('../data/weights_single_mse.mat')
train_error_rates = get_error_rate(xtrain, ytrain, all_weights);
% 0.0860
test_error_rates = get_error_rate(xtest, ytest, all_weights);
% 0.0835

% Make Plot
figure();
plot(1:401, train_error_rates, 'blue', 1:401, test_error_rates, 'r')
legend('training error', 'test error')
xlabel('number of epoch'); 
ylabel('error rate');
title('Single layer mse')


% Get single layer neural network for cee
start_time = clock();
snn_cee = nn_train(xtrain, ytrain, 10, 400, ones(1, 400) * 1e-2, false, '../data/weights_single_cee.mat', 0); 
elapsed_time = etime(clock(), start_time);
fprintf('it took %d seconds\n', elapsed_time);  
% 5008.216 seconds

% Compute error rate
load('../data/weights_single_cee.mat')
train_error_rates = get_error_rate(xtrain, ytrain, all_weights);
% 0.0764
test_error_rates = get_error_rate(xtest, ytest, all_weights);
% 0.0786

% Make Plot
figure();
plot(1:401, train_error_rates, 'blue', 1:401, test_error_rates, 'r')
legend('training error', 'test error')
xlabel('number of epoch'); 
ylabel('error rate');
title('Single layer cee')
 

% Get 2 hidden layers neural network for mse
start_time = clock();
mnn = nn_train(xtrain, ytrain, [300, 100, 10], 5, ones(1, 500) * 1e-4, true, '../data/weights_multiple_mse2.mat', init_weight);
elapsed_time = etime(clock(), start_time);
fprintf('it took %d seconds\n', elapsed_time);

% Compute error rate
load('../data/weights_multiple_mse.mat');
train_error_rates = get_error_rate(xtrain, ytrain, all_weights);
% 0.0764
test_error_rates = get_error_rate(xtest, ytest, all_weights);
% 0.0786

% Make Plot
figure();
plot(1:401, train_error_rates, 'blue', 1:401, test_error_rates, 'r')
legend('training error', 'test error')
xlabel('number of epoch'); 
ylabel('error rate');
title('Single layer cee')
 

% Get 2 hidden layers neural network for cee
start_time = clock();
mnn_cee = nn_train(xtrain, ytrain, [300, 100, 10], 10, 10.^(-3:-0.1:-6), false, '../data/weights_multiple_cee.mat', 0);
elapsed_time = etime(clock(), start_time);
fprintf('it took %d seconds\n', elapsed_time);
% 6.430163e+03

% Compute error rate
load('../data/weights_multiple_cee.mat');
train_error_rates = get_error_rate(xtrain, ytrain, all_weights);
% 0.0764
test_error_rates = get_error_rate(xtest, ytest, all_weights);
% 0.0786

% Make Plot
figure();
plot(1:401, train_error_rates, 'blue', 1:401, test_error_rates, 'r')
legend('training error', 'test error')
xlabel('number of epoch'); 
ylabel('error rate');
title('Single layer cee')
