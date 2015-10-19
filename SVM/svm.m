% Load data
trainSet = load('../data/train_small.mat');
train60000 = load('../data/train.mat');
testSet = load('../data/test.mat');


% Problem 1
trainSet_size = size(trainSet.train, 2);
reformat_test = reformat_images(testSet.test);

% Variables to store train and predict intermediate values
reformat_trains = cell(1, trainSet_size);
models = cell(1, trainSet_size);
predicted_labels = cell(1, trainSet_size);
error_rate = zeros(1, trainSet_size);

% Run train and test for each train set
for i = 1:trainSet_size,
    reformat_trains{i} = reformat_images(trainSet.train{i});
    models{i} = train(reformat_trains{i}.label, reformat_trains{i}.matrix, '-s 2');
    predicted_labels{i} = predict(reformat_test.label, reformat_test.matrix, models{i});
    error_rate(i) = benchmark(predicted_labels{i}, reformat_test.label);
end

% 0.2740    0.2176    0.1856    0.1740    0.1704    0.1496    0.1133

% Plot the result
% plot(1:7, error_rate, 'r*');


% Problem 2
confusion_matrix = confusionmat(reformat_test.label,predicted_labels{7});
% imagesc(confusion_matrix);
% colorbar;


% Problem 3
train10000 = reformat_trains{7};
random_indices = randperm(10000);

% get all the folds
folds = cell(1, 10);
for i = 1:10,
    indices1000 = random_indices(1000*(i-1)+1 : 1000*i);
    features1000 = train10000.matrix(indices1000,:);
    labels1000 = train10000.label(indices1000);
    fold = struct('matrix', features1000, 'label', labels1000);
    folds{i} = fold;
end

% get the 10 train and validation sets
cvData = cell(1,10);
for i = 1:10,
    train9000_features = zeros(9000, 28*28);
    train9000_labels = zeros(9000, 1);
    n = 1;
    for j = 1:10,
        if j == i
            validation_features = folds{j}.matrix;
            validation_labels = folds{j}.label;
        else
            train9000_features(n:(n+999),:) = folds{j}.matrix;
            train9000_labels(n:(n+999),1) = folds{j}.label;
            n = n + 1000;
        end
    end
    cvData{i} = struct('train_matrix', train9000_features, 'train_labels', train9000_labels, 'validation_features', validation_features, 'validation_labels', validation_labels);
end

% Just try to get a general idea of the range of best c values.
error_rate_cv = zeros(1, 21);
for i = 1:21,
    error_rate_cv(i) = cv_svm(cvData, 10^(i-19));
end

% 0.3433    0.3433    0.3433    0.3433    0.3433    
% 0.3429    0.3329    0.2859    0.2334    0.1670
% 0.1221    0.1026    0.1021    0.1142    0.1228    
% 0.1237    0.1234    0.1236    0.1243    0.1223    
% 0.1216

% the best c is between 10^-8 and 10^-5
error_rate_cv2 = zeros(1, 21);
for i = 1:21,
    error_rate_cv2(i) = cv_svm(cvData, 10^(-8) + 50*(i-1)*10^(-8) );
end

% 0.1221    0.1023    0.1022    0.1036    0.1052    
% 0.1056    0.1069    0.1075    0.1106    0.1094    
% 0.1103    0.1110    0.1107    0.1123    0.1132    
% 0.1132    0.1122    0.1129    0.1143    0.1131    
% 0.1141

% the best c is between 10^-8 and 10^-8 * 151

error_rate_cv3 = zeros(1, 31);
for i = 1:31,
    error_rate_cv3(i) = cv_svm(cvData, 10^(-8) + 5*(i-1)*10^(-8) );
end


% 0.1221    0.1057    0.1020    0.1018    0.1020    
% 0.1016    0.1019    0.1017    0.1014    0.1022    
% 0.1023    0.1014    0.1028    0.1020    0.1019    
% 0.1019    0.1026    0.1028    0.1026    0.1017    
% 0.1022    0.1021    0.1026    0.1027    0.1032    
% 0.1031    0.1033    0.1035    0.1034    0.1035    
% 0.1036
  
% For range 11 * 10^-8 ~ 121 * 10 ^-8, the error rate varies between 0.1014
% and 0.1028. So I'd say C = 4.1 * 10 ^ -7 is a pretty good value.

% Train on the whole 10000 data set.
model_10000 = train(train10000.label, train10000.matrix, horzcat(['-s 2 -c ', num2str(4.2 * 10 ^ (-7))]));
predicted_labels_10000 = predict(reformat_test.label, reformat_test.matrix, model_10000);
error_rate_10000 = benchmark(predicted_labels_10000, reformat_test.label);

% 0.0947

% Test on the 60000 training set
reformat_train60000 = reformat_images(train60000.train);
model_60000 = train(reformat_train60000.label, reformat_train60000.matrix, horzcat(['-s 2 -c ', num2str(4.2 * 10 ^ (-7))]));
predicted_labels_60000 = predict(reformat_test.label, reformat_test.matrix, model_60000);
error_rate_60000 = benchmark(predicted_labels_60000, reformat_test.label);
    
% 0.0831
