function [ gradient ] = loss_mse_gradient( X_layer, y_train_point )
%FUNC_MSE_DERIVATIVE Summary of this function goes here
%   Detailed explanation goes here
gradient = X_layer - y_train_point;
end

