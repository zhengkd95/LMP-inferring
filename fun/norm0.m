function y = norm0(B)
    B(abs(B)<1e-4) = 0;
    B=B(:);
    y = length(find(B~=0));
end