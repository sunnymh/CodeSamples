% Solution for Q2

% 1
mu = [1 1];
cov = [2 0; 0 1];
x1 = -5:0.2:5;
x2 = -5:0.2:5;
density = get_gaussian_pdf( mu, cov, x1, x2 );
figure();
contour( x1, x2, density );
xlabel('x1'); 
ylabel('x2');
colorbar;
%saveas(f, 'writeup/2-1.png');

%2
mu = [-1 2];
cov = [3 1; 1 2];
x1 = -5:0.2:5;
x2 = -5:0.2:5;
density = get_gaussian_pdf( mu, cov, x1, x2 );
figure();
contour( x1, x2, density );
xlabel('x1'); 
ylabel('x2');
colorbar;
%saveas(f, 'writeup/2-2.png');

%3
mu1 = [0 2];
mu2 = [2 0];
cov = [1 1; 1 2];
x1 = -5:0.2:5;
x2 = -5:0.2:5;
density1 = get_gaussian_pdf( mu1, cov, x1, x2 );
density2 = get_gaussian_pdf( mu2, cov, x1, x2 );
figure();
contour( x1, x2, density1-density2 );
xlabel('x1'); 
ylabel('x2');
colorbar;
%saveas(f, 'writeup/2-3.png');

%4
mu1 = [0 2];
mu2 = [2 0];
cov1 = [1 1; 1 2];
cov2 = [3 1; 1 2];
x1 = -5:0.2:5;
x2 = -5:0.2:5;
density1 = get_gaussian_pdf( mu1, cov1, x1, x2 );
density2 = get_gaussian_pdf( mu2, cov2, x1, x2 );
figure();
contour( x1, x2, density1-density2 );
xlabel('x1'); 
ylabel('x2');
colorbar;
%saveas(f, 'writeup/2-4.png');

%5
mu1 = [1 1];
mu2 = [-1 -1];
cov1 = [1 0; 0 2];
cov2 = [2 1; 1 2];
x1 = -5:0.2:5;
x2 = -5:0.2:5;
density1 = get_gaussian_pdf( mu1, cov1, x1, x2 );
density2 = get_gaussian_pdf( mu2, cov2, x1, x2 );
figure();
contour( x1, x2, density1-density2 );
xlabel('x1'); 
ylabel('x2');
colorbar;
%saveas(f, 'writeup/2-5.png');


