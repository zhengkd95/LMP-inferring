%% initialize
clear;
clc;
addpath('src');
addpath('case');
addpath('fun');
mpc = case30();
REF = find(mpc.bus(:,2)==3);
B = makeBmatrix(mpc);
B0 = get_lap(B, REF);
B = normalize(B);
B0 = normalize(B0);
N = size(B,1);

%% load data
load data/mdata_lossy.mat
Prices = mdata.PricesClean;
Prices = Prices(2:end,:);
lossless = 0;
T = size(Prices,2);
k = [sqrt(T), sqrt(T), sqrt(T), 0.03];
counts = [5, 10, 15, 20, 25, 30, 35];
AllLines = find(mpc.branch(:,1) ~= REF);
acc = zeros(length(counts), floor(size(Prices,2)/10)+1);
index = zeros(length(counts), floor(size(Prices,2)/10)+1);

for j = 1:length(counts)
    count = counts(j);     
    KnownLines = sort(randperm(size(AllLines,1), count));
    KnownPart.time = sort(randperm(T, count))';
    KnownPart.lines = AllLines(KnownLines);
    output = online_admm3(Prices, k, mpc, B0, lossless, KnownPart);   
    i = 1;
    for t = 1:size(Prices,2)
        if rem(t,10) == 0 || t == size(Prices,2)
            Br = output.B(:,:,t);
            Br0 = get_lap(Br, REF);
            Br0 = normalize(Br0);
            [ACC, TPR, FPR] = evaluation(B0, Br0);
            acc(j,i) = ACC;
            index(j,i) = t;
            i = i+1;
        end
    end
    [m,p] = max(acc(j,:));
    Br0 = get_lap(output.B(:,:,index(j,p)), REF);
    Br0 = normalize(Br0);
    plot_mat(Br0,'jet',['Recovered L when ' num2str(counts(j)) ' lines are known (lossy)']);
end
