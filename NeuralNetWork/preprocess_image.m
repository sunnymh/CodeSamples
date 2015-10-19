function [ feature_matrix, label_matrix ] = preprocess_image( images_struct )
%PREPROCESS_IMAGE Preprocess a single cell of images
%INPUT: image struct
%RETURN: n * 785 feature matrix with bias added,  and labels
features = images_struct.images;
dim = size(features);
features = permute(features, [2 1 3]);
feature_matrix = reshape(features, [dim(1)*dim(2) dim(3)])';
feature_matrix = double(feature_matrix);
for i=1:dim(3),
    row = feature_matrix(i,:);
    feature_matrix(i,:) = row/norm(row);
end
feature_matrix = [ones(dim(3), 1) feature_matrix];
label_matrix = zeros(dim(3), 10);
for i = 1:dim(3),
    label_matrix(i, images_struct.labels(i) + 1) = 1;
end

