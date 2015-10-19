% Read in data
spamData = load('spam.mat');
Xtest = spamData.Xtest;
Xtrain = spamData.Xtrain;
Ytrain = double(spamData.ytrain);
beta_length = size(Xtrain, 2) + 1;
number_of_points = size(Xtrain, 1);

% Clean up data
Xtrain1 = bsxfun(@rdivide, bsxfun(@minus, Xtrain, mean(Xtrain)), sqrt(var(Xtrain)));
Xtrain1 = add_constant(Xtrain1);
Xtest1 = bsxfun(@rdivide, bsxfun(@minus, Xtest, mean(Xtest)), sqrt(var(Xtest)));
Xtest1 = add_constant(Xtest1);

Xtrain2 = log(Xtrain + 0.1);
Xtrain2 = add_constant(Xtrain2);
Xtest2 = log(Xtest + 0.1);
Xtest2 = add_constant(Xtest2);

Xtrain3 = double(Xtrain > 0);
Xtrain3 = add_constant(Xtrain3);
Xtest3 = double(Xtest > 0);
Xtest3 = add_constant(Xtest3);

%Q1
% Here I use: initial_beta = all 0.1, lambda = 25, alpha = 1e-5, max_iteration = 10000, threshold = 1
error_rate1 = plot_training_loss(Xtrain1, Ytrain, ones(beta_length, 1) * 0.1, 25, 1e-5, 10000, 1, 0, 'cleaned dataset 1');
error_rate2 = plot_training_loss(Xtrain2, Ytrain, ones(beta_length, 1) * 0.1, 25, 1e-5, 10000, 1, 0, 'cleaned dataset 2');
error_rate3 = plot_training_loss(Xtrain3, Ytrain, ones(beta_length, 1) * 0.1, 25, 1e-5, 10000, 1, 0, 'cleaned dataset 3');

%Q2
error_rate4 = plot_training_loss(Xtrain1, Ytrain, ones(beta_length, 1) * 0.1, 10, 1e-4, 30, 1, 1, 'cleaned dataset 1');
error_rate5 = plot_training_loss(Xtrain2, Ytrain, ones(beta_length, 1) * 0.1, 10, 1e-6, 20, 1, 1, 'cleaned dataset 2');
error_rate6 = plot_training_loss(Xtrain3, Ytrain, ones(beta_length, 1) * 0.1, 10, 1e-4, 30, 1, 1, 'cleaned dataset 3');

%Q3
learning_rate = 10./(1:(100 * number_of_points));
error_rate7 = plot_training_loss(Xtrain1, Ytrain, ones(beta_length, 1) * 0.1, 10, learning_rate, 30, 1, 1, 'cleaned dataset 1');
error_rate8 = plot_training_loss(Xtrain2, Ytrain, ones(beta_length, 1) * 0.1, 10, learning_rate, 30, 1, 1, 'cleaned dataset 2');
error_rate9 = plot_training_loss(Xtrain3, Ytrain, ones(beta_length, 1) * 0.1, 10, learning_rate, 30, 1, 1, 'cleaned dataset 3');

%Q4
% Batch returns better results comparing with Stochastic. So for the three
% data sets, I'm going to run cross validation using batch gradient decent
% with different lambdas and alphas.

cvData1 = get_10folds(Xtrain1, Ytrain);
cvData2 = get_10folds(Xtrain2, Ytrain);
cvData3 = get_10folds(Xtrain3, Ytrain);

% CV 1
lambdas1 = 10 .^(-2:2);
alphas1 = 10.^(-7:-3);
error_rates2_1 = cv_batch(cvData2, ones(beta_length, 1) * 0.1, lambdas1, alphas1, 10000, 1);

% Result for data set 2

%       NaN       NaN       NaN       NaN       NaN
%       NaN       NaN       NaN       NaN       NaN
%       NaN       NaN       NaN       NaN       NaN
%       NaN       NaN    0.0565       NaN       NaN
%       NaN       NaN    0.0693       NaN       NaN

% valid range lambda > 1, learning rate 1e-6 ~ 1e-4


% CV 2
lambdas2 = 0:10:100;
alphas2 = 1e-5:1e-5:1e-4;
error_rates2_2 = cv_batch(cvData2, ones(beta_length, 1) * 0.1, lambdas2, alphas2, 10000, 1);

% Result for data set 2

%       NaN       NaN       NaN       NaN       NaN       NaN       NaN
%    0.0565    0.0565    0.0565       NaN       NaN       NaN       NaN
%    0.0571    0.0574    0.0574       NaN       NaN       NaN       NaN
%    0.0591    0.0591    0.0591       NaN       NaN       NaN       NaN
%    0.0620    0.0620    0.0620       NaN       NaN       NaN       NaN
%    0.0638    0.0638       NaN       NaN       NaN       NaN       NaN
%    0.0661    0.0661       NaN       NaN       NaN       NaN       NaN
%    0.0684    0.0684       NaN       NaN       NaN       NaN       NaN
%    0.0687    0.0687       NaN       NaN       NaN       NaN       NaN
%    0.0693    0.0693       NaN       NaN       NaN       NaN       NaN
%    0.0693    0.0693       NaN       NaN       NaN       NaN       NaN

%  Columns 8 through 10
%
%       NaN       NaN       NaN
%       NaN       NaN       NaN
%       NaN       NaN       NaN
%       NaN       NaN       NaN
%       NaN       NaN       NaN
%       NaN       NaN       NaN
%       NaN       NaN       NaN
%       NaN       NaN       NaN
%       NaN       NaN       NaN
%       NaN       NaN       NaN
%       NaN       NaN       NaN

% good range lambda close to 0~10, learning rate 1e-6 ~ 1e-5


% CV 3
lambdas3 = 9:0.2:11;
alphas3 = 5e-6:1e-6:1.5e-5;
error_rate1_3 = cv_batch(cvData1, ones(beta_length, 1) * 0.1, lambdas3, alphas3, 10000, 1);
error_rates2_3 = cv_batch(cvData2, ones(beta_length, 1) * 0.1, lambdas3, alphas3, 10000, 1);
error_rate3_3 = cv_batch(cvData3, ones(beta_length, 1) * 0.1, lambdas3, alphas3, 10000, 1);

% Result for data set 1

% Columns 1 through 7
%
%       NaN       NaN       NaN       NaN       NaN       NaN       NaN
%       NaN       NaN       NaN       NaN       NaN       NaN    0.0814
%       NaN       NaN       NaN       NaN       NaN       NaN    0.0814
%       NaN       NaN       NaN       NaN       NaN       NaN    0.0817
%       NaN       NaN       NaN       NaN       NaN       NaN    0.0823
%       NaN       NaN       NaN       NaN       NaN       NaN    0.0829
%       NaN       NaN       NaN       NaN       NaN       NaN    0.0832
%       NaN       NaN       NaN       NaN       NaN    0.0835    0.0835
%       NaN       NaN       NaN       NaN       NaN    0.0835    0.0835
%       NaN       NaN       NaN       NaN       NaN    0.0835    0.0835
%       NaN       NaN       NaN       NaN       NaN    0.0835    0.0835
%
%  Columns 8 through 11
%
%    0.0814    0.0814    0.0814    0.0814
%    0.0814    0.0814    0.0814    0.0814
%    0.0814    0.0814    0.0814    0.0814
%    0.0817    0.0817    0.0817    0.0817
%    0.0823    0.0823    0.0823    0.0823
%    0.0829    0.0829    0.0829    0.0829
%    0.0832    0.0832    0.0832    0.0832
%    0.0835    0.0835    0.0835    0.0835
%    0.0835    0.0835    0.0835    0.0835
%    0.0835    0.0835    0.0835    0.0835
%    0.0835    0.0835    0.0835    0.0835

% Result for data set 2

% Columns 1 through 7
%
%       NaN       NaN       NaN       NaN       NaN       NaN    0.0557
%       NaN       NaN       NaN       NaN       NaN       NaN    0.0557
%       NaN       NaN       NaN       NaN       NaN       NaN    0.0559
%       NaN       NaN       NaN       NaN       NaN       NaN    0.0562
%       NaN       NaN       NaN       NaN       NaN    0.0562    0.0562
%       NaN       NaN       NaN       NaN       NaN    0.0565    0.0565
%       NaN       NaN       NaN       NaN       NaN    0.0565    0.0565
%       NaN       NaN       NaN       NaN       NaN    0.0565    0.0565
%       NaN       NaN       NaN       NaN       NaN    0.0565    0.0565
%       NaN       NaN       NaN       NaN       NaN    0.0565    0.0565
%       NaN       NaN       NaN       NaN       NaN    0.0565    0.0565
%
%  Columns 8 through 11
%
%    0.0557    0.0557    0.0557    0.0557
%    0.0557    0.0557    0.0557    0.0557
%    0.0559    0.0559    0.0559    0.0559
%    0.0562    0.0562    0.0562    0.0562
%    0.0562    0.0562    0.0562    0.0562
%    0.0565    0.0565    0.0565    0.0565
%    0.0565    0.0565    0.0565    0.0565
%    0.0565    0.0565    0.0565    0.0565
%    0.0565    0.0565    0.0565    0.0565
%    0.0565    0.0565    0.0565    0.0565
%    0.0565    0.0565    0.0565    0.0565
    
% good range lambda 9.4 ~ 10, learning rate 1.1e-5 ~ 1.5e-5. And learning
% rate in this range doesn't seems to influence the prediction. Data set 2
% performs the best among the three

% CV 4
lambdas4 = 9.4:0.06:10;
error_rates2_4 = cv_batch(cvData2, ones(beta_length, 1) * 0.1, lambdas4, 1.3e-5, 10000, 1);

% 0.0559    0.0562  0.0562  0.0562  0.0562  0.0562  0.0562  0.0565  0.0565  0.0565  0.0565

% optimal lambda 9.6 with eta 1.3e-5


% Predict Ytest using optimal Beta and Eta
[betas2, iter2] = get_beta_batch(Xtrain2, Ytrain, ones(beta_length, 1) * 0.1, 9.6, 1.3e-5, 10000, 1);
beta2 = betas2(:,iter2);

predicted_Ytest2 = double((Xtest2 * beta2) > 0);
Header=sprintf('%s',['Id',',', 'Category']);
dlmwrite('result.csv', Header,'');
dlmwrite('result.csv',[transpose(1:size(Xtest2)), predicted_Ytest2],'-append','delimiter',',');
