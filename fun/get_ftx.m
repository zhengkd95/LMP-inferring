function [f,t,x] = get_ftx(L, nl)
    L_triu = abs(triu(L,1));
    value = sort(L_triu(L_triu(:)>0),'descend');
    if length(value) >= nl
        [f,t,x] = find(L_triu,nl);
    else 
        [f,t,x] = find(L_triu);
end