function mpc2 = create_mpc(mpc, f, t, x, limit)
    mpc2 = mpc;
    nl = length(f);
    r = zeros(nl,1);
    b = zeros(nl,1);
    rateA = limit;
    rateB = limit;
    rateC = limit;
    ratio = zeros(nl,1);
    angle = zeros(nl,1);
    status = ones(nl,1);
    angmin = -360 * ones(nl,1);
    angmax = 360 * ones(nl,1);
    mpc2.branch = [f,t,r,x,b,rateA,rateB,rateC,ratio,angle,status,angmin,angmax];


end