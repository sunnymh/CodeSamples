function [ mu, beta_new ] = update_beta( X, Y, lambda, beta )
%UPDATE_BETA Summary of this function goes here
%   Detailed explanation goes here
mu = get_mu(X, beta);
g = 2 * lambda * beta + transpose(X) * (mu - Y);
h = 2  * lambda * eye(length(beta)) + transpose(X) * diag(mu .* (1 - mu)) * X;
beta_new = beta - (h \ g);
end

