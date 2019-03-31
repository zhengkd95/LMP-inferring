function [AUC,TPR,FPR] = evaluation(B0,B)

nb = size(B,1) + 1;

B0_triu = triu(B0,1);
B_triu = triu(B,1);

B0_triu = B0_triu(:);
B_triu = B_triu(:);

TPR = [];
FPR = [];
for e = eps:5e-2:max(abs(B_triu))

    IDX0 = find(B0_triu ~= 0);

    IDX = find(abs(B_triu) >= e);

    TP = length(intersect(IDX0,IDX));

    FP = length(setdiff(IDX,IDX0));

    % 
    TPR = [TPR; TP/length(IDX0)];
    % 
    TPR = [TPR; TP/length(IDX0)]; 

    FPR = [FPR; FP/( (nb-1)*(nb-2)/2 - length(IDX0) + eps)];
end
AUC = sum(([1;FPR]-[FPR;0]).*([1;TPR] + [TPR;0])/2 );
end