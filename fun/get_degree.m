function degree = get_degree(mpc)

REF = find(mpc.bus(:,2) == 3);
B = makeBmatrix(mpc);
L = get_lap(B,REF);
degree = diag(L);

end