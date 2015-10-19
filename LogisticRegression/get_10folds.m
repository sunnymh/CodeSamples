function [ cvData ] = get_10folds( feature, label )
%GET_10FOLDS Summary of this function goes here
%   Detailed explanation goes here
number_of_points = size(feature, 1);
feature_length = size(feature, 2);
random_indices = randperm(number_of_points);
fold_length = floor(number_of_points/ 10);

% get all the folds
folds = cell(1, 10);
for i = 1:10,
    indice_fold = random_indices(fold_length*(i-1)+1 : fold_length*i);
    train_fold = feature(indice_fold,:);
    label_fold = label(indice_fold);
    fold = struct('feature', train_fold, 'label', label_fold);
    folds{i} = fold;
end

% get the 10 train and validation sets
cvData = cell(1,10);
for i = 1:10,
    train_features = zeros(fold_length * 9, feature_length);
    train_labels = zeros(fold_length * 9, 1);
    n = 1;
    for j = 1:10,
        if j == i
            validation_features = folds{j}.feature;
            validation_labels = folds{j}.label;
        else
            train_features(n:(n+fold_length-1),:) = folds{j}.feature;
            train_labels(n:(n+fold_length-1),1) = folds{j}.label;
            n = n + fold_length;
        end
    end
    cvData{i} = struct('train_features', train_features, 'train_labels', train_labels, 'validation_features', validation_features, 'validation_labels', validation_labels);
end

end

