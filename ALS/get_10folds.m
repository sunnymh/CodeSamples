function [ cvData ] = get_10folds( R, W )
%GET_10FOLDS Summary of this function goes here
%   Detailed explanation goes here
number_of_points = size(R, 1);
feature_length = size(R, 2);
indices = find(R);
random_indices = randperm(size(indices, 1));
fold_length = floor(size(indices, 1)/ 10);

% get the 10 train and validation sets
cvData = cell(1,10);
for i = 1:10,
    if i ~= 10,
        indice_fold = indices(random_indices(fold_length*(i-1)+1 : fold_length*i));
    else
        indice_fold = indices(random_indices(fold_length*9+1 : size(indices, 1)));
    end
    training_data = R;
    training_weight = W;
    
    training_data(indice_fold) = 0;
    training_weight(indice_fold) = 0;
    
    testing_data = zeros(number_of_points, feature_length);
    testing_weight = zeros(number_of_points, feature_length);
    
    testing_data(indice_fold) = R(indice_fold);
    testing_weight(indice_fold) = W(indice_fold);
    cvData{i} = struct('indice', indice_fold, 'training_data', training_data, 'training_weight', training_weight, 'testing_data', testing_data, 'testing_weight', testing_weight);
end

end

