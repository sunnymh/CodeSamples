function [ predicted, error_rate ] = get_predicted2( test, mus, sigmas, priors, lambda, alpha )
%Q3: Return a structed of predicted labels and error rate of
%test_stuct given mus and sigmas for each class for question 4-3-b
%exp(-0.5 * trans(x-u_i) * inv(sigma_i) * (x-u_i)) * p(w) / sqrt(|sigma_i|)
dim = size(test.images);
predicted = zeros(1, dim(1));

% get the inverse of sigmas:
sigmas_inverse = cell(1, 10);
for i = 1:10,
   sigma = sigmas{i} + lambda * eye(dim(2));
   [e,lam]=eig(sigma);
   sigmas_inverse{i} = e*diag(1./diag(lam))*e';
end

% get the sqrt(|sigma_i|)
sqrt_det = zeros(1,10);
for i = 1:10,
    sqrt_det(i) = det((sigmas{i} + lambda * eye(dim(2)))  * alpha)^0.5;
end

% find the class belongs to
for i = 1:dim(1),
    x = transpose(test.images(i,:));
    pdf = zeros(1, 10);
   
    for j = 1:10,
        pdf(j) = exp(-0.5 * transpose(x - mus{j}) * sigmas_inverse{j} * (x - mus{j})) * priors(j) / sqrt_det(j);
    end
    
    [val index] = max(pdf);
    predicted(i) = index - 1;
end
error_rate = 1 - sum(test.labels == transpose(predicted)) / dim(1);

end

