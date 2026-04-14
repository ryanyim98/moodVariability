function plot_uncert_series()
    addpath(genpath("~/Desktop/MoodInstability/moodVariability/figures/figure2"));
    load('7_bayes_mod.mat')
    load('out.mat')

    green = [0 176 80]./255;
    red = [255 0 0]./255;
    blue = [0 112 192]./255;

    % data=fullpart;
    % sem=fullpartsem;

    fs=12;
    makefigure(22,12);

    % fig2=figure;
    set(gca,'Layer','top','linewidth',3)
    % set(fig2,'color',[1 1 1]);
    subplot(2,1,1,'Box','off')

    hold on
    p1=plot([0.5;subdata.shape1_win(1:end-1)],'k','linewidth',1)
    p2=plot(maglearn_data_noise.rewdata(7,7).muEst,'color',green,'linewidth',1);

    legend([p2 p1],{'Mean Estimate','Actual Data'},'Location','north')
    xlabel('Trials')
    ylabel({'Outcome', 'Magnitude'})
    xlim([-1 360])
    ylim([0 1]);
    %title('The fitted model has a coarser representation of noise than the full model')
    set(gca,'FontSize',fs,'FontName','Helvetica')

    subplot(2,1,2,'Box','off')
    hold on;
        
    xlim([-1 360])
    ylim([-5.2 2]);
    
    h(1) = plot(maglearn_data_noise.rewdata(7,7).vmuEst,':','color',red,'linewidth',1.5); hold on;
    h(2) = plot(maglearn_data_noise.rewdata(7,7).sEst.*2,'--','color',blue,'linewidth',1.5);
    set(gca,'FontSize',fs,'FontName','Helvetica')
    xlabel('Trials')
    ylabel({'Uncertainty', 'Estimate'})
    
    ax = gca;
    text(1, 2.5,'(1)','FontSize',12)
    b = area([1 60], [ax.YLim(1) ax.YLim(1)],'FaceColor','k','FaceAlpha',0.02,'LineStyle','none');
    area([1 60], [ax.YLim(2) ax.YLim(2)],'FaceColor','k','FaceAlpha',0.02,'LineStyle','none');
    b.ShowBaseLine='off'
    
    text(61, 2.5,'(2)','FontSize',12)
    area([61 120], [ax.YLim(1) ax.YLim(1)],'FaceColor','k','FaceAlpha',0.04,'LineStyle','none');
    area([61 120], [ax.YLim(2) ax.YLim(2)],'FaceColor','k','FaceAlpha',0.04,'LineStyle','none');
    
    text(121, 2.5,'(3)','FontSize',12)
    area([121 240], [ax.YLim(1) ax.YLim(1)],'FaceColor','k','FaceAlpha',0.06,'LineStyle','none');
    area([121 240], [ax.YLim(2) ax.YLim(2)],'FaceColor','k','FaceAlpha',0.06,'LineStyle','none');
    
    text(241, 2.5,'(4)','FontSize',12)
    area([241 300], [ax.YLim(1) ax.YLim(1)],'FaceColor','k','FaceAlpha',0.08,'LineStyle','none');
    area([241 300], [ax.YLim(2) ax.YLim(2)],'FaceColor','k','FaceAlpha',0.08,'LineStyle','none');
    
    text(301, 2.5,'(5)','FontSize',12)
    area([301 360], [ax.YLim(1) ax.YLim(1)],'FaceColor','k','FaceAlpha',0.10,'LineStyle','none');
    area([301 360], [ax.YLim(2) ax.YLim(2)],'FaceColor','k','FaceAlpha',0.10,'LineStyle','none');

%     
%     line([1 60],[-5 -5],'lineWidth',2,'Color','k');
%     text(1, -5.5,'high vmu low s','FontSize',8)
%     line([61 120],[-4.8 -4.8],'lineWidth',2,'Color','k');
%     text(61, -5.5,'high vmu high s','FontSize',8)
%     line([121 240],[-4.6 -4.6],'lineWidth',2,'Color','k');
%     text(121, -5.5,'low vmu low s','FontSize',8)
%     line([241 300],[-4.4 -4.4],'lineWidth',2,'Color','k');
%     text(241, -5.5,'low vmu high s','FontSize',8)
%     line([301 360],[-4.8 -4.8],'lineWidth',2,'Color','k');
%     text(301, -5.5,'high vmu high s','FontSize',8)
    line([61 120],[-5 -5],'lineWidth',2,'Color','k');
    line([241 360],[-5 -5],'lineWidth',2,'Color','k');
    text(1, -4.5,'high noise','FontSize',10,'Color',blue)
    line([1 120],[1 1],'lineWidth',2,'Color','k');
    line([301 360],[1 1],'lineWidth',2,'Color','k');
    text(1, 1.5,'high volatility','FontSize',10,'Color',red)
    legend([h(1) h(2)],'Volatility Estimate','Noise Estimate','Location','north');


    export_fig('./fig1c.png','-r 300');

end

