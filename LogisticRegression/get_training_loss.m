function [ training_losses ] = get_training_loss( X, label, betas)
%GET_TRAINING_LOSS Summary of this function goes here
%   Detailed explanation goes here
iters = size(betas, 2);
training_losses = zeros(1, iters);
for i = 1:iters,
    if mod(i, 100) == 0
        disp(strcat(['Finish ', num2str(i / iters * 100), '%']));
    end
    mu = get_mu(X, betas(:, i));
    training_losses(i) =  - sum(label .* log(mu) + (1 - label) .* log(1 - mu));
end


