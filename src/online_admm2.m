function output = online_admm2(Prices,k,Bo)
% The modified method
% output = online_admm2(Prices,k,Bo);
% It solves the online convex recovery scheme using online ADMM (Banerjee's) on matrix Prices,
% having parameters k = [k1 k2 k3], and with possible initialization at Bo.
% If length(k)==3, then the Huber option is activated, otherwise it is only
% the ell-1 norm cost.

[N,T] = size(Prices);

huber = (length(k)==3);

% admm parameter
rho = sqrt(T);
eta = sqrt(T);
% cost = zeros(ITER,1);

errorIsBig = true;
iteration = 0;

e = ones(N,1);
%% INITIALIZATION
if nargin<=2,
    % primal variables
    B1 = eye(N,N); B2 = eye(N,N); B3 = eye(N,N); b = e;
    S = Prices;
    % dual variables
else
    B1 = Bo; B2 = Bo; B3 = Bo; b = Bo*e;
    S = Bo*Prices;
end;
M12 = zeros(N,N); 
M13 = zeros(N,N);
m10 = zeros(N,1);

P = eye(N) - ones(N,N);
Q = (2*rho+eta) * eye(N,N) + rho * (e * e');
[V,D,W] = eig(Q);
Q2 = W*(D.^0.5)*W';
Q2 = Q2^(-1);

%% TIME ITERATIONS
output.B3 = zeros(N,N,T);
for time = 1:T,
    tic;
    %% B1 update
    B1c = rho*(B2 + B3 - M12 - M13 + b * e' - m10 * e' + ...
        eta/rho*B1 - k(1)/(T*rho)*P) * Q2 ;
    pt = Q2 * Prices(:,time);
    if huber,
        B1 = modulehuber(pt,B1c,1,k(3)) * Q2;
    else
        B1 = modulel1(pt,B1c) * Q2;
    end;    
    
    %% B2 update
    B2 = min(B1+M12,eye(N));
    
    %% B3 update
    Temp = B1 + M13;
    Temp = (Temp + Temp')/2;    % symmetricized
    [U,v] = eig(Temp);
    v = diag(v);
    B3 = U*diag(v + sqrt(v.^2 + 4*k(2)/T/rho))*U'/2;
    output.B3(:,:,time) = B3;
    
    %% b update
    b = module_b(B1*e+m10, k(1)/(N-1)/T/rho);
    
    %% Lagrange multipliers update
    M12 = M12 + B1 - B2;
    M13 = M13 + B1 - B3;
    m10 = m10 + B1*e - b;
    cost(time) = sum(sum(abs(S))) + k(1)*trace(P*B1) - k(2)*log(det(B3)) + k(1)/(N-1)*norm(b,1);
    
    %     disp(['Iteration ' num2str(iteration) '. Error ' num2str(error) '; Primal:' num2str(error_pri) '; Dual:' num2str(error_dual) '; Cost: ' num2str(cost(iteration))]);
    toc;
    if rem(time,1000) == 0
        plot_mat(B3,'jet','Br in IEEE case30');
    end
end;

output.B1 = B1;
output.B2 = B2;
output.B = B3;
output.b = b;
output.M12 = M12;
output.M13 = M13;
output.m10 = m10;
output.cost = cost;

clk = clock;
str = ['oADMM' num2str(clk(1)) '_' num2str(clk(2)) '_' num2str(clk(3)) '_' num2str(clk(4)) '.' num2str(clk(5)) '.' num2str(clk(6)) '.mat'];
save(['data/',str],'output');
