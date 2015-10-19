% Solution for Q3

trainSet = load('../data/train_small.mat');
testSet = load('../data/test.mat');

% 1
disp('Q1');
d = 28*28;
trainSet_size = size(trainSet.train, 2);
format_trains = cell(1, trainSet_size); % the formatted training sets
estimated_mus_all = cell(1, trainSet_size); % estimated_mus_all{i}{j} is the estimated mu for class (j-1) in train set i
estimated_sigmas_all = cell(1, trainSet_size); % estimated_sigmas_all{i}{j} is the estimatted sigma for class (j -1) for train set i

for i = 1:trainSet_size,
    disp(strcat(['Running on train set: ', num2str(i)]));
    format_trains{i} = format_images(trainSet.train{i});
    [estimated_mus_all{i}, estimated_sigmas_all{i}] = get_mle_estimate_classes(format_trains{i}.images, format_trains{i}.labels);
end

% 2
disp('Q2');
prior_dist = cell(1, trainSet_size); % prior_dist{i}(j) is the prior probability for class (j-1) in train set i
for i = 1:trainSet_size,
    disp(strcat(['Running on train set: ', num2str(i)]));
    prior_dist{i} = get_prior_dist(format_trains{i}.labels);
end

% 3
% (a)

for i = 1: trainSet_size,
    subplot(3,3,i);
    imagesc(estimated_sigmas_all{i}{1});
    title(strcat(['Training set ', num2str(i)]));
end
h=colorbar;
set(h, 'Position', [.92 .11 .03 .8150])



% 4
format_test = format_images(testSet.test);

%(a)
% In this case, p(w, x) ~ p(x|w)*p(w) ~ exp(-0.5 * trans(x-u_i) * inv(sigma) *
% (x-u_i)) * p(w)
disp('Q4(a)');
predicteds = cell(1, trainSet_size); % predicteds{i} is the predicted label for the test set base on train set i
error_rates = zeros(1, trainSet_size); % error_rates(i) is the error rate of test set base on train set i
for i = 1:trainSet_size,
    disp(strcat(['Running on train set: ', num2str(i)]));
    [predicteds{i} error_rates(i)] = get_predicted1(format_test, estimated_mus_all{i}, estimated_sigmas_all{i}, prior_dist{i}, 0.001);
end

% error rate: 0.2571    0.2081    0.1420    0.1294    0.1226    0.1163    0.1145

%(b)
% in this case, p(w, x) ~ p(x|w)*p(w) ~ exp(-0.5 * trans(x-u_i) *
% inv(sigma_i) * (x-u_i)) * p(w) / sqrt(|sigma_i|)
disp('Q4(b)');
predicteds_2 = cell(1, trainSet_size); % predicteds_2{i} is the predicted label for the test set base on train set i
error_rates_2 = zeros(1, trainSet_size); % error_rates_2(i) is the error rate of test set base on train set i
for i = 1:trainSet_size,
    disp(strcat(['Running on train set: ', num2str(i)]));
    [predicteds_2{i} error_rates_2(i)] = get_predicted2(format_test, estimated_mus_all{i}, estimated_sigmas_all{i}, prior_dist{i}, 0.001, 960);
end

% error rate: 0.2011    0.1370    0.0825    0.0601    0.0501    0.0438    0.0431

%(c)
figure()
plot(1:7, error_rates, 1:7, error_rates_2)
legend('Overall sigma', 'individual sigmas')
xlabel('train sets'); 
ylabel('error rates');
title('Comparing error rate for the two methods')
