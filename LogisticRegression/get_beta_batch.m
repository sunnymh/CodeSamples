function [ betas, iter ] = get_beta_batch( X, label, init_beta, lambda, learning_rate, max_iter, threshold )
%UPDATE_BETA_BATCH Summary of this function goes here
%   Detailed explanation goes here
beta_length = size(X, 2);
betas = zeros(beta_length, max_iter);
beta = init_beta;
for i = 1:max_iter,
    if (mod(i, 1000) == 0)
        disp(strcat(['Runned ', num2str(i), ' iterations']));
    end
    mu = get_mu(X, beta);
    g = 2 * lambda * beta + transpose(X) * (mu - label);
    new_beta = beta - learning_rate * g;
    if norm(g) < threshold
        iter = i - 1;
        break;
    else
        beta = new_beta;
        betas(:, i) = beta;
    end
    iter = max_iter;
end
betas = betas(:, 1:iter);
end

