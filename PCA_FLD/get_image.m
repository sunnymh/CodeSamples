function [ image ] = get_image( image_vector, image_size )
% This function takes in a (1, 256*256) and return a 256*256 matrix
    image = uint8(reshape(image_vector, image_size(1), image_size(2)));
end

