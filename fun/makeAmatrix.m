function A = makeAmatrix(mpc)

from = mpc.branch(:,1);
to = mpc.branch(:,2);
nl = length(from);
nb = length(mpc.bus(:,1));

Cf = sparse(1:nl, from, ones(nl, 1), nl, nb);
Ct = sparse(1:nl, to, ones(nl, 1), nl, nb);
A = Cf-Ct;

end