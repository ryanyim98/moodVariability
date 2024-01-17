
clear
close all

fs3=figure('Units', 'pixels', ...
    'Position', [133 150 900 350]);
hold on;
set(gca,'Layer','top','linewidth',3)
set(fs3,'color',[1 1 1]);


load('Simulated_long_modeldata.mat')

for i=1:27
MuMat_L(i,:)=out(i).moddata.muEst';        
VMuMat_L(i,:)=out(i).moddata.vmuEst';     
SMat_L(i,:)=out(i).moddata.sEst';
end

clear out

load('Simulated_short_modeldata.mat')

for i=1:27
MuMat_S(i,:)=out(i).moddata.muEst';        
VMuMat_S(i,:)=out(i).moddata.vmuEst';     
SMat_S(i,:)=out(i).moddata.sEst';
end

f=figure
xx1 = beeswarm(ones(9,1),mean(MuMat_L([7:9,16:18,25:27],:),2));
close(f)

f=figure
xx2 = beeswarm(ones(9,1),mean(MuMat_L([1:3,10:12,19:21],:),2));
close(f)

f=figure
xx3 = beeswarm(ones(9,1),mean(MuMat_L([4:6,13:15,22:24],:),2));
close(f)

s1a1=subplot('Position',[0.05 0.25 0.25 0.7]);
scatter(xx1,mean(MuMat_L([7:9,16:18,25:27],:),2),'filled')
hold on
scatter(xx2+1,mean(MuMat_L([1:3,10:12,19:21],:),2),'filled');
hold on
scatter(xx3+2,mean(MuMat_L([4:6,13:15,22:24],:),2),'filled')

scatter(1,mean(MuMat_L([7:9,16:18,25:27],:),'all'),'k','d');
scatter(2,mean(MuMat_L([1:3,10:12,19:21],:),'all'),'k','d');
scatter(3,mean(MuMat_L([4:6,13:15,22:24],:),'all'),'k','d');

xlim([0.5,3.5])
xticks([1 2 3])
xticklabels({'-4','0','+4'})
xlabel({'affective set-point'},'fontname','helvetica','fontweight','normal','fontsize',13,'color','k')
ylabel({'logit mean affect'},'fontname','helvetica','fontweight','normal','fontsize',13,'color','k')
box off 

clear xx1 xx2 xx3

f=figure
xx1 = beeswarm(ones(9,1),mean(SMat_L([1:9],97:101),2));
close(f)

f=figure
xx2 = beeswarm(ones(9,1),mean(SMat_L([19:27],97:101),2));
close(f)

f=figure
xx3 = beeswarm(ones(9,1),mean(SMat_L([19:27],97:101),2));
close(f)

s1a1=subplot('Position',[0.37 0.25 0.25 0.7]);
scatter(xx1,mean(SMat_L([1:9],97:101),2),'filled');
 hold on
scatter(xx2+1,mean(SMat_L([10:18],97:101),2),'filled');
  hold on
scatter(xx3+2,mean(SMat_L([19:27],97:101),2),'filled');

scatter(1,mean(SMat_L([1:9],97:101),'all'),'k','d');
scatter(2,mean(SMat_L([10:18],97:101),'all'),'k','d');
scatter(3,mean(SMat_L([19:27],97:101),'all'),'k','d');

xlim([0.5,3.5])
xticks([1 2 3])
xticklabels({'1','2','3'})
xlabel({'magnitude of initial deflection'},'fontname','helvetica','fontweight','normal','fontsize',13,'color','k')
ylabel({'log affective noise'},'fontname','helvetica','fontweight','normal','fontsize',13,'color','k')
box off

clear xx1 xx2 xx3


f=figure
xx1 = beeswarm(ones(9,1),mean(VMuMat_L([1,4,7,10,13,16,19,22,25],97:101),2))
close(f)

f=figure
xx2 = beeswarm(ones(9,1),mean(VMuMat_L([2,5,8,11,14,17,20,23,26],97:101),2))
close(f)

f=figure
xx3 = beeswarm(ones(9,1),mean(VMuMat_L([(1:9).*3],97:101),2))
close(f)

s1a1=subplot('Position',[0.69 0.25 0.25 0.7]);
scatter(xx1,mean(VMuMat_L([1,4,7,10,13,16,19,22,25],97:101),2),'filled')
hold on
scatter(xx2+1,mean(VMuMat_L([2,5,8,11,14,17,20,23,26],97:101),2),'filled')
hold on
scatter(xx3+2,mean(VMuMat_L([(1:9).*3],97:101),2),'filled')

scatter(1,mean(VMuMat_L([1,4,7,10,13,16,19,22,25],97:101),'all'),'k','d');
scatter(2,mean(VMuMat_L([2,5,8,11,14,17,20,23,26],97:101),'all'),'k','d');
scatter(3,mean(VMuMat_L([(1:9).*3],97:101),'all'),'k','d');

xlim([0.5,3.5])
xticks([1 2 3])
xticklabels({'2','1.25','0.5'})
xlabel({'rate of affective decay'},'fontname','helvetica','fontweight','normal','fontsize',13,'color','k')
ylabel({'log affective volatility'},'fontname','helvetica','fontweight','normal','fontsize',13,'color','k')
box off 

set(gcf,'PaperPositionMode','auto')
print(gcf,'../figures/figure_SimExpVsbayes.png','-dpng','-r300');  
% saveas(fs3,'figure_SimExpVsbayes.pdf')