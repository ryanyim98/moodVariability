clear
close all

fs3=figure('Units', 'pixels', ...
    'Position', [133 150 1200 800]);
hold on;
set(gca,'Layer','top','linewidth',3)
set(fs3,'color',[1 1 1]);

map=brewermap(3,'Set1');

s1a2=subplot(2,3,1);
Plot_GorBayesVsBetas('M')

s1a3=subplot(2,3,2);
Plot_GorBayesVsBetas('V')

s1a4=subplot(2,3,3);
Plot_GorBayesVsBetas('S')


%annotation('textbox','linestyle','none','position',[0.16 0.11 0.8 0.1],'string',{'The dependency of Bayesian mood parameters on the affective impact of the three trials','preceding each affect rating. From most to least recent trials (left to right of each panel)'},'Fontsize',20,'fontname','helvetica','fontweight','normal','fontsize',15,'color','k');
annotation('textbox','linestyle','none','position',[0.88 0.05 0.4 0.0],'string',{'*'},'fontname','helvetica','fontweight','normal','fontsize',20,'color','k');
annotation('textbox','linestyle','none','position',[0.9 0.05 0.4 0.0],'string',{'p < 0.05'},'fontname','helvetica','fontweight','normal','fontsize',15,'color','k'); 


annotation('textbox','linestyle','none','position',[0.08 0.92 0.05 0.05],'string','a','fontname','helvetica','fontweight','bold','fontsize',18);
annotation('textbox','linestyle','none','position',[0.37 0.92 0.05 0.05],'string','b','fontname','helvetica','fontweight','bold','fontsize',18);
annotation('textbox','linestyle','none','position',[0.65 0.92 0.05 0.05],'string','c','fontname','helvetica','fontweight','bold','fontsize',18);


s2a2=subplot(2,3,4);
Plot_PANASBayesVsBetas('M')

s2a3=subplot(2,3,5);
Plot_PANASBayesVsBetas('V')

s2a4=subplot(2,3,6);
Plot_PANASBayesVsBetas('S')

annotation('textbox','linestyle','none','position',[0.08 0.45 0.05 0.05],'string','d','fontname','helvetica','fontweight','bold','fontsize',18);
annotation('textbox','linestyle','none','position',[0.37 0.45 0.05 0.05],'string','e','fontname','helvetica','fontweight','bold','fontsize',18);
annotation('textbox','linestyle','none','position',[0.65 0.45 0.05 0.05],'string','f','fontname','helvetica','fontweight','bold','fontsize',18);


set(gcf,'PaperPositionMode','auto')
print(gcf,'../figure_Bayes_vs_Betas','-dpng','-r300');  