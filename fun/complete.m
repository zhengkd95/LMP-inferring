function Bc = complete(B, t, B_origin, KnownPart, mpc)
    REF = find(mpc.bus(:,2)==3);
    Bc = B;
    j = find(KnownPart.time(:,1) <= t, 1, 'last');
    if j
        [row, col, val] = locate(mpc, KnownPart.lines(1:j,1), B_origin);
        for i = 1:length(row)
            if row(i) < REF && col(i) < REF
                Bc(row(i),col(i)) = val(i);
                Bc(col(i),row(i)) = val(i);
                Bc(row(i),row(i)) = Bc(row(i),row(i))-val(i);
                Bc(col(i),col(i)) = Bc(col(i),col(i))-val(i);
            elseif row(i) > REF && col(i) < REF
                Bc(row(i)-1,col(i)) = val(i);
                Bc(col(i),row(i)-1) = val(i);
                Bc(row(i)-1,row(i)-1) = Bc(row(i)-1,row(i)-1)-val(i);
                Bc(col(i),col(i)) = Bc(col(i),col(i))-val(i);
            elseif row(i) < REF && col(i) > REF
                Bc(row(i),col(i)-1) = val(i);
                Bc(col(i)-1,row(i)) = val(i);
                Bc(row(i),row(i)) = Bc(row(i),row(i))-val(i);
                Bc(col(i)-1,col(i)-1) = Bc(col(i)-1,col(i)-1)-val(i);
            elseif row(i) > REF && col(i) > REF
                Bc(row(i)-1,col(i)-1) = val(i);
                Bc(col(i)-1,row(i)-1) = val(i);
                Bc(row(i)-1,row(i)-1) = Bc(row(i)-1,row(i)-1)-val(i);
                Bc(col(i)-1,col(i)-1) = Bc(col(i)-1,col(i)-1)-val(i);
            end
        end
    end
end