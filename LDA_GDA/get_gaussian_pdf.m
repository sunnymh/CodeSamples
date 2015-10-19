function [ density ] = get_gaussian_pdf( mu, cov, x1, x2 )
%Q2: Get densities of of each point given x1, x2 axises
[X1,X2] = meshgrid(x1,x2);
F = mvnpdf([X1(:) X2(:)],mu,cov);
density = reshape(F,length(x2),length(x1));
end

