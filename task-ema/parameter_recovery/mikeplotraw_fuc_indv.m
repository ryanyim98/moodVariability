function fighand=mikeplotraw_fuc_indv(datain,group, titleu,opts)

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

g1vol=squeeze(datain(group==1,:)');

g2vol=squeeze(datain(group==2,:)');
g3vol=squeeze(datain(group==3,:)');

xpoints=1:size(datain,2);
transp=0.35;
fighand=figure('Units', 'pixels','Position',[100 100 500 375]);
hold on;
set(gca,'Layer','top','linewidth',3)
set(fighand,'color',[1 1 1]);


hold on;

p1=plot((g1vol),'color',map(1,:),'linewidth',0.5);
p2=plot((g2vol),'color',map(2,:),'linewidth',0.5);
p3=plot((g3vol),'color',map(3,:),'linewidth',0.5);
xlim([0 opts.xlim]);
yl1=ylabel(titleu);
xl1=xlabel(opts.xlabel);
l1=legend([p1(1) p2(1) p3(1)],{'Bipolar','Borderline','Control'});
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
