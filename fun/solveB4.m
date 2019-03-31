function B_solve = solveB4(B1, M14, rho, k, T)

N = size(B1, 1);
B_solve = zeros(N,N);

C = B1 + M14;
rowC = sqrt(sum(C.^2,2));
idx = rho*rowC > k(1)/T;

rowB = (rho*rowC(idx)-k(1)/T)/rho;
B_solve(idx,:) = rho*C(idx,:)./(rho + k(1)/T./rowB);

end