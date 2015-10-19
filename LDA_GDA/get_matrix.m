function [ mat ] = get_matrix( train, d )
%Q1: Get the design matrix
mat = zeros(length(train), d);
for i = 1:d,
    mat(:,i) = train.^i;
end
