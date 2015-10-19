xtrain = [4 5 3 1 2 2];
ytrain = [0 1 0 0];

result1 = zeros(4, 4);
for i = 1:4,
    for j = 1:4,
       
        weightsl = cell(1, 3);
        weightsl{1} = ones(6, 4)* 1e-3;
        weightsl{2} = ones(4, 4)* 1e-3;
        weightsl{3} = ones(4, 4) *1e-3;
        weightsl{3}(i,j) = weightsl{3}(i,j) - 1e-5;

        weightsr = cell(1, 3);
        weightsr{1} = ones(6, 4) * 1e-3;
        weightsr{2} = ones(4, 4) * 1e-3;
        weightsr{3} = ones(4, 4) * 1e-3;
        weightsr{3}(i,j) = weightsr{3}(i,j) + 1e-5;

        msel = loss_mse(xtrain, ytrain, weightsl);
        mser = loss_mse(xtrain, ytrain, weightsr);

        result1(i, j) = (mser - msel) / 2e-5;
    end
end