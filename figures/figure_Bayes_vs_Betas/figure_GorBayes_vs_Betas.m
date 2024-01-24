clear
close all

fs3=figure('Units', 'pixels', ...
    'Position', [133 150 1200 800]);
hold on;
set(gca,'Layer','top','linewidth',3)
set(fs3,'color',[1 1 1]);

map=brewermap(3,'Set1');

colourmat1=[0.6510,0.8078,0.8902;0.1216,0.4706,0.7059;0.6980,0.8745,0.5412;0.2000,0.6275,0.1725;...
0.9843,0.6039,0.6000;0.8902,0.1020,0.1098;0.9922,0.7490,0.4353;1.0000,0.4980,0];

s1a2=subplot('Position',[0.06 0.375 0.255 0.6]);
Plot_GorBayesVsBetas('M')

s1a3=subplot('Position',[0.38 0.375 0.265 0.6]);
Plot_GorBayesVsBetas('V')

s1a4=subplot('Position',[0.735 0.375 0.255 0.6]);
Plot_GorBayesVsBetas('S')


%annotation('textbox','linestyle','none','position',[0.16 0.11 0.8 0.1],'string',{'The dependency of Bayesian mood parameters on the affective impact of the three trials','preceding each affect rating. From most to least recent trials (left to right of each panel)'},'Fontsize',20,'fontname','helvetica','fontweight','normal','fontsize',15,'color','k');
annotation('textbox','linestyle','none','position',[0.88 0.235 0.01*2/3 0.01],'string',{'*'},'fontname','helvetica','fontweight','normal','fontsize',20,'color','k');
annotation('textbox','linestyle','none','position',[0.9 0.17 0.4 0.1*0.75],'string',{'p < 0.05'},'fontname','helvetica','fontweight','normal','fontsize',15,'color','k'); 


annotation('textbox','linestyle','none','position',[0.08 0.96 0.05 0.05],'string','a','fontname','helvetica','fontweight','bold','fontsize',18);
annotation('textbox','linestyle','none','position',[0.4 0.96 0.05 0.05],'string','b','fontname','helvetica','fontweight','bold','fontsize',18);
annotation('textbox','linestyle','none','position',[0.755 0.96 0.05 0.05],'string','c','fontname','helvetica','fontweight','bold','fontsize',18);

set(gcf,'PaperPositionMode','auto')
%print(gcf,'../figure_GorBayes_vs_Betas','-dpng','-r300');  