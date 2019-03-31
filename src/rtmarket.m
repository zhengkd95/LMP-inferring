function market = rtmarket(db, h)
% function market = rtmarket(h);
% Function for running the real-time market corresponding to a single 5-min
% interval in the hour indicated by input h. Piece-wise linear up to 5
% implemented.
% After loading the database file db30.mat (see nced.m), it draws randomly costs and load demands,
% and then solves the linear program involved using YALMIP. Lagrange
% multipliers and prices are stored in output structure market.

% load db30.mat

%% sample random quantities
loads = db.loads(:,h) + sqrt(db.loads(:,h)/10).*randn(db.N,1);
market.loads = loads;
market.rare = 0;

c = db.c + (((rand(db.N,1) - 0.5)*5) * ones(1,5)) .* (db.c~=0);
market.c = c;
%% Solve market using yalmip
tic,
settings = sdpsettings('solver','cplex','verbose',0);
clear('yalmip')
P = sdpvar(db.N,5);
F = [(db.pmin<=P):'Pmin', (P<=db.pmax):'Pmax', ...
    (sum(loads-sum(P,2))==0):'balance',...
    (-db.flowlimit<=diag(db.x)*db.Ar*db.Bri*(sum(P(2:end,:),2)-loads(2:end) )):'conlow',...
    (diag(db.x)*db.Ar*db.Bri*(sum(P(2:end,:),2)-loads(2:end) )<=db.flowlimit):'conhigh'];

diagnostic = optimize(F,c(:)'*P(:),settings);
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
    if max(abs(market.price)) > 1.5e2
        market.rare = 1;
    end
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
fprintf('Demand: %g. Capacity: %g. %s Time: %g\n', sum(loads),sum(sum(db.pmax)),str,t)
%disp(['Demand: ' num2str(sum(loads)) '. Capacity: ' num2str(sum(sum(db.pmax))) '. ' str])

