function [ labels ] = nn_predict( feature_matrix, weights )
%PREDICT_NN Given a matrix of data, return the prediction their label
ndata = size(feature_matrix, 1);
labels = zeros(1,ndata);
for i=1:ndata,
    [S, X] = apply_forward(feature_matrix(i,:), weights);
    [m,n] = max(X{size(weights, 2)});
    labels(i) = n-1;
end
end

