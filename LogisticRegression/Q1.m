%Q1
X = [0 3; 1 3; 0 1; 1 1];
X = add_constant(X);
Y = [1; 1; 0; 0];
lambda = 0.07;
beta0 = [-2; 1; 0];

[mu0, beta1] = update_beta( X, Y, lambda, beta0 );

[mu1, beta2] = update_beta( X, Y, lambda, beta1 );
