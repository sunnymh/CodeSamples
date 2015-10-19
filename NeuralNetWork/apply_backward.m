function [ deltas ] = apply_backward( S, X, ytrain_point, weights, is_mse)
%APPLY_BACKWARD backward step
%  INPUT: 
%    X: result from apply_forward for given point
%    ytrain_point: y for the given point, vector of 0, 1
            
%  RETURN: cells, the k's cell contains a vector of de/dw for the k'th
%   layer

% initialized cell dedw
% for  i = L, L-1, ....1,
%       dedw{i} = ...

nlayers = size(weights, 2);
deltas = cell(1, nlayers);
ytrain_point = transpose(ytrain_point);

if is_mse
    deltas{nlayers} = loss_mse_gradient(X{nlayers}, ytrain_point) .* transfer_func_sigmoid_derivative(S{nlayers}); 
else
    deltas{nlayers} = loss_cee_gradient(X{nlayers}, ytrain_point) .* transfer_func_sigmoid_derivative(S{nlayers}); 
end

for i = (nlayers-1):-1:1,
    deltas{i} = transfer_func_tanh_derivative(S{i}) .* (weights{i+1} * deltas{i+1});
end
end

