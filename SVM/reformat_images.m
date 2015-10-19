function [ output_images_struct ] = reformat_images( images_struct )
%CREATE_TRAINING_INSTANCE_MATRIX : Create the feature matrix for an image array
features = images_struct.images;
dim = size(features);
features = permute(features, [2 1 3]);
feature_matrix = reshape(features, [dim(1)*dim(2) dim(3)])';
feature_matrix = sparse(double(feature_matrix));
label_vector = double(images_struct.labels);
output_images_struct = struct('matrix', feature_matrix, 'label', label_vector);
end

