function [ output_images_struct ] = format_images( images_struct )
%Q3: Change each image to a 1*784 double vector and nomalize it.
features = images_struct.images;
dim = size(features);
features = permute(features, [2 1 3]);
feature_matrix = reshape(features, [dim(1)*dim(2) dim(3)])';
feature_matrix = double(feature_matrix);
for i = 1:dim(3),
    row = feature_matrix(i, :);
    feature_matrix(i, :) = double(row/norm(row));
end
label_vector = double(images_struct.labels);
output_images_struct = struct('images', feature_matrix, 'labels', label_vector);
end

