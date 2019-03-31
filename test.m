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
% 节点电纳矩阵
Bo = makeBmatrix(mpc);
% 增广电纳矩阵
L0 = get_lap(Bo,REF);
plot_mat(L0,'jet','B0 in IEEE case30');
Bo = Bo / max(max(Bo));
plot_mat(Bo,'jet','B in IEEE case30');
% 绘制阻塞分量拉格朗日乘子
%plot_mat(mdata.M(:,mdata.index),'jet','Lagrange Multiplier of LCP in IEEE case30');
% mdata.PricesClean = normc(mdata.PricesClean);
% 行阶梯型矩阵
[~,jb] = rref(mdata.PricesClean(:,10));
B_my = B_estimate(mdata.PricesClean(:,jb),[0.01,0.001,0.01]);
baseline = evaluation(L0, get_lap(B_my,REF));
plot_mat(get_lap(B_my,REF),'jet','Initial Feasible Solution of B in IEEE case30');

online_results = online_admm2(mdata.PricesClean(:,10:end), [0.01,0.001],B_my);
B_final = online_results.B3(:,:,end);
plot_mat(B_final,'jet','Reconstructed B by OADM in IEEE case3');
L_final = get_lap(B_final,REF);
plot_mat(L_final,'jet','Reconstructed B0 by OADM in IEEE case3');
[ACC, TPR, FPR] = evaluation(L0, L_final);
acc = ACC;
tpr = TPR(1);
fpr = FPR(1);
%%
step = [0.001, 0.01, 0.1, 1, 10];
acc = [];
tpr = [];
fpr = [];
for i = 1:5
    B_my = B_estimate(mdata.PricesClean(:,jb),[0.01,0.01,step(i)]);
    online_results = online_admm2(mdata.PricesClean(:,10:end), [0.01,0.01],B_my);
    B_final = online_results.B3(:,:,end);
    L_final = get_lap(B_final,REF);
    [ACC, TPR, FPR] = evaluation(L0, L_final);
    acc = [acc, ACC];
    tpr = [tpr, TPR(1)];
    fpr = [fpr, FPR(1)];
end

acc2 = (1+tpr-fpr)./2;

%%

acc=[];
tpr=[];
fpr=[];
[~,jb] = rref(mdata.PricesClean(:,1:10));
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
    B_part = B_partial(mdata.PricesClean(:,jb),[0.01,0.001,0.01],rows,cols,vals);
    L_final = get_lap(B_part,REF);
    plot_mat(L_final,'jet',join(['Reconstructed B0 with ',num2str(k),' Nodes Unknown']));
    [ACC, TPR, FPR] = evaluation(L0, L_final);
    acc = [acc, (1+TPR(1)-FPR(1))/2];
    tpr = [tpr, TPR(1)];
    fpr = [fpr, FPR(1)];
end

%%
x = 3:30;
plot(x, acc, 'r--o', 'LineWidth', 1.5);
hold on;
plot(x, tpr, 'b--o', 'LineWidth', 1.5);
hold on;
plot(x, fpr, 'g--o', 'LineWidth', 1.5);
ylim([0,1.2]);
legend('AR','TPR','FPR');
grid on;
ax = gca;
ax.FontName = 'Times New Roman';
xlabel('Unknown Nodes', 'FontSize', 13,'FontName', 'Times New Roman');
ylabel('Accuracy', 'FontSize', 13,'FontName', 'Times New Roman');
title('Accuracy of Topology Identification based on Partial Information', 'FontSize', 15,'FontName', 'Times New Roman');
