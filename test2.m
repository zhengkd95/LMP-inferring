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
%plot_mat(B0,'jet','Primal L');

%% load data
load data/mdata_lossy.mat
Prices = mdata.PricesClean;
Prices = Prices(2:end,:);
lossless = 0;
T = size(Prices,2);
k = [sqrt(T), sqrt(T), sqrt(T), 0.03];

count = 10;
AllLines = find(mpc.branch(:,1) ~= REF);
KnownLines = sort(randperm(size(AllLines,1), count));
KnownPart.time = sort(randperm(T, count))';
KnownPart.lines = AllLines(KnownLines);

%% odam
output = online_admm3(Prices, k, mpc, B0, lossless, KnownPart);
Br0 = get_lap(output.B(:,:,end), REF);
Br0 = normalize(Br0);
[AUC, TPR, FPR] = evaluation(B0, Br0);
%% evaluate

for t = 1:size(Prices,2)
    if rem(t,500) == 0 || t == size(Prices,2)
        Br = output.B(:,:,t);
        Br0 = get_lap(Br, REF);
        Br0 = normalize(Br0);
        plot_mat(Br0,'jet',['Recovered L at ' num2str(t) '-th interval (loss-less 30)']);
    end
end

