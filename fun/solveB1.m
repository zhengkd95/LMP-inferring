function B_solve = solveB1(xt, Q2, B1, B2, B3, B4, B5, M12, M13, M14, M15, m10, b, rho, eta, k, lossless)

N = size(B1,1);
e = ones(N,1);
C = rho*(B2 + B3 + B4 + B5 - M12 - M13 - M14 - M15 + b * e' - m10 * e' + eta/rho*B1);
B1C = C * Q2;

xt = Q2*xt;
if lossless
    B_solve = modulel1(xt,B1C) * Q2;
else
    B_solve = modulehuber(xt,B1C,1,k(4)) * Q2;
end

% settings = sdpsettings('solver', 'sedumi','verbose',1);
% 
% clear('yalmip');
% B = sdpvar(N,N);
% 
% obj = norm(B*xt,1) + ...
%   rho/2 * norm((B-B2+M12),'fro')^2 + rho/2 * norm((B-B3+M13),'fro')^2 + ...
%   rho/2 * norm((B-B4+M14),'fro')^2 + rho/2 * norm((B*e-b+m10),2)^2 + ...
%   eta/2 * norm((B-B1),'fro')^2;
% 
% optimize([], obj, settings);
% 
% B_solve = value(B);

end

