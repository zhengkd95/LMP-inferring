function B = makeBmatrix(mpc)
from = mpc.branch(:,1);
to = mpc.branch(:,2);
nl = length(from);
nb = length(mpc.bus(:,1));
REF = find(mpc.bus(:,2)==3);

Cf = sparse(1:nl, from, ones(nl, 1), nl, nb);
Ct = sparse(1:nl, to, ones(nl, 1), nl, nb);
A = Cf-Ct;
A(:,REF) = [];

x = mpc.branch(:,4);
D = diag(1./x);
B = A'*D*A;

end