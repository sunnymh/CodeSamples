function [ ] = give_analysis( file_name, xtrain, ytrain, xtest, ytest )
%GIVE_ANALYSIS Summary of this function goes here
%   Detailed explanation goes here

% load weight file
load(file_name);
 
% calculate training error and generate graph
training_error = get_error_rate(xtrain, ytrain, all_weights);
training_error = training_error(find(training_error));
plot(linspace(0,10*(size(training_error,2)-1), size(training_error,2)),training_error);

% calculate classification accuracy and generate graph
class_error = get_error_rate(xtest, ytest, all_weights);
class_error = class_error(find(class_error));
plot(linspace(0,10*(size(class_error,2)-1), size(class_error,2)),class_error);

% calculate L2 magnitude of weights (every 10 epochs)
% calculate the change in L2 magnitude of weights (every 10 epochs)

end

