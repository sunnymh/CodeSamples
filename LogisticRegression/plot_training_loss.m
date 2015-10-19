function [ error_rate ] = plot_training_loss( X, label, init_beta, lambda, learning_rate, max_iter, threshold, flag, dataset_name )
%PLOT_TRAINGING_LOSS Summary of this function goes here
%   Detailed explanation goes here
if flag == 0
    [betas, iter] = get_beta_batch(X, label, init_beta, lambda, learning_rate, max_iter, threshold);
else
    [betas, iter] = get_beta_stochastic(X, label, init_beta, lambda, learning_rate, max_iter, threshold);
end
training_loss = get_training_loss(X, label, betas);
error_rate = get_error_rate(X, label, betas(:,iter));
figure();
plot(training_loss);
if flag == 0
    title(strcat(['Training loss for ',dataset_name, ' using batch']));
else
    title(strcat(['Training loss for ',dataset_name, ' using stochastic']));
end
end

