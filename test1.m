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
load data/mdata.mat
Prices = mdata.PricesClean;
%Prices = Prices(2:end,:);
lossless = 1;
T = size(Prices,2);
k = [sqrt(T), sqrt(T), sqrt(T), 0.03];
Prices = Prices(:,1:500);
%counts = [20, 40, 60, 80, 100, 120, 140];
%counts = [5, 10, 15, 20, 25, 30, 35];
counts = 0;
cycle = 1; 
AUC_lists = zeros(length(counts),cycle);
Time_lists = zeros(length(counts),1);
B_sets = zeros(length(counts), N, N, cycle);
AllLines = find(mpc.branch(:,1) ~= REF);

for j = 1:length(counts)
    count = counts(j);
    time = 0;
    for i = 1:cycle       
        KnownLines = sort(randperm(size(AllLines,1), count));
        KnownPart.time = sort(randperm(T, count))';
        KnownPart.lines = AllLines(KnownLines);
        time_start = clock;
        output = online_admm3(Prices, k, mpc, B0, lossless, KnownPart);
        time_end = clock;
        time = time + etime(time_end,time_start);
        B_sets(j,:,:,i) = output.B(:,:,end);
        Br = output.B(:,:,end);
        Br0 = get_lap(Br, REF);     
        Br0 = normalize(Br0);
        [AUC, TPR, FPR] = evaluation(B0, Br0);
        AUC_lists(j,i) = AUC;
    end
    Time_lists(j,1) = time/cycle;
    fprintf('Mean time when %d lines are known: %.4f.\n',counts(j),time/cycle);
    fprintf('Mean loss when %d lines are known: %.4f.\n',counts(j),mean(AUC_lists(j,:)));
end

%str = ['lossy' '_' 'auc' '30_lossy.mat'];
%save(['data/',str],'AUC_lists');

%%
% a = load(['data/' 'lossy' '_' 'auc' '.mat']);
% b = load(['data/' 'lossy' '_' 'auc' '30_r.mat']);
% AUC_lists = [a.AUC_lists; b.AUC_lists];

figure
boxplot(AUC_lists','Labels',{'20', '40', '60', '80', '100', '120', '140'});
xlabel('Number of Known Lines', 'FontSize', 13, 'FontName', 'Times New Roman');
ylabel('Box Plot of AUC-ROC', 'FontSize', 13, 'FontName', 'Times New Roman');
ylim([0.7,1]);
print(['figure/','lossy_auc_distribute','118.eps'],'-depsc');



