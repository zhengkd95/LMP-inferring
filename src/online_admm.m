function output = online_admm(Prices,k,Bo)
% output = online_admm(Prices,k,Bo);
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

%% INITIALIZATION
if nargin<=2,
    % primal variables
    B1 = eye(N,N); B2 = eye(N,N); B3 = eye(N,N);
    S = Prices;
    % dual variables
else
    B1 = Bo; B2 = Bo; B3 = Bo;
    S = Bo*Prices;
end;
M12 = zeros(N,N); 
M13 = zeros(N,N);

P = eye(N) - ones(N,N);

%% TIME ITERATIONS
output.B3 = zeros(N,N,T);
for time = 1:T,
    tic;
    %% B1 update
    B1c = rho/(2*rho+eta)*(B2 + B3 - M12 - M13) + (eta/(2*rho+eta))*B1 - k(1)/(2*T*(2*rho+eta))*P;
    if huber,
        B1 = modulehuber(Prices(:,time),B1c,1/(2*rho+eta),k(3));
    else
        B1 = modulel1(Prices(:,time)/(2*rho+eta),B1c);
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
    
    %% Lagrange multipliers update
    M12 = M12 + B1 - B2;
    M13 = M13 + B1 - B3;
    
    cost(time) = sum(sum(abs(S))) + k(1)*trace(P*B1) - k(2)*log(det(B3));
    
    %     disp(['Iteration ' num2str(iteration) '. Error ' num2str(error) '; Primal:' num2str(error_pri) '; Dual:' num2str(error_dual) '; Cost: ' num2str(cost(iteration))]);
    toc
end;

output.B1 = B1;
output.B2 = B2;
output.B = B3;
output.M12 = M12;
output.M13 = M13;
output.cost = cost;

clk = clock;
str = ['oADMM' num2str(clk(1)) '_' num2str(clk(2)) '_' num2str(clk(3)) '_' num2str(clk(4)) '.' num2str(clk(5)) '.' num2str(clk(6)) '.mat'];
save(['data/',str],'output');