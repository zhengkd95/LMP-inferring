function BN = normalize(B)
    Bu = triu(B, 1);
    Bu = diag(diag(B).^(-1))*Bu;
    BN = Bu + Bu' + eye(size(B,1));
end