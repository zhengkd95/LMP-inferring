function db2 = line_reduce(db, mdata, REF, time)
% function [L2, f2, t2, x2, T2] = line_reduce(limit, L2, f2, t2, REF)
    j = find(db.flowlimit == min(db.flowlimit));
    m = find(db.A(j,:)==1);
    n = find(db.A(j,:)==-1);
    L2 = db.Lap;
    L2(m,m) = L2(m,m) + L2(m,n);
    L2(n,n) = L2(n,n) + L2(m,n);
    L2(m,n) = 0;
    L2(n,m) = 0;
    db2 = L2A(L2,REF);
    Pf = diag(db2.x)*db2.Ar*db2.Bri* ...
        (mdata.gen(2:end,time)-mdata.loads(2:end,time) );
    db2.flowlimit = max(abs(Pf),[],2);
end