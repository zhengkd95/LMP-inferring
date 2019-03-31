function L = get_lap(B,REF)
    aDA = -sum(B);
    aDa = -sum(aDA);
    L = [B(1:REF-1,1:REF-1),aDA(1:REF-1)',B(1:REF-1,REF:end);
        aDA(1:REF-1),  aDa,  aDA(REF:end);
        B(REF:end,1:REF-1), aDA(REF:end)',B(REF:end,REF:end)];
%    L = L / max(max(L));
    L(abs(L)<1e-4)=0;
end