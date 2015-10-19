function [ error_rate ] = cv_svm( cvData, c )
%CV_SVM Summary of this function goes here
%   Detailed explanation goes here
error_rates = zeros(1,10);
for i = 1:10,
    model10 = train(cvData{i}.train_labels, sparse(cvData{i}.train_matrix), horzcat(['-s 2 -c ', num2str(c)]));
    predicted_labels = predict(cvData{i}.validation_labels, cvData{i}.validation_features, model10);
    error_rates(i) = benchmark(predicted_labels, cvData{i}.validation_labels);
    error_rate = mean(error_rates);
end

