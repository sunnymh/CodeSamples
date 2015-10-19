function [ error_rates ] = get_error_rate( feature_matrix, label_matrix, all_weights)
%GET_ERROR_RATE Summary of this function goes here
%   Detailed explanation goes here
[m labels] = max(transpose(label_matrix));
labels = labels -1;
error_rates = zeros(1, size(all_weights, 2));
for i=1:size(all_weights, 2),
    disp(strcat(['working on the ith rate: ', num2str(i)]));
    if  isempty(all_weights{i})==1,
        return
    end
    labels_predicted = nn_predict( feature_matrix, all_weights{i});
    error_rates(i) = sum(labels_predicted ~= labels)/size(feature_matrix, 1);
end
end
