c = loadcase('case30');
LoadBuses = find(c.bus(:,3)>0);  %找到有负荷的节点
Loads = c.bus(LoadBuses,3);  %带负荷节点的基础负荷

savedir = 'figure\';
figure,
bar(Loads);
ylim([0,35]);
title_txt = 'Nodal Loads in IEEE case 30';
title(title_txt,'FontSize', 13, 'FontName', 'Times New Roman');
xlabel('Bus Node', 'FontSize', 13, 'FontName', 'Times New Roman');
ylabel('Active Power', 'FontSize', 13,'FontName', 'Times New Roman');
set(gca,'FontSize',12,'Fontname', 'Times New Roman');
print([savedir,title_txt,'.eps'],'-depsc');

% 取2008年1月
KaggleLoads = get_load('data/Load_history.csv',2008,1);
K = KaggleLoads;
KaggleLoads = [];

for day = 1:31
    Day = K(:,(day-1)*24+1:day*24);
    DailyMax = max(Day')';
    Day = diag(1./DailyMax)*Day;
    KaggleLoads = [KaggleLoads Day];
end
figure,
plot(KaggleLoads(:,1:48)','LineWidth',1);
ylim([0,1.1]);
title_txt = 'Real Loads from Kaggle';
title(title_txt,'FontSize', 13, 'FontName', 'Times New Roman');
xlabel('Time Slot', 'FontSize', 13, 'FontName', 'Times New Roman');
ylabel('Normalized Active Power', 'FontSize', 13,'FontName', 'Times New Roman');
print([savedir,title_txt,'.eps'],'-depsc');


KaggleLoads = diag(Loads)*KaggleLoads;
save data/KaggleLoads.mat KaggleLoads

figure,
plot(KaggleLoads(:,1:48)','LineWidth',1);
ylim([0,1.2*30])
title_txt = 'Generated Load Profiles';
title(title_txt,'FontSize', 13, 'FontName', 'Times New Roman');
xlabel('Time Slot', 'FontSize', 13, 'FontName', 'Times New Roman');
ylabel('Absolute Active Power', 'FontSize', 13,'FontName', 'Times New Roman');
print([savedir,title_txt,'.eps'],'-depsc');