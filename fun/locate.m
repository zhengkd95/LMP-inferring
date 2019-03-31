function [row, col, val] = locate(mpc, lines, B0)
L = size(lines,1);
row = zeros(L,1);
col = zeros(L,1);
val = zeros(L,1);
for i = 1:L
    row(i) = mpc.branch(lines(i),1);
    col(i) = mpc.branch(lines(i),2);
    val(i) = B0(row(i),col(i));
end