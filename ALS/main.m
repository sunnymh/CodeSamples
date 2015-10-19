data = dlmread('u.data', '\t');

%%%%%%
% Q1 %
%%%%%%

R1 = full(spconvert(data(:,1:3)));
W1 = (R1~=0);

rand('seed',1);
[A1_10,Y1_10,residual1_10] = wnmfrule(R1, W1, 10, struct());
LSE1_10 = sum(sum(W1.*(R1 - A1_10*Y1_10).^2));
% 5.1014e+04

rand('seed',1);
[A1_50,Y1_50,residual1_50] = wnmfrule(R1, W1, 50, struct());
LSE1_50 = sum(sum(W1.*(R1 - A1_50*Y1_50).^2));
% 1.5550e+04

rand('seed',1);
[A1_100,Y1_100,residual1_100] = wnmfrule(R1, W1, 100, struct());
LSE1_100 = sum(sum(W1.*(R1 - A1_100*Y1_100).^2));
% 3.9825e+03

figure1 = figure;
plot(1:10:5000, residual1_10, 'b-', 1:10:5000, residual1_50, 'g--', 1:10:5000, residual1_100, 'r-.');
legend('k=10', 'k=50', 'k=100');
xlabel('iteration');
ylabel('Residual');
title('Method 1');
print(figure1, '-djpeg', './1.jpg', '-r50');

%%%%%%
% Q2 %
%%%%%%

R2 = W1;
W2 = R1;

rand('seed',1);
[A2_10,Y2_10,residual2_10] = wnmfrule(R2, W2, 10, struct());
LSE2_10 = sum(sum(W2.*(R2 - A2_10*Y2_10).^2));
% 0.0413

rand('seed',1);
[A2_50,Y2_50,residual2_50] = wnmfrule(R2, W2, 50, struct());
LSE2_50 = sum(sum(W2.*(R2 - A2_50*Y2_50).^2));
% 0.1086

rand('seed',1);
[A2_100,Y2_100,residual2_100] = wnmfrule(R2, W2, 100, struct());
LSE2_100 = sum(sum(W2.*(R2 - A2_100*Y2_100).^2));
% 0.3342

figure2 = figure;
plot(1:10:5000, residual2_10, 'b-', 1:10:5000, residual2_50, 'g--', 1:10:5000, residual2_100, 'r-.');
legend('k=10', 'k=50', 'k=100');
xlabel('iteration');
ylabel('Residual');
title('Method 2');
print(figure2, '-djpeg', './2.jpg', '-r50');

%%%%%%
% Q5 %
%%%%%%

% Link for the paper
% http://ac.els-cdn.com/S002437950500340X/1-s2.0-S002437950500340X-main.pdf
% ?_tid=541876e0-abf5-11e4-8614-00000aab0f6c&acdnat=1423003269_e66291b73acb
% 963d916d655024aabf01

k = [10, 50, 100];
lambda = [0.01, 0.1, 1];

% Method 1 regularized
rand('seed',1);
residuals5_1 = zeros(3, 3, 500);
LSE5_1 = zeros(3,3);
for i = 1:3,
    for j = 1:3,
        disp(['k: ', num2str(k(i)),', lambda: ', num2str(lambda(j))]);
        [A, Y, residuals] = wnmfrule_sparse(R1, W1, k(i), lambda(j));
        LSE5_1(i,j) = sum(sum(W1.*(R1 - A*Y).^2));
        residuals5_1(i,j,:) = residuals;
    end
end

figure3 = figure;
plot(1:10:5000, residual1_10, 'c-', 1:10:5000, reshape(residuals5_1(1,1,:), 1, 500), 'b-', 1:10:5000, reshape(residuals5_1(1,2,:),1,500), 'g--', 1:10:5000, reshape(residuals5_1(1,3,:),1,500), 'r-.');
legend('labmda=0','lambda=0.01', 'lambda=0.1', 'lambda=1');
xlabel('iteration');
ylabel('Residual');
title('Method 1 regularized k=10');
print(figure3, '-djpeg', './5_1.jpg', '-r50');

figure4 = figure;
plot(1:10:5000, residual1_50, 'c-', 1:10:5000, reshape(residuals5_1(2,1,:), 1, 500), 'b-', 1:10:5000, reshape(residuals5_1(2,2,:),1,500), 'g--', 1:10:5000, reshape(residuals5_1(2,3,:),1,500), 'r-.');
legend('labmda=0','lambda=0.01', 'lambda=0.1', 'lambda=1');
xlabel('iteration');
ylabel('Residual');
title('Method 1 regularized k=50');
print(figure4, '-djpeg', './5_2.jpg', '-r50');

figure5 = figure;
plot(1:10:5000, residual1_100, 'c-', 1:10:5000, reshape(residuals5_1(3,1,:), 1, 500), 'b-', 1:10:5000, reshape(residuals5_1(3,2,:),1,500), 'g--', 1:10:5000, reshape(residuals5_1(3,3,:),1,500), 'r-.');
legend('labmda=0','lambda=0.01', 'lambda=0.1', 'lambda=1');
xlabel('iteration');
ylabel('Residual');
title('Method 1 regularized k=100');
print(figure5, '-djpeg', './5_3.jpg', '-r50');

% Method 2 regularized
rand('seed',1);
residuals5_2 = zeros(3, 3, 500);
LSE5_2 = zeros(3,3);
for i = 1:3,
    for j = 1:3,
        disp(['k: ', num2str(k(i)),', lambda: ', num2str(lambda(j))]);
        [A, Y, residuals] = wnmfrule_sparse(R2, W2, k(i), lambda(j));
        LSE5_2(i,j) = sum(sum(W2.*(R2 - A*Y).^2));
        residuals5_2(i,j,:) = residuals;
    end
end

figure6 = figure;
plot(1:10:5000, residual2_10, 'c-', 1:10:5000, reshape(residuals5_2(1,1,:), 1, 500), 'b-', 1:10:5000, reshape(residuals5_2(1,2,:),1,500), 'g--', 1:10:5000, reshape(residuals5_2(1,3,:),1,500), 'r-.');
legend('labmda=0','lambda=0.01', 'lambda=0.1', 'lambda=1');
xlabel('iteration');
ylabel('Residual');
title('Method 2 regularized k=10');
print(figure6, '-djpeg', './5_4.jpg', '-r50');

figure7 = figure;
plot(1:10:5000, residual2_50, 'c-', 1:10:5000, reshape(residuals5_2(2,1,:), 1, 500), 'b-', 1:10:5000, reshape(residuals5_2(2,2,:),1,500), 'g--', 1:10:5000, reshape(residuals5_2(2,3,:),1,500), 'r-.');
legend('labmda=0','lambda=0.01', 'lambda=0.1', 'lambda=1');
xlabel('iteration');
ylabel('Residual');
title('Method 2 regularized k=50');
print(figure7, '-djpeg', './5_5.jpg', '-r50');

figure8 = figure;
plot(1:10:5000, residual2_100, 'c-', 1:10:5000, reshape(residuals5_2(3,1,:), 1, 500), 'b-', 1:10:5000, reshape(residuals5_2(3,2,:),1,500), 'g--', 1:10:5000, reshape(residuals5_2(3,3,:),1,500), 'r-.');
legend('labmda=0','lambda=0.01', 'lambda=0.1', 'lambda=1');
xlabel('iteration');
ylabel('Residual');
title('Method 2 regularized k=100');
print(figure8, '-djpeg', './5_6.jpg', '-r50');

%%%%%%
% Q3 %
%%%%%%

% Method 1 k=100, lambda = 0.1
rand('seed',1);
cv_data1 = get_10folds(R1, W1);
result1 = cell(1, 10);
for i = 1:10,
    [A, Y] = wnmfrule_sparse(cv_data1{i}.training_data, cv_data1{i}.training_weight, 100, 0.1);
    result1{i} = struct('indice', cv_data1{i}.indice, 'predicted', A * Y, 'testing_data', cv_data1{i}.testing_data, 'testing_weight', cv_data1{i}.testing_weight);
end

ABE1 = zeros(1, 10);
for i=1:10,
    ABE1(i) = sum(sum(abs((result1{i}.predicted -result1{i}.testing_data) .* result1{i}.testing_weight)))/10000;
end

figure9 = figure;
plot(ABE1, 'bo');
xlabel('Test');
ylabel('Average absolute error');
title('Average absolue error for Method 1');
print(figure9, '-djpeg', './3_1.jpg', '-r50');

max(ABE1);
% 1.0609
min(ABE1);
% 1.0408
mean(ABE1);
% 1.0507

% Method 2 k=100, lambda = 0.1
rand('seed',1);
cv_data2 = get_10folds(R2, W2);
result2 = cell(1, 10);
for i = 1:10,
    [A, Y] = wnmfrule_sparse(cv_data2{i}.training_data, cv_data2{i}.training_weight, 100, 0.1);
    result2{i} = struct('indice', cv_data2{i}.indice, 'predicted', A * Y, 'testing_data', cv_data2{i}.testing_data, 'testing_weight', cv_data2{i}.testing_weight);
end

ABE2 = zeros(1, 10);
for i=1:10,
    ABE2(i) = sum(sum(abs((result2{i}.predicted -result2{i}.testing_data) .* (result2{i}.testing_weight~=0))))/10000;
end

figure10 = figure;
plot(ABE2, 'bo');
xlabel('Test');
ylabel('Average absolute error');
title('Average absolue error for Method 2');
print(figure10, '-djpeg', './3_2.jpg', '-r50');

max(ABE2);
% 0.0179
min(ABE2);
% 0.0139
mean(ABE2);
% 0.0154

%%%%%%
% Q4 %
%%%%%%
indices = find(W1);

actual_preference = R1 > 3;
actual_prefer_indices = find(actual_preference);
actual_prefer_size = size(actual_prefer_indices, 1);

% Method 1 k=100, lambda = 0.1
predicted_preference1 = zeros(943, 1682);
for i=1:10,
    predicted_preference1(result1{i}.indice) = result1{i}.predicted(result1{i}.indice);
end

precision1 = zeros(1, 100000);
recall1 = zeros(1, 100000);

for i=1:100000,
    if mod(i, 100)==0,
        disp(['Got: ',num2str(i)]);
    end
    threshold = predicted_preference1(indices(i));
    predicted_prefer = predicted_preference1 > threshold;
    TP = sum(sum(predicted_prefer & actual_preference));
    predicted_prefer_size = size(find(predicted_prefer), 1);
    precision1(i) = TP / predicted_prefer_size;
    recall1(i) = TP/actual_prefer_size;
end

% Method 2 k=100, lambda = 0.1
predicted_preference2 = zeros(943, 1682);
for i=1:10,
    predicted_preference2(result2{i}.indice) = result2{i}.predicted(result2{i}.indice);
end

precision2 = zeros(1, 100000);
recall2 = zeros(1, 100000);

for i=1:100000,
    if mod(i, 100)==0,
        disp(['Got: ',num2str(i)]);
    end
    threshold = predicted_preference2(indices(i));
    predicted_prefer = predicted_preference2 > threshold;
    TP = sum(sum(predicted_prefer & actual_preference));
    predicted_prefer_size = size(find(predicted_prefer), 1);
    precision2(i) = TP / predicted_prefer_size;
    recall2(i) = TP/actual_prefer_size;
end

[recall_sorted_1, order_1] = sort(recall1);
precision_sorted_1 = precision1(order_1);
[recall_sorted_2, order_2] = sort(recall2);
precision_sorted_2 = precision2(order_2);
figure11 = figure;
plot(recall_sorted_1, precision_sorted_1, 'r-', recall_sorted_2, precision_sorted_2, 'b-');
legend('Method 1', 'Method 2');
xlabel('Recall');
ylabel('Precision');
title('Precision-Recall graph');
print(figure11, '-djpeg', './4.jpg', '-r50');

%%%%%%
% Q6 %
%%%%%%

% Calculating precision
TP_5_1 = 0;
for i=1:943,
    [sorted, order] = sort(predicted_preference1(i,:), 'descend');
    TP_5_1 = TP_5_1 + sum(actual_preference(i,order(1:5)));
end
precision_5_1 = TP_5_1/ (5 * 943);% 0.7048
recall_5_1 = TP_5_1/actual_prefer_size;% 0.06

TP_5_2 = 0;
for i=1:943,
    [sorted, order] = sort(predicted_preference2(i,:), 'descend');
    TP_5_2 = TP_5_2 + sum(actual_preference(i,order(1:5)));
end
precision_5_2 = TP_5_2/ (5 * 943);% 0.5599
recall_5_2 = TP_5_2/actual_prefer_size;% 0.0477

% Hit rate - False alarm rate
HR1 = zeros(1, 1682);
FR1 = zeros(1, 1682);
for i=1:1682,
    disp(['Got: ', num2str(i)]);
    hit = 0;
    for j=1:943,
        [sorted, order] = sort(predicted_preference1(j,:), 'descend');
        hit = hit+ sum(actual_preference(j, order(1:i)));
    end
    HR1(i) = hit / actual_prefer_size;
    FR1(i) = (i*943 - hit)/(100000 - actual_prefer_size);
end

HR2 = zeros(1, 1682);
FR2 = zeros(1, 1682);
for i=1:1682,
    disp(['Got: ', num2str(i)]);
    hit = 0;
    for j=1:943,
        [sorted, order] = sort(predicted_preference2(j,:), 'descend');
        hit = hit+ sum(actual_preference(j, order(1:i)));
    end
    HR2(i) = hit / actual_prefer_size;
    FR2(i) = (i*943 - hit)/(100000 - actual_prefer_size);
end

figure12 = figure;
plot(FR1, HR1, 'r-', FR2, HR2, 'b-');
legend('Method 1', 'Method 2');
xlabel('False rate');
ylabel('Hit rate');
title('Hit rate - False rate graph');
print(figure12, '-djpeg', './6.jpg', '-r50');
