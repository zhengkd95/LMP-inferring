function y = plot_mat(B,map,title_txt,norm,e,showtext,savedir)
% y = PLOT_LAP(B,map,norm,e,title_txt,showtext)
%% default arguments

if nargin < 7
    savedir = 'D:\research\MyProject\LMP\Topology\paper\MyPaper\figure\';
    if nargin < 6
        showtext = 0;
        if nargin < 5 
            e = 1e-3;
            if nargin < 4
                norm = 1;
                if nargin <3 
                    title_txt = 'MATRIX';
                    if nargin <2
                        map = 'jet';
                    end
                end

if nargin < 6
    showtext = 0;
    if nargin < 5 
        e = 1e-3;
        if nargin < 4
            norm = 1;
            if nargin <3 
                title_txt = 'MATRIX';
                if nargin <2
                    map = 'jet';

            end
        end
    end
end

B = double(B);
B(abs(B)<e) = 0;
 
figure,
colormap(map)
L = B;
if norm > 0 
    ceil = max(max(L));
    if  ceil > 0
        L(L>0) = L(L>0)/ceil;
    end
    floor = min(min(L));
    if floor < 0
        L(L<0) = -L(L<0)/floor;
    end
end
image(L,'CDataMapping','scaled'),
colorbar
if showtext
hold on;
    for i = 1:size(L,1)
      for j = 1:size(L,2)
          nu = L(i,j);
          val = num2str(round(nu,2));
          text(i,j,val)
      end
    end
    hold off;
end
%title(title_txt,'FontSize', 13, 'FontName', 'Times New Roman');
xlabel('Bus Node', 'FontSize', 13, 'FontName', 'Times New Roman');
ylabel('Bus Node', 'FontSize', 13,'FontName', 'Times New Roman');
set(gca,'FontSize',12,'Fontname', 'Times New Roman');
print(['figure/',title_txt,'.eps'],'-depsc');
end