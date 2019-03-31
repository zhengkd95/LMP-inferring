function B = B_partial(PI,k,row,col,val)

kappa1 = k(1);
kappa2 = k(2);
kappa3 = k(3);
e = 1e-3;
nb = size(PI,1)+1;

B_solve = sdpvar(nb-1,nb-1);
I = eye(nb-1);
P = I - ones(nb-1,nb-1);
E = ones(1,nb-1);

F = [B_solve(:) <= I(:), B_solve*E' >= 0]; 

for i = 1:length(row)
    F = [F; B_solve(row(i), col(i)) == val(i) ];
end

optimize(F,norm(B_solve*PI,1)+kappa1*trace(P*B_solve)-kappa2*logdet(B_solve)+kappa3*norm(E*B_solve,1),sdpsettings('solver','sdpt3'));

B = value(B_solve);

B(abs(B)<e) = 0;

end