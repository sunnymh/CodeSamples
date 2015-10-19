function [ im_vec_reconst, errors ] = reconstruct_image( im_vec, eigenfaces )
%RECONSTRUCT_FACE Summary of this function goes here
%   Detailed explanation goes here
im_vec_reconst = zeros(1, size(eigenfaces, 1));
errors = zeros(1, size(eigenfaces, 2));
for i = 1:size(eigenfaces, 2),
    eigenface = eigenfaces(:, i);
    im_vec_reconst = im_vec_reconst + (im_vec * eigenface)/(norm(eigenface)^2)*eigenface';
    errors(i) = sum((im_vec - im_vec_reconst).^2);
end
end

