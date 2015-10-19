function [ a ] = transfer_func_sigmoid( vec )
%FUNC_SIGMOID Takes a vector and transfer to sigmoid
a = 1.0 ./ (1.0 + exp(-vec));
end

