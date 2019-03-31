%% initialize
clear;
clc;
addpath('src');
addpath('case');
addpath('fun');
mpc = case30();
REF = find(mpc.bus(:,2)==3);

%% load data
load data/mdata.mat

%% recovery
B = makeBmatrix(mpc);
B0 = get_lap(B, REF);
B = normalize(B);
B0 = normalize(B0);
Prices = mdata.PricesClean;
T = size(Prices,2);
k = [sqrt(T), sqrt(T), sqrt(T)];

%% find subspace of LMP matrix
[~,jb] = rref(mdata.PricesClean);
tic;
Br = B_estimate(mdata.PricesClean(:,jb),k);
toc;
%B_r2 = B_estimate(mdata.PricesClean(:,1:500),[0.01,0.01,0.02]);

%%
Br0 = get_lap(Br, REF);
Br0 = normalize(Br0);
[AUC, TPR, FPR] = evaluation(B0, Br0);

%plot_mat(B_r1,'jet','Br in IEEE case30');



