function [ error_rates ] = cv_batch( cvData, init_beta, lambdas, alphas, max_iter, threshold )
%CV_BATCH Summary of this function goes here
%   Detailed explanation goes here
nlambda = length(lambdas);
nalpha = length(alphas);
error_rates = zeros(nlambda, nalpha);
for i = 1:nlambda,
    for j = 1:nalpha,
        error_rate = zeros(1, 10);
        for k = 1:10,
            disp(strcat(['Running i = ', num2str(i), ', j = ', num2str(j), ', fold = ', num2str(k)]));
            [betas, iter] = get_beta_batch( cvData{k}.train_features, cvData{k}.train_labels, init_beta, lambdas(i), alphas(j), max_iter, threshold );
            error_rate(k) = get_error_rate( cvData{k}.validation_features, cvData{k}.validation_labels, betas(:, iter));
            if iter == max_iter
                error_rate = NaN * ones(1,10);
                break;
            end
        end
        error_rates(i, j) = mean(error_rate);
    end 
end
end

