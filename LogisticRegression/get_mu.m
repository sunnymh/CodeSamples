function [ mu ] = get_mu( X, beta )
%GET_MU Summary of this function goes here
%   Detailed explanation goes here
mu = 1 ./ (1 + exp(-1 * X * beta));
end

