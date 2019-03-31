function output = online_admm3(Prices, k, mpc, B_origin, lossless, KnownPart, B0)

T = size(Prices,2);
N = size(mpc.bus,1)-1;

rho = sqrt(T);
eta = sqrt(T);

e = ones(N,1);

if nargin<=6
    % primal variables
    B1 = eye(N,N); B2 = eye(N,N); B3 = eye(N,N); B4 = eye(N,N); B5 = eye(N,N);
    b = ones(N,1);
    % dual variables
else
    B1 = B0; B2 = B0; B3 = B0; B4 = B0;
    b = B0*e; 
end
M12 = zeros(N,N); 
M13 = zeros(N,N);
M14 = zeros(N,N);
M15 = zeros(N,N);
m10 = zeros(N,1);

Q = (4*rho+eta) * eye(N,N) + rho * (e * e');
[V,D,W] = eig(Q);
Q2 = W*(D.^0.5)*W';
Q2 = Q2^(-1);

output.B = zeros(N,N,T);
for t = 1:T
    %tic;
    xt = Prices(:,t);
    %% B1 update
    B1 = solveB1(xt, Q2, B1, B2, B3, B4, B5, M12, M13, M14, M15, m10, b, rho, eta, k, lossless);
    output.B(:,:,t) = B1;
    %B1 = complete(B1, t, B_origin, KnownPart, mpc);
    %% B2 update
    B2 = min(B1+M12,eye(N));
    %B2 = complete(B2, t, B_origin, KnownPart, mpc);
    %% B3 update
    Temp = B1 + M13;
    Temp = (Temp + Temp')/2;    % symmetricized
    [U,v] = eig(Temp);
    v = diag(v);
    B3 = U*diag(v + sqrt(v.^2 + 4*k(2)/T/rho))*U'/2;
    %B3 = complete(B3, t, B_origin, KnownPart, mpc);
    %% B4 update
    B4 = solveB4(B1, M14, rho, k, T);
    %B4 = complete(B4, t, B_origin, KnownPart, mpc);    
    %% B5 update
    B5 = B1 + M15;
    B5 = complete(B5, t, B_origin, KnownPart, mpc);
    %output.B(:,:,t) = B5;
    %% b update
    b = module_b(B1*e+m10, k(3)/T/rho);
    %% Lagrange multipliers update
    M12 = M12 + B1 - B2;
    M13 = M13 + B1 - B3;
    M14 = M14 + B1 - B4;
    M15 = M15 + B1 - B5;
    m10 = m10 + B1*e - b;
    %toc;
    %if rem(t,1000) == 0
    %    plot_mat(B5,'jet','Br in IEEE case30');
    %end
end

output.B1 = B1;
output.B2 = B2;
output.B3 = B3;
output.B4 = B4;
output.B5 = B5;
output.b = b;
output.M12 = M12;
output.M13 = M13;
output.M14 = M14;
output.M15 = M15;
output.m10 = m10;

%clk = clock;
%str = ['oADMM' num2str(clk(1)) '_' num2str(clk(2)) '_' num2str(clk(3)) '_' num2str(clk(4)) '.' num2str(clk(5)) '.' num2str(clk(6)) '.mat'];
%save(['data/',str],'output');

end

