% Solution for Q1

Xtrain = textread('../data/Xtrain.txt', '%n');
Ytrain = textread('../data/Ytrain.txt', '%n');
Xtest = textread('../data/Xtest.txt', '%n');
Ytest = textread('../data/Ytest.txt', '%n');

%(a)

% initialize variables
features = cell(1, 10); % the design matrics
Yfitteds = cell(1, 10); % the fitted values
weights = cell(1, 10); % the lesast square solution for b
losses = zeros(1, 10); % the values from loss function

for i = 1:10,
    feature = get_matrix(Xtrain, i);
    weight = feature \ Ytrain;
    Yfitted = feature * weight;
    loss = sum((Ytrain - Yfitted).^2);
    features{i} = feature;
    Yfitteds{i} = Yfitted;
    weights{i} = weight;
    losses(i) = loss;
end

figure();
plot(1:10, losses, 'rO');
xlim([0 11])
xlabel('d'); 
ylabel('least square loss');
title('Least square loss for d = 1:10')
% losses:
% 6.0870    3.4393    0.9842    0.9831    0.9704
% 0.9477    0.9476    0.9473    0.9448    0.9397
% The minimum loss is achieved by d = 10
% However it is not a good fit since for d > 2, all losses are quite
% similar.

figure();
plot(Xtrain, Ytrain, 'black', Xtrain, Yfitteds{1}, 'r', Xtrain, Yfitteds{2}, 'y', Xtrain, Yfitteds{3}, 'bx', Xtrain, Yfitteds{4}, 'g')
legend('Ytrain', 'd = 1', 'd = 2', 'd = 3', 'd = 4')
xlabel('x'); 
ylabel('y');
title('y~x for d = 1, 2, 3, 4')
% There is almost no different for d = 3 and d = 4

%(b)

% loss for d = 3
test_feature_3 = get_matrix(Xtest, 3);
test_Yfitted_3 = test_feature_3 * weights{3};
test_loss_3 = sum((Ytest - test_Yfitted_3).^2); % 5.1013

% loss for d = 10
test_feature_10 = get_matrix(Xtest, 10);
test_Yfitted_10 = test_feature_10 * weights{10};
test_loss_10 = sum((Ytest - test_Yfitted_10).^2); % 5.4406
% The two losses are almost the same
