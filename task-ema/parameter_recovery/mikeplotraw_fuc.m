function fighand=mikeplotraw_fuc(datain,group, titleu,opts)

if nargin<4
    opts=struct;
end

if nargin<3
    titleu=' ';
end

if ~isfield(opts,'xlabel')
    opts.xlabel='Days';
end
if ~isfield(opts,'xlim')
    opts.xlim=100;
end



map=brewermap(3,'Set1');

somedata=sum(~isnan(datain))>0;

xps=find(somedata==1,1);
xpl=find(somedata==1,1,'last');
datain=datain(:,somedata);

g1vol=squeeze(datain(group==1,:));
g2vol=squeeze(datain(group==2,:));
g3vol=squeeze(datain(group==3,:));


xpoints=xps:xpl;
%xpoints=1:size(datain,2);
transp=0.35;
fighand=figure('Units', 'pixels','Position',[100 100 500 375]);
hold on;
set(gca,'Layer','top','linewidth',3)
set(fighand,'color',[1 1 1]);


hold on;

fi1=jbfill(xpoints,nanmean(g1vol)+(nanstd(g1vol)./sqrt(sum(~isnan(g1vol)))), nanmean(g1vol)-(nanstd(g1vol)./sqrt(sum(~isnan(g1vol)))),map(1,:),map(1,:),0, transp);
fi2=jbfill(xpoints,nanmean(g2vol)+(nanstd(g2vol)./sqrt(sum(~isnan(g2vol)))), nanmean(g2vol)-(nanstd(g2vol)./sqrt(sum(~isnan(g2vol)))),map(2,:),map(2,:),0, transp);
fi3=jbfill(xpoints,nanmean(g3vol)+(nanstd(g3vol)./sqrt(sum(~isnan(g3vol)))), nanmean(g3vol)-(nanstd(g3vol)./sqrt(sum(~isnan(g3vol)))),map(3,:),map(3,:),0, transp);

p1=plot(nanmean(g1vol),'color',map(1,:),'linewidth',3);
p2=plot(nanmean(g2vol),'color',map(2,:),'linewidth',3);
p3=plot(nanmean(g3vol),'color',map(3,:),'linewidth',3);
xlim([0 opts.xlim]);
yl1=ylabel(titleu);
xl1=xlabel(opts.xlabel);
l1=legend([p1 p2 p3],{'Bipolar','Borderline','Control'});
g1=gca;

set( [g1]                       , ...
    'FontName'   , 'Helvetica' );
set([ yl1 xl1 l1 ], ...
    'FontName'   , 'Helvetica', 'FontSize'   , 12          );

set([g1], ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'off'      , ...
  'YMinorTick'  , 'off'      , ...
  'YGrid'       , 'off'      , ...
  'XColor'      , [0 0 0 ], ...
  'YColor'      , [0 0 0], ...
  'LineWidth'   , 2         );
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8/1.5 6/1.5])
%export_fig(f2, 'C:\Users\michaelb\Documents\MRC_intermediate_fellowship\pilot_study\Figures\mikes_figs\fig_s4.tif', '-opengl', '-r300');
