function [ projected_image ] = project_image( im_vec, eigen_vecs )
%PROJECT_IMAGE Summary of this function goes here
%   Detailed explanation goes here
projected_image = zeros(1, size(eigen_vecs, 1));
for i = 1:size(eigen_vecs, 2),
    eigen_vec = eigen_vecs(:, i);
    projected_image = projected_image + (im_vec * eigen_vec)/(norm(eigen_vec)^2)*eigen_vec';
end
end

