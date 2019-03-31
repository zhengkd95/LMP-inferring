% initialize
l0 = 0;
LF = zeros(db.N,1);
D = zeros(db.N,1);
market = dc_opf_Litvinov(dailyload,db.c,db.T,db.flowlimit,db.pmin,db.pmax,LF,l0,D);
% solve dc power flow
mpc.bus(:,3) = dailyload;
mpc.gen(:,2) = market.p(mpc.gen(:,1));
pf_results = runpf(mpc, mpopt);
% update parameters
r = mpc.branch(:,3);
l0_temp = l0;
p_branch = (pf_results.branch(:,14) - pf_results.branch(:,16))/2;
p_branch = p_branch / mpc.baseMVA;
LF = 2*(r.*p_branch)'*db.T;
LF = LF';
Pg = zeros(db.N,1);
Pg(pf_results.gen(:,1),1) = pf_results.gen(:,2);
l0 = market.loss - LF'*(Pg-dailyload);
from = mpc.branch(:,1);
to = mpc.branch(:,2);
Ei = zeros(db.N,1);
for i = 1:db.N
    Mi = find(from == i | to == i);
    Ei(i) = 0.5 * p_branch(Mi)'.^2 * r(Mi);
end
D = Ei/sum(Ei);
% convergence
while abs(l0_temp-l0)>=1e-3 
    l0_temp = l0;
    market = dc_opf_Litvinov(dailyload,db.c,db.T,db.flowlimit,db.pmin,db.pmax,LF,l0,D);
    mpc.gen(:,2) = market.p(mpc.gen(:,1));
    pf_results = runpf(mpc, mpopt);
    p_branch = (pf_results.branch(:,14) - pf_results.branch(:,16))/2;
    p_branch = p_branch / mpc.baseMVA;
    LF = 2*(r.*p_branch)'*db.T;
    LF = LF';
    Pg = zeros(db.N,1);
    Pg(pf_results.gen(:,1),1) = pf_results.gen(:,2);
    l0 = market.loss - LF'*(Pg-dailyload);
    from = mpc.branch(:,1);
    to = mpc.branch(:,2);
    Ei = zeros(db.N,1);
    for i = 1:db.N
        Mi = find(from == i | to == i);
        Ei(i) = 0.5 * p_branch(Mi)'.^2 * r(Mi);
    end
    D = Ei/sum(Ei);
end
