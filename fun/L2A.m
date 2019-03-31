function db = L2A(L,REF)
    db.N = size(L,1);
    f = [];t = [];x = [];
    for i = 1:db.N-1
        for j = i+1:db.N
            if abs(L(i,j)) > 1e-3
                f = [f;i];
                t = [t;j];
                x = [x;1/abs(L(i,j))];
            end
        end
    end
    nl = length(f);
    Cf = sparse(1:nl, f, ones(nl, 1), nl, db.N);
    Ct = sparse(1:nl, t, ones(nl, 1), nl, db.N);
    db.A = Cf-Ct;
    db.Ar = db.A;
    db.Ar(:,REF) = [];
    db.x = 1./x;
    db.Lap = L;
    db.L = nl;
    db.Br = db.Ar' * diag(db.x) * db.Ar;
    db.Bri = db.Br^(-1);
end