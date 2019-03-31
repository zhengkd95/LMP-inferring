function flowlimit = Pf_limit(gen,loads,f,t,x,REF,f0,t0)
    nl = length(f);
    nb = size(gen,1);
    Cf = sparse(1:nl, f, ones(nl, 1), nl, nb);
    Ct = sparse(1:nl, t, ones(nl, 1), nl, nb);
    A = Cf-Ct;
    A(:,REF) = [];
    D = diag(x);
    B = A'*D*A;
    T = [zeros(nl,1),D*A*B^(-1)];
    Pf = T*(gen-loads);
    flowlimit = zeros(nl,1);
    idx = [];
    for i = 1:length(f0)
        idx = [idx; find(f==f0(i) & t==t0(i))];
        flowlimit(idx(i)) = max(abs(Pf(idx(i),:)));
    end
    
end