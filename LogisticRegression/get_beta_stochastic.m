function [ betas, iter ] = get_beta_stochastic( X, label, init_beta, lambda, learning_rate, max_iter, threshold )
%GET_BETA_STOCHASTIC Summary of this function goes here
%   Detailed explanation goes here
num_of_points = size(X, 1);
beta_length = size(X, 2);
betas = zeros(beta_length, max_iter * num_of_points);
beta = init_beta;
iter = 0;
constant_learning_rate = (length(learning_rate) == 1);
for i = 1:max_iter,
    random_indices = randperm(num_of_points);
    for j = 1:num_of_points,
        iter = iter + 1;
        indice = random_indices(j);
        mu = get_mu(X(indice,:), beta);
        g = 2 * lambda * beta + transpose(X(indice,:)) * (mu - label(indice));
        if constant_learning_rate
            new_beta = beta - learning_rate * g;
        else
            new_beta = beta - learning_rate(iter) * g;
        end
        if norm(g) < threshold
            iter = iter - 1;
            break;
        else
            beta = new_beta;
            betas(:, iter) = beta;
            if (mod(iter, 100) == 0)
                disp(strcat(['Runned ', num2str(iter), ' iterations']));
            end
        end
    end
end
betas = betas(:, 1:iter);
end

