function mdata2 = get_lmp(db,mdata,time)
mdata2.S = [];
mdata2.M = [];
mdata2.Prices = [];
mdata2.index = [];
mdata2.mu0 = [];
settings = sdpsettings('solver','mosek','verbose',0);

for i = 1:length(time)
    if mod(i,20) == 0
        fprintf('%d',i)
    end
    h = time(i);
    loads = mdata.loads(:,h);
    c = mdata.c(:,:,h);
    % tic,
    P = sdpvar(db.N,5);
    F = [db.pmin<=P, P<=db.pmax, (sum(loads-sum(P,2))==0):'balance',...
    (-db.flowlimit<=diag(db.x)*db.Ar*db.Bri*(sum(P(2:end,:),2)-loads(2:end) )):'conlow',...
    (diag(db.x)*db.Ar*db.Bri*(sum(P(2:end,:),2)-loads(2:end) )<=db.flowlimit):'conhigh'];
    diagnostic = solvesdp(F,c(:)'*P(:),settings);
    if diagnostic.problem,
        %% typically infeasible problem
        market.mu0 = 0;
        market.mul = inf*ones(db.L,1);
        market.muh = inf*ones(db.L,1);
        market.p = zeros(db.N,1);
        market.P = zeros(db.N,1);
        market.s = zeros(db.N-1,1);
        market.price = zeros(db.N-1,1);
    else
        market.mu0 = double(dual(F('balance')));
        market.mul = double(dual(F('conlow'))) .* (abs(double(dual(F('conlow'))))>1e-6);
        market.muh = double(dual(F('conhigh'))) .* (abs(double(dual(F('conhigh'))))>1e-6);
        market.p = sum(double(P),2);
        market.P = double(P);
        market.s = db.Ar'*diag(db.x)*(market.mul-market.muh);
        market.price = db.Bri*market.s;
    end
    if diagnostic.problem,
        str = 'Infeasible.';
        market.success = 0;
        market.cong = 0;
    else
        market.success = 1;
        if sum(abs(market.mul-market.muh))==0,
            str = 'No congestion.';
            market.cong = 0;
        else
            str = '';
            market.cong = 1;
        end
    end
    % t = toc;
    % fprintf('Demand: %g. Capacity: %g. %s Time: %g\n', sum(loads),sum(sum(db.pmax)),str,t)
    %%
    % save the results
    mdata2.S = [mdata2.S, market.s];
    mdata2.M = [mdata2.M, market.muh-market.mul];
    mdata2.Prices = [mdata2.Prices, market.price];
    mdata2.mu0 = [mdata2.mu0, market.mu0];
    if market.success && market.cong
        mdata2.index = [mdata2.index, i];
    end
end



end