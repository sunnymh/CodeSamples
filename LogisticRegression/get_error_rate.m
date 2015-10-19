function [ error_rate ] = get_error_rate( X, label, beta )
%GET_ERROR_RATE Summary of this function goes here
%   Detailed explanation goes here
predicted = double((X * beta) > 0);
error_rate = mean(predicted ~= label);
end

