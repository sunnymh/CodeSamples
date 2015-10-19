function [ A,Y, residuals, numIter, finalResidual ] = wnmfrule_sparse( X, W, k, lambda )
%WNMFRULE_SPARSE This code is modified from wnmfrul.m

option.distance='ls';
option.iter=5000;
option.dis=true;
option.residual=1e-4;
option.tof=1e-4;

residuals = zeros(1, floor(option.iter/10));

% iter: number of iterations
[r,c]=size(X); % c is # of samples, r is # of features
Y=rand(k,c);
% Y(Y<eps)=0;
Y=max(Y,eps);
A=X/Y;
% A(A<eps)=0;
A=max(A,eps);
XfitPrevious=Inf;
for i=1:option.iter
    switch option.distance
        case 'ls'
            A=A.*(((W.*X)*Y' - lambda * A)./((W.*(A*Y))*Y'));
%             A(A<eps)=0;
                A=max(A,eps);
            Y=Y.*((A'*(W.*X) - lambda * Y)./(A'*(W.*(A*Y))));
%             Y(Y<eps)=0;
                Y=max(Y,eps);
        case 'kl'
            error('Not implemented yet');
        otherwise
            error('Please select the correct distance: option.distance=''ls''; or option.distance=''kl'';');
    end
    if mod(i,10)==0 || i==option.iter
        if option.dis
            disp(['Iterating >>>>>> ', num2str(i),'th']);
        end
        XfitThis=A*Y;
        fitRes=matrixNorm(W.*(XfitPrevious-XfitThis));
        XfitPrevious=XfitThis;
        curRes=norm(W.*(X-XfitThis),'fro');
        disp(['>>>>>> ', num2str(curRes)]);
        residuals(floor(i/10)) = curRes;
        if option.tof>=fitRes || option.residual>=curRes || i==option.iter
            s=sprintf('Mutiple update rules based NMF successes! \n # of iterations is %0.0d. \n The final residual is %0.4d.',i,curRes);
            disp(s);
            numIter=i;
            finalResidual=curRes;
            break;
        end
    end
end

end

