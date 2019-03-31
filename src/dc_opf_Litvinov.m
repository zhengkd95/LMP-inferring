function market = dc_opf_Litvinov(loads,c,T,flowlimit,pmin,pmax,LF,l0,D)
% market = dc_opf_Litvinov(loads,c,T,flowlimit,pmin,pmax,loss,LF,l0,D)
% 
N = size(T,2);
% T(:,ref) = [];
market.loads = loads;
market.c = c;
tic,
settings = sdpsettings('solver','cplex','verbose',0);
clear('yalmip')
P = sdpvar(N,5);
loss = sdpvar(1);
F = [(pmin<=P):'Pmin', (P<=pmax):'Pmax', ...
    (sum(loads-sum(P,2))+loss==0):'balance',...
    (loss == LF'*(sum(P,2)-loads)+l0):'loss',...
    (-flowlimit<=T*(sum(P(1:end,:),2)-loads(1:end)-D*loss )):'conlow',...
    (T*(sum(P(1:end,:),2)-loads(1:end)-D*loss )<=flowlimit):'conhigh'];

diagnostic = optimize(F,c(:)'*P(:),settings);

if diagnostic.problem,
    %% typically infeasible problem
    market.mu0 = 0;
    %market.mul = inf*ones(db.L,1);
    %market.muh = inf*ones(db.L,1);
    market.p = zeros(N,1);
    market.P = zeros(N,1);
    % market.s = zeros(db.N-1,1);
    market.price = zeros(N,1);
    market.MEP = zeros(N,1);
    market.MCP = zeros(N,1);
    market.MLP = zeros(N,1);
    market.loss = 0;
else
    market.mu0 = double(dual(F('balance')));
    market.mul = double(dual(F('conlow'))) .* (abs(double(dual(F('conlow'))))>1e-6);
    market.muh = double(dual(F('conhigh'))) .* (abs(double(dual(F('conhigh'))))>1e-6);
    market.tau = double(dual(F('loss')));
    market.p = sum(double(P),2);
    market.P = double(P);
    market.loss = double(loss);
    % market.s = db.Ar'*diag(db.x)*(market.mul-market.muh);
    % market.price = T'*(market.mul - market.muh);
    market.MEP = -market.tau * ones(N,1);
    market.MLP = market.tau * LF;
    market.MCP = T' * (market.mul-market.muh) - (T*D*ones(1,N))' * (market.mul-market.muh);
    market.price = market.MEP + market.MLP + market.MCP;
    % if max(abs(market.price)) > 1.5e1
    %     market.rare = 1;
    % end
end;

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
    end;
end;
t = toc;
% fprintf('Demand: %g. Capacity: %g. %s Time: %g\n', sum(loads),sum(sum(pmax)),str,t)

end