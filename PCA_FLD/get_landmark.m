function [ landmark ] = get_landmark( landmark_vector, landmark_size )
%GET_LANDMARK Summary of this function goes here
%   Detailed explanation goes here
landmark = reshape(landmark_vector, landmark_size(1), landmark_size(2));
end

