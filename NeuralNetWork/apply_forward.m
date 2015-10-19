function [ S, X ] = apply_forward( xtrain_point, weights )
%GET_STOCHASTIC_GRADIENT forward step
%RETURN: S and X. Cells, the k's cell contains a vector of si or xi at level k

% initialized
nlayers = size(weights, 2);
S = cell(1, nlayers);
X = cell(1, nlayers);
xtrain_point = transpose(xtrain_point);

% compute S and X
S{1} = transpose(weights{1}) * xtrain_point;
if nlayers==1
    X{1} = transfer_func_sigmoid(S{1});
else
    X{1} = transfer_func_tanh(S{1});
    for i=2:(nlayers-1),
        S{i} = transpose(weights{i}) * X{i-1};
        X{i} = transfer_func_tanh(S{i});
    end
    S{nlayers} = transpose(weights{nlayers}) * X{nlayers - 1};
    X{nlayers} = transfer_func_sigmoid(S{nlayers});
end
end

