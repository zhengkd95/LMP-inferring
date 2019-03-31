function X = modulel1(z,Y)
% This function solves the problem:
% min_X norm(X*z,1) + 0.5*norm(X-Y,'fro')^2;
% where z is a Nx1 vector and Y is an MxN matrix

[M,N] = size(Y);

t = Y*z;
scalar = z'*z;

if scalar==0,
    X = Y;
else  %% alpha>0
    g = sign(t).*min(abs(t)./scalar,1);       
    X = Y - g*z';
end;

% %%%%%% YALMIP solution follows
% settings = sdpsettings('solver','sedumi','verbose',1);
% 
% clear('yalmip')
% X = sdpvar(M,N,'full');
% 
% obj = norm(X*z,1) + 0.5*norm(X-Y,'fro')^2;
% 
% diagnostic = solvesdp([],obj,settings)
% if diagnostic.problem,
%     disp([diagnostic.info ' and exiting']);
%     solution.X1 = 0;
%     return
% end;
% solution.X1 = double(X);