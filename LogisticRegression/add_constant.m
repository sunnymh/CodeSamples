function [ new_X ] = add_constant( X )
%ADD_CONSTANT Summary of this function goes here
%   Detailed explanation goes here
new_X = [ones(size(X, 1), 1) X];
end

