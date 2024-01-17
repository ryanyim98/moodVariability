
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

s1a1=subplot('Position',[0.05 0.25 0.25 0.7]);
scatter(mean(MuMat_L,2),mean(MuMat_S,2),'filled')
xlabel({'log mean affect-long timescale'},'fontname','helvetica','fontweight','normal','fontsize',13,'color','k')
ylabel({'log mean affect-short timescale'},'fontname','helvetica','fontweight','normal','fontsize',13,'color','k')
box off 
annotation('textbox','linestyle','none','position',[0.11 0.7 0.3 0.1],'string',{'r=0.7160' 'p=0.267*10^{-04}'},'fontname','helvetica','fontweight','normal','fontsize',13,'color','k'); 

s1a1=subplot('Position',[0.37 0.25 0.25 0.7]);
scatter(mean(SMat_L(:,97:101),2),mean(SMat_S(:,97:101),2),'filled')
xlabel({'log affective noise-long timescale'},'fontname','helvetica','fontweight','normal','fontsize',13,'color','k')
ylabel({'log affective noise-short timescale'},'fontname','helvetica','fontweight','normal','fontsize',13,'color','k')
box off 
annotation('textbox','linestyle','none','position',[0.43 0.7 0.3 0.1],'string',{'r=0.8490' 'p=0.218*10^{-07}'},'fontname','helvetica','fontweight','normal','fontsize',13,'color','k'); 




s1a1=subplot('Position',[0.69 0.25 0.25 0.7]);
scatter(mean(VMuMat_L(:,97:101),2),mean(VMuMat_S(:,97:101),2),'filled')
xlabel({'log affective volatility-long timescale'},'fontname','helvetica','fontweight','normal','fontsize',13,'color','k')
ylabel({'log affective volatility-short timescale'},'fontname','helvetica','fontweight','normal','fontsize',13,'color','k')
box off 
annotation('textbox','linestyle','none','position',[0.76 0.7 0.3 0.1],'string',{'r=0.9044' 'p=0.985*10^{-10}'},'fontname','Helvetica','fontweight','normal','fontsize',13,'color','k'); 

set(gcf,'PaperPositionMode','auto')
print(gcf,'../figures/figure_SimCorr.png','-dpng','-r300');  
% saveas(fs3,'figure_SimCorr.pdf')