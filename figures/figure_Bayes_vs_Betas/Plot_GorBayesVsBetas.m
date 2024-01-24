%M=Mu
%V=VMu
%S=S

function Plot_GorBayesVsBetas(Param)

rr=3

map=brewermap(3,'Set1');
 %This script takes results from BetavsBayesRegress.m found in C:\Users\donh\Dropbox\DPHIL\modelling_workspace\Mood_Instability_Study\AppleTask_scripts_1
 % and makes plots out of them
 %You need to run three seperate analyses in BetavsBayesRegress.m, one
 %each for Mu, VMu and S. After each analysis, rename the table 'BetaB' as 
 % MuB, VMuB and SB respectively.
 
 %Then you will need to work out which asterixes to put in the individual
 %plots both for signifiying betas significantly different from zero and
 %for betas significantly different from each other.
 %To do the former, look at the pB array for each analysis.
 % To do the latter, after each analysis, use this function  ci = coefCI(lmb)
 %to check the 95% CI and see if they overlap or not.
 %You will then need to add/alter/remove/comment-out asterixs as needed

 load('GorBayes_vs_Betas_data.mat')
 
if Param=='M'
 
    bar([1],table2array(GorMu_vs_Betas.Coefficients(2,1)),'barwidth',1,'FaceColor',map(2,:),'EdgeColor',map(2,:))
    hold on
    bar([3],table2array(GorMu_vs_Betas.Coefficients(3,1)),'barwidth',1,'FaceColor',map(2,:),'EdgeColor',map(2,:))
    hold on
    bar([5],table2array(GorMu_vs_Betas.Coefficients(4,1)),'barwidth',1,'FaceColor',map(2,:),'EdgeColor',map(2,:))
    hold on
    errorbar([1,3,5],table2array(GorMu_vs_Betas.Coefficients(2:4,1)),table2array(GorMu_vs_Betas.Coefficients(2:4,2)),'.k','LineWidth',1.5,'CapSize',1.5)
      text(0.9, 0.025, '*','FontSize', 16)
      plot([0.75,1.25],[0.02,0.02], 'k--','LineWidth', 1.6)
%          text(4.9, 0.03, '*','FontSize', 16)
%      plot([4.75,5.25],[0.028,0.028], 'k--','LineWidth', 1.6)
%         text(4,-0.025, '*','FontSize', 16)
%       plot([3,5],[-0.02,-0.02], 'k--','LineWidth', 1.6)
xticks([1,3,5])
xticklabels({'trials - 1:3','trials - 4:6','trials - 7:9',})
ylabel('Correlation Strength');
xlabel('{\beta} type');
%ylim([-0.25,0.04])
title({'Dependency of task {\it mu} on {\beta}'},'FontSize', 14);
box off
H=gca;
H.LineWidth=1;
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',12)

elseif Param=='V' 

    bar([1],table2array(GorVMu_vs_Betas.Coefficients(2,1)),'barwidth',1,'FaceColor',map(1,:),'EdgeColor',map(1,:))
    hold on
    bar([3],table2array(GorVMu_vs_Betas.Coefficients(3,1)),'barwidth',1,'FaceColor',map(1,:),'EdgeColor',map(1,:))
    hold on
    bar([5],table2array(GorVMu_vs_Betas.Coefficients(4,1)),'barwidth',1,'FaceColor',map(1,:),'EdgeColor',map(1,:))
    hold on
    errorbar([1,3,5],table2array(GorVMu_vs_Betas.Coefficients(2:4,1)),table2array(GorVMu_vs_Betas.Coefficients(2:4,2)),'.k','LineWidth',1.5,'CapSize',1.5)
      text(2.9, 4.72, '*','FontSize', 16)
      plot([2.75,3.25],[4.65,4.65], 'k--','LineWidth', 1.6)
%      text(0.9, 3.3, '*','FontSize', 16)
%      plot([0.75,1.25],[3.2,3.2], 'k--','LineWidth', 1.6)
       text(4.9, 4.72, '*','FontSize', 16)
      plot([4.75,5.25],[4.65,4.65], 'k--','LineWidth', 1.6)
      text(1.95,-1.2, '*','FontSize', 16)
      plot([1.2,2.8],[-0.9,-0.9], 'k--','LineWidth', 1.6)
      text(3,-1.8, '*','FontSize', 16)
      plot([1.2,4.8],[-1.5,-1.5], 'k--','LineWidth', 1.6)
xticks([1,3,5])
%ylim([0,0.17])
xticklabels({'trials - 1:3','trials - 4:6','trials - 7:9',})
ylabel('Correlation Strength');
xlabel('{\beta} type');
title({'Dependency of task {\it vmu} on {\beta}'},'FontSize', 14);
box off
H=gca;
H.LineWidth=1;
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',12)


elseif Param=='S'

    bar([1],table2array(GorS_vs_Betas.Coefficients(2,1)),'barwidth',1,'FaceColor',map(3,:),'EdgeColor',map(3,:))
    hold on
    bar([3],table2array(GorS_vs_Betas.Coefficients(3,1)),'barwidth',1,'FaceColor',map(3,:),'EdgeColor',map(3,:))
    hold on
    bar([5],table2array(GorS_vs_Betas.Coefficients(4,1)),'barwidth',1,'FaceColor',map(3,:),'EdgeColor',map(3,:))
    hold on
    errorbar([1,3,5],table2array(GorS_vs_Betas.Coefficients(2:4,1)),table2array(GorS_vs_Betas.Coefficients(2:4,2)),'.k','LineWidth',1.5,'CapSize',1.5)
       text(0.9, 1.525, '*','FontSize', 16)
       plot([0.75,1.25],[1.5,1.5], 'k--','LineWidth', 1.6)
             text(1.95,-0.6, '*','FontSize', 16)
      plot([1.2,2.8],[-0.5,-0.5], 'k--','LineWidth', 1.6)
      text(3,-0.88, '*','FontSize', 16)
      plot([1.2,4.8],[-0.78,-0.78], 'k--','LineWidth', 1.6)
%  text(1.95,-0.125, '*','FontSize', 16)
%        plot([1.2,2.8],[-0.11,-0.11], 'k--','LineWidth', 1.6)
%      text(3,-0.42, '*','FontSize', 16)
%      plot([1.2,4.8],[-0.38,-0.38], 'k--','LineWidth', 1.6)
% hold on
 %          text(2.9, 0.05, '*','FontSize', 16)
%       plot([2.75,3.25],[0.03,0.03], 'k--','LineWidth', 1.6)
         hold on
%             text(4,-0.12, '*','FontSize', 16)
%       plot([3,5],[-0.1,-0.1], 'k--','LineWidth', 1.6)
%          hold on
%              text(3,-0.15, '*','FontSize', 16)
%        plot([1,5],[-0.13,-0.13], 'k--','LineWidth', 1.6)
      xticks([1,3,5])
xticklabels({'trials - 1:3','trials - 4:6','trials - 7:9',})
ylabel('Correlation Strength');
xlabel('{\beta} type');
ylim([-1,1.7])
title({'Dependency of task {\it SD} on {\beta}'},'FontSize', 14);
box off
H=gca;
H.LineWidth=1;
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',12)

end
end


% figure
%     bar([1,3,5],MuB(1:3,rr,1),'barwidth',0.15)
%     hold on
%     errorbar([1,3,5],MuB(1:3,rr,1),MuB(1:3,rr,2),'.k')
%     hold on
%    bar([1.25,3.25,5.25],VMuB(1:3,rr,1),'barwidth',0.15)
%     hold on
%     errorbar([1.25,3.25,5.25],VMuB(1:3,rr,1),VMuB(1:3,rr,2),'.k')
%         bar([1.5,3.5,5.5],SB(1:3,rr,1),'barwidth',0.15)
%     hold on
%     errorbar([1.5,3.5,5.5],SB(1:3,rr,1),SB(1:3,rr,2),'.k')
% xticks([1.25,3.25,5.25])
% xticklabels({'t:1-3','t:4-6','t:7-9'})
% %ylabel({'The dependency of PANAS Bayesian mood parameters';'on the effect of trial outcomes on mood'});
% ylabel({'The dependency of PANAS Bayesian mood parameters';'on the effect of WoF-Loss on mood'});
