%%
% run lossy real time market
mpopt = mpoption;
mpopt.out.all = 0;
mpopt.model = 'DC';
disp('generating LMP for every 5 minutes...');
mdata.Prices = [];
mdata.MEP = [];
mdata.MCP = [];
mdata.MLP = [];
mdata.index = [];
mdata.loads = [];
mdata.gen = [];
mdata.loss = [];
mdata.c = [];
for h = 1:744
    fprintf('hour %d:\n',h);
    dailyload = db.loads(:,h);
    lossy_LMP,
    for i = 1:12
        dailyload = db.loads(:,h) + sqrt(db.loads(:,h)/10).*randn(db.N,1);
        c = db.c + (((rand(db.N,1) - 0.5)*5) * ones(1,5)) .* (db.c~=0);
        market = dc_opf_Litvinov(dailyload,c,db.T,db.flowlimit,db.pmin,db.pmax,LF,l0,D);
        mdata.Prices = [mdata.Prices, market.price];
        mdata.MEP = [mdata.MEP, market.MEP];
        mdata.MCP = [mdata.MCP, market.MCP];
        mdata.MLP = [mdata.MLP, market.MLP];        
        mdata.loads = [mdata.loads, dailyload];
        mdata.gen = [mdata.gen, market.p];
        mdata.loss = [mdata.loss, market.loss];
        mdata.c(:,:,h*12-12+i) = c;
        if market.success && market.cong 
            mdata.index = [mdata.index, (h-1)*12+i];
        end
    end
end
mdata.PricesClean = mdata.Prices(:,mdata.index);
save data/mdata_lossy.mat mdata