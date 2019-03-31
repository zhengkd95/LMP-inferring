function B = B_estimate(PI,k,avg_degree,e)
% function B = B_estimate(PI,REF,k,avg_degree,e)
% The original non-convex problem:
% min norm(B*PI,0)+k*norm(B*e,0)
% s.t. B>0, B*e>0

% This function aims to solve the convex opt problem:
% min norm(B*PI,1)+k1*tr(PB)-k2*log|B|+k3*norm(B*e,1)
% s.t. B>0, B<=I, B*e>0

if nargin < 4
    e = 1e-3;
    if nargin < 3
        avg_degree = 0;
    end
end

kappa1 = k(1);
kappa2 = k(2);
kappa3 = k(3);
nb = size(PI,1)+1;

B_solve = sdpvar(nb-1,nb-1);
I = eye(nb-1);
P = I - ones(nb-1,nb-1);
E = ones(1,nb-1);

F = [B_solve(:) <= I(:), B_solve*E' >= 0]; %,... 
    % diag(B_solve) >= 1/(10*nb)*E' ];
%f = norm(B_solve*PI,1)+kappa1*trace(P*B_solve)-kappa2*logdet(B_solve)+kappa3*norm(E*B_solve,1);
%f = sum(sqrt(sum((B_solve*PI).^2,2)))+kappa1*sum(sqrt(sum(B_solve.^2,2)))-kappa2*logdet(B_solve)+kappa3*norm(E*B_solve,1);
%f = sum(sqrt(sum((B_solve*PI).^2,2)))+kappa1*trace(P*B_solve)-kappa2*logdet(B_solve)+kappa3*norm(E*B_solve,1);
f = norm(B_solve*PI,1)+kappa1*sum(sqrt(sum(B_solve.^2,2)))-kappa2*logdet(B_solve)+kappa3*norm(E*B_solve,1);

optimize(F,f,sdpsettings('solver','sdpt3'));

BS = value(B_solve);

if avg_degree>0
    degree = mean(diag(BS));
    B = BS * avg_degree/degree; 
else 
    B = BS;
end
B(abs(B)<e) = 0;

end