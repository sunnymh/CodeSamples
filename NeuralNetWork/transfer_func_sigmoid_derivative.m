function [ derivative ] = transfer_func_sigmoid_derivative( S_layer )
%FUNC_SIGMOID_DERIVATIVE Summary of this function goes here
%   Detailed explanation goes here
derivative = transfer_func_sigmoid(S_layer) .* (1 - transfer_func_sigmoid(S_layer));
end

