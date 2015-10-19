function [ gradient ] = loss_cee_gradient( X_layer, y_train_point )
%FUNC_CEE_GRADIENT Summary of this function goes here
%   Detailed explanation goes here
gradient = - (y_train_point ./ X_layer + (y_train_point - 1) ./ (1 - X_layer));
end

