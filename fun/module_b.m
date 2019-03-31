function b = module_b(x,alpha)
% This function solves the problem:
% min_(b>=0) alpha*norm(b,1) + 0.5*norm(b-x)^2;
% where x is a Nx1 vector, alpha>0. 
idx = find(x > alpha);
b = zeros(length(x),1);
b(idx) = x(idx) - alpha ;

end