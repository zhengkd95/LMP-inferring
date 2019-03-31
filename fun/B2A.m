function [A,x,f,t] = B2A(B,L,REF,nl)
    nb = size(L,1);
    nl1 = floor(nl/nb*(nb-1));
    f = [];
    t = [];
    x = [];
    U = triu(B,1);
    U_sort = sort(abs(U(:)),'descend');
    e = U_sort(nl1+1);
    for i = 1:size(B,1)-1
        for j = i+1:size(B,1)
            if abs(B(i,j))>e
                f = [f;i];
                t = [t;j];
                x = [x;1/abs(B(i,j))];
            end
        end
    end
    f(f>=REF) = f(f>=REF)+1;
    t(t>=REF) = t(t>=REF)+1;
    
    nl2 = nl-nl1;
    L_sort = sort(abs(L(:,REF)),'descend');
    e = L_sort(nl2+2);
    for i = 1:REF-1
        if abs(L(i,REF))>e
            f = [f;i];
            t = [t;REF];
            x = [x;1/abs(L(i,REF))];
        end
    end
    for i = REF+1:nb
        if abs(L(i,REF))>e
            f = [f;REF];
            t = [t;i];
            x = [x;1/abs(L(i,REF))];
        end            
    end
    
    [f,I] = sort(f,'ascend');
    t = t(I);
    x = x(I);
    Cf = sparse(1:nl, f, ones(nl, 1), nl, nb);
    Ct = sparse(1:nl, t, ones(nl, 1), nl, nb);
    A = Cf-Ct;
end