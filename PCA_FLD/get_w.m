function [ w ] = get_w( C, distance )
%GET_W Summary of this function goes here
%   Detailed explanation goes here
B = C'*C;

[eigen_vec_small, eigen_value_gender] = eig(B);

V = zeros(size(C,2), size(C, 2));
for i=1:153,
    V(:,i) = eigen_vec_small(:,i)/norm(eigen_vec_small(:,i));
end

A = zeros(size(C,1), size(C,2));
for i=1:size(C,2),
    A(:,i) = eigen_value_gender(i,i)^0.5 * C * V(:,i) / norm(C * V(:,i));
end


y = A'* distance;
z = (eigen_value_gender * eigen_value_gender * V')\ y;
w = C * z;


end

