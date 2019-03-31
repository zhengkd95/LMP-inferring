%%
% preprocess
clear,
clc,
addpath('src')
addpath('case')
addpath('fun')
mpc = loadcase('case30');
REF = find(mpc.bus(:,2)==3);
%%
try
    load data/KaggleLoads.mat
catch error
    disp('Load .mat file does not exist. Generating...')
    data_preprocess,
end
block_offer,
db = create_db(mpc,KaggleLoads./0.625,c,pmin,pmax); %除以0.625什么意思
clear c pmin pmax,

%%
% real time market or load the market data.
run_rt = 0;
if run_rt ==1
    run_rtmarket
else
    load data/mdata.mat
end
load_idx = find(mdata.loads(:,1)>0)';
%% 
% online admm
% load data/Market_with_changes.mat
% 节点电纳矩阵
Bo = makeBmatrix(mpc);
% 增广电纳矩阵
L0 = get_lap(Bo,REF);
plot_mat(L0,'jet','B0 in IEEE case30');
Bo = Bo / max(max(Bo));
plot_mat(Bo,'jet','B in IEEE case30');
% mdata.PricesClean = normc(mdata.PricesClean);
acc=[];
tpr=[];
fpr=[];
for k = 3:30
    rows = [];
    cols = [];
    vals = [];
    for i = 1:28
        for j = k:29
            if j <= i 
                continue
            end
            rows = [rows; i];
            cols = [cols; j];
            vals = [vals; Bo(i,j)];
        end
    end
    % 行阶梯型矩阵
    [~,jb] = rref(mdata.PricesClean(:,1:10));
    B_part = B_partial(mdata.PricesClean(:,jb),[0.01,0.01,0.01*2],rows,cols,vals);
    L_part = get_lap(B_part,REF);
    [ACC, TPR, FPR] = evaluation(L0(1:k-1,1:k-1), L_part(1:k-1,1:k-1));
    acc = [acc, ACC];
    tpr = [tpr, TPR(1)];
    fpr = [fpr, FPR(1)];
    % plot_mat(B_part,'jet')
end