%%
% preprocess
clear,
clc,
addpath('src')
addpath('case')
addpath('fun')
mpc = loadcase('case30');
REF = find(mpc.bus(:,2)==3);
% delete 'data/KaggleLoads.mat'

try
    load data/KaggleLoads.mat
catch error
    disp('Load .mat file does not exist. Generating...')
    data_preprocess,
end
block_offer,
db = create_db(mpc,KaggleLoads./0.625,c,pmin,pmax); 
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

Bo = makeBmatrix(mpc);

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

    [~,jb] = rref(mdata.PricesClean(:,1:10));
    B_part = B_partial(mdata.PricesClean(:,jb),[0.01,0.01,0.01*2],rows,cols,vals);
    L_part = get_lap(B_part,REF);
    [ACC, TPR, FPR] = evaluation(L0(1:k-1,1:k-1), L_part(1:k-1,1:k-1));
    acc = [acc, ACC];
    tpr = [tpr, TPR(1)];
    fpr = [fpr, FPR(1)];
    % plot_mat(B_part,'jet')
end
figure,
plot(acc)

B_my = B_estimate(mdata.PricesClean(:,1:jb),[0.01,0.01,0.01*2]);

baseline = evaluation(L0, get_lap(B_my,REF));

hold on,
plot(1:30,baseline,'r*');
hold off;

acc2 = zeros(29,29);
for i = 1:28
    for j = i+1:29
        if Bo(i,j) == 0
            continue
        end
        B_part = B_partial(mdata.PricesClean(:,1:jb),[0.01,0.01,0.01*2],i,j,Bo(i,j));
        L_part = get_lap(B_part,REF);
        acc2(i,j) = evaluation(L0, L_part);
    end
end
figure,
plot(acc2(acc2>0))

hold on,
plot(1:41,baseline,'r*');
hold off;

plot_mat(B_my,'jet','B my');
B_keka = B_Kekatos(mdata.PricesClean(:,1:10),[0.01,0.01]);
plot_mat(B_keka,'jet','B keka');
online_results = online_admm2(mdata.PricesClean(:,10:end), 0.01*[1,1], B_my);
online_results2 = online_admm(mdata.PricesClean(:,10:end), 0.01*[1,1], B_keka);
B_final = online_results.B3(:,:,end);
plot_mat(B_final,'jet','B1');
L_final = get_lap(B_final,REF);
plot_mat(L_final,'jet','L1');
B_final2 = online_results2.B3(:,:,end);
plot_mat(B_final2,'jet','B2');
L_final2 = get_lap(B_final2,REF);
plot_mat(L_final2,'jet','L2');


a = online_results.B3(22,25,:);
b = online_results2.B3(22,25,:);
AUC = zeros(1,length(a));
AUC2 = zeros(1,length(a));
parfor i = 1:length(a)
    B_final = online_results.B3(:,:,i);
    L_final = get_lap(B_final,REF);

    B_final2 = online_results2.B3(:,:,i);
    L_final2 = get_lap(B_final2,REF);
    AUC(i) = evaluation(L0,L_final);
    AUC2(i) = evaluation(L0,L_final2);
end
figure, hold on,
axis([0,9000,0.5,1])
plot(AUC,'r-'),plot(AUC2,'b-')
hold off

%%
% [f,t,x] = get_ftx(L_final, 200);



%%
% constructing PTDF matrix from the inferred Laplacian matrix

for time = 1000:size(mdata.PricesClean,2)-288
    t = mdata.index(time);
    fprintf('time=%d\n',time)
    L_infered = get_lap(online_results.B3(:,:,end),REF);
    avg_degree = mean(diag(L_infered));
    L_infered = L_infered/avg_degree * mean(diag(L0));
    db_infered = L2A(L_infered, REF);
    Pf = diag(db_infered.x)*db_infered.Ar*db_infered.Bri* ...
        (mdata.gen(2:end,1:t)-mdata.loads(2:end,1:t) );
    db_infered.flowlimit = max(abs(Pf),[],2);
    
    train_error_min = 100;
    while (1)
        db_infered = line_reduce(db_infered, mdata ,REF, 1:t);
        fprintf('nl=%d\n',db_infered.L)
        if db_infered.L <= 80
            tt = mdata.index((time-287):time);
            db_infered.pmin = db.pmin; db_infered.pmax = db.pmax;
            mdata2 = get_lmp(db_infered, mdata, tt);
            PI = mdata.Prices(:,tt) + repmat(mdata.mu0(:,tt),db.N-1,1);
            PI2 = mdata2.Prices + repmat(mdata2.mu0,db.N-1,1);
            train_error = rmse(PI(load_idx-1,mdata2.index), PI2(load_idx-1,mdata2.index));
            fprintf('training rmse=%g\n',train_error)
            if train_error<train_error_min
                db_reduced = db_infered;
                train_error_min = train_error;
            end
            if db_infered.L <= 41
                fprintf('min training rmse=%g\n',train_error_min)
                break
            end
        end
    end
end

mdata2 = get_lmp(db_reduced, mdata, tt);
PI2 = mdata2.Prices + repmat(mdata2.mu0,db.N-1,1);
train_error = rmse(PI(load_idx-1,mdata2.index), PI2(load_idx-1,mdata2.index));
%%
% print to files
for i = load_idx
    figure,
    hold on,
    title(sprintf('LMP of bus %d',i))
    plot(PI(i-1,mdata2.index),'b-')
    plot(PI2(i-1,mdata2.index),'r-')
    hold off
    print(sprintf('fig/train_bus%d.eps',i),'-depsc')
    close
end

%%
% testing
time_test = size(mdata.PricesClean,2)-287:size(mdata.PricesClean,2);
tt = mdata.index(time_test);
mdata3 = get_lmp(db_reduced,mdata,time_test);
PI3 = mdata3.Prices + repmat(mdata3.mu0,db.N-1,1);
PI = mdata.Prices(:,tt) + repmat(mdata.mu0(:,tt),db.N-1,1);
test_error = rmse(PI(load_idx-1,mdata3.index), PI3(load_idx-1,mdata3.index));
fprintf('test rmse =%g\n', test_error)
for i = load_idx
    figure,
    hold on,
    title(sprintf('LMP of bus %d',i))
    plot(PI(i-1,mdata3.index),'b-')
    plot(PI2(i-1,mdata3.index),'r-')
    hold off
    print(sprintf('fig/test_bus%d.eps',i),'-depsc')
    close
end
system('fig\eps2pdf.bat');

%%
mdata.MClean(abs(mdata.MClean)<1e-4) = 0;
[R,jb] = rref(mdata.MClean);
M = mdata.MClean(:,jb);
for i = 1:41
M = eye(size(M,1),i);
% M = M ./ repmat(max(abs(M)),size(M,1),1);
P = db.Bri * db.Ar'*diag(db.x)*M;
P = normc(P);
B_mini = B_estimate(P,0.005*[1,1,1]);

L_mini = get_lap(B_mini,REF);
plot_mat(L_mini,'jet','Lmini');
print(sprintf('fig/M%d.eps',i),'-depsc')

AUC3(i) = evaluation(L0,L_mini);
end
plot_mat(L0,'jet','L0');
close all,
system('fig\eps2pdf.bat');
plot(AUC3);

