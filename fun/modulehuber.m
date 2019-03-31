function X = modulehuber(z,Y,alpha,kappa)
% This function solves the problem:
% min_X alpha*huber(X*z,kappa) + 0.5*norm(X-Y,'fro')^2;
% where z is a Nx1 vector, Y is an MxN matrix, alpha>0, and kappa is the
% Huber function parameter

[M,N] = size(Y);

t = Y*z;
scalar = z'*z;

if scalar==0,
    X = Y;
else  %% scalar>0
    g = alpha*kappa*(abs(t) > kappa*(1+alpha*scalar)).*sign(t) + (abs(t) <= kappa*(1+alpha*scalar)).*t/(1/alpha+scalar);
    X = Y - g*z';
end;


%%%%%% YALMIP solution follows
% settings = sdpsettings('solver','sedumi','verbose',1);
% 
% clear('yalmip')
% X = sdpvar(M,N,'full');
% 
% obj = alpha/2*huber(X*z) + 0.5*norm(X-Y,'fro')^2;
% 
% diagnostic = solvesdp([],obj,settings)
% if diagnostic.problem,
%     disp([diagnostic.info ' and exiting']);
%     solution.X1 = 0;
%     return
% end;
% solution.X1 = double(X);