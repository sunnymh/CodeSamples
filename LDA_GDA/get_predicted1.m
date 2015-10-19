function [ predicted, error_rate ] = get_predicted1( test, mus, sigmas, priors, lambda )
%Q3: Return a structed of predicted labels and error rate of
%test given mus and sigmas for each class for question 4-3-a
%exp(-0.5 * trans(x-u_i) * inv(sigma) * (x-u_i)) * p(w)
dim = size(test.images);
estimated_sigma_overall = zeros(dim(2), dim(2));
predicted = zeros(1, dim(1));

for i = 1:10,
    estimated_sigma_overall = estimated_sigma_overall + sigmas{i};
end

estimated_sigma_overall = estimated_sigma_overall / 10;
estimated_sigma_overall = estimated_sigma_overall + lambda * eye(dim(2));
[e,lam]=eig(estimated_sigma_overall);
estimated_sigma_overall_inverse = e*diag(1./diag(lam))*e';

for i = 1:dim(1),
    x = transpose(test.images(i,:));
    pdf = zeros(1, 10);
   
    for j = 1:10,
        pdf(j) = exp(-0.5 * transpose(x - mus{j}) * estimated_sigma_overall_inverse * (x - mus{j})) * priors(j);
    end
    
    [val index] = max(pdf);
    predicted(i) = index - 1;
end
error_rate = 1 - sum(test.labels == transpose(predicted)) / dim(1);


