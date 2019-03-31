%% initialize
clear;
clc;
addpath('src');
addpath('case');
addpath('fun');
mpc = case118();
REF = find(mpc.bus(:,2)==3);
B = makeBmatrix(mpc);
B0 = get_lap(B, REF);
B = normalize(B);
B0 = normalize(B0);
plot_mat(B,'jet','B in IEEE case118');
plot_mat(B0,'jet','L in IEEE case118');
N = size(B,1);

%% load data
load data/mdata118.mat
Prices = mdata.PricesClean;
%Prices = Prices(2:end,:);
lossless = 1;
T = size(Prices,2);
k = [sqrt(T), sqrt(T), sqrt(T), 0.03];

count = 0;
AllLines = find(mpc.branch(:,1) ~= REF);
KnownLines = sort(randperm(size(AllLines,1), count));
KnownPart.time = sort(randperm(T, count))';
KnownPart.lines = AllLines(KnownLines);

%% odam
%output = online_admm2(Prices, 0.01*[1,1]);
cycle = 1;
t1 = clock;
for i = 1:cycle
    output = online_admm3(Prices, k, mpc, B0, lossless, KnownPart);
end
t2 = clock;
Br0 = get_lap(output.B(:,:,end), REF);
Br0 = normalize(Br0);
[AUC, TPR, FPR] = evaluation(B0, Br0);
fprintf('Mean time: %.4f.\n',etime(t2,t1)/cycle);
fprintf('Mean loss: %.4f.\n',AUC);

%% evaluate
acc = zeros(floor(size(Prices,2)/10)+1,1);
i = 1;
for t = 1:size(Prices,2)
    if rem(t,10) == 0 || t == size(Prices,2)
        Br = output.B(:,:,t);
        Br0 = get_lap(Br, REF);
        Br0 = normalize(Br0);
        [ACC, TPR, FPR] = evaluation(B0, Br0);
        acc(i,1) = ACC;
        i = i+1;
    end
end

%% plot
figure,
plot(acc);
hold on
sz = 20;
scatter(KnownPart.time, acc(KnownPart.time,1), sz,'MarkerEdgeColor','k',...
              'MarkerFaceColor','k',...
              'LineWidth',1.5);
hold off

%% plot TPR-FPR
figure,
plot([1;FPR;0],[1;TPR;0]);






