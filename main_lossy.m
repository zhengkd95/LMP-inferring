%% load net
clear,
clc,
addpath('src')
addpath('case')
addpath('fun')
mpc = loadcase('case30');

%% load loads
LoadBuses = find(mpc.bus(:,3)>0);
LoadBase = mpc.bus(LoadBuses,3);
KaggleLoads = get_load('data/Load_history.csv',2008,1);
NormalizedLoads = [];
for day = 1:31
    Daily = KaggleLoads(:,(day-1)*24+1:day*24);
    DailyMax = diag(max(Daily,[],2));
    NormalizedLoads = [NormalizedLoads DailyMax\Daily];
end
loads = diag(LoadBase)*NormalizedLoads;

%% load cost function and generator output limit
block_offer,
db = create_db(mpc,loads./0.625,c,pmin,pmax);

%%
clear mdata,
% real time market or load the market data.
run_rt = 1;
if run_rt ==1
    run_lossy_market
else
    load data/mdata_lossy.mat
end
load_idx = find(mdata.loads(:,1)>0)';
%%
