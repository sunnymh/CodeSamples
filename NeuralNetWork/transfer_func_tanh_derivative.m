function [ derivative ] = transfer_func_tanh_derivative( S_layer )
%FUNC_TANH_DERIVATIVE Summary of this function goes here
%   Detailed explanation goes here
derivative = 1 - S_layer .* S_layer;
end

