function plot_example_uncert()
rng(123)
fig = gcf;
hold on;
xposvol=[0.6 0.4];
noise = 0.1;

x = [0.1:0.01:0.9];
y1 = normpdf(x,xposvol(1),noise);
y2 = normpdf(x,xposvol(2),noise);
c1 = [211 211 211]/255;
c2 = [128 128 128]/255;

l1 = line(x,y1,'lineWidth',3); hold on;
l1.Color = c1; %brown
l2 = line(x,y2,'lineWidth',3);
l2.Color = c2; %pink
ylim([-4 4.5]);

%create Gaussian distribution (mean 0, SD 0.025) and draw from this
%distribution
Npoint = 60;
gaussian_noise = normrnd(0,2*noise,Npoint,1);

point_pos = reshape(repmat(xposvol,Npoint/2,1),[1 Npoint]);
point_pos = point_pos + gaussian_noise';
p1 = plot(point_pos(1:(Npoint/2)),-1.1:(1/(Npoint/2-1)):-0.1,'.');
p1.Color = c1;
p1.MarkerSize = 11;
p2 = plot(point_pos((Npoint/2+1):Npoint),-2.6:(1/(Npoint/2-1)):-1.6,'.');
p2.Color = c2;
p2.MarkerSize = 11;


%add affect ratings
y_ = repmat(-3,10);
x_ = 0.095:(0.81/(length(y_)-1)):0.905;
plot(x_,y_,'k-','lineWidth',3);

%ticks
line([0.105 0.105],[-3 -3.2],'lineWidth',3,'Color','k'); hold on;
line([0.5 0.5],[-3 -3.2],'lineWidth',3,'Color','k'); hold on;
line([0.895 0.895],[-3 -3.2],'lineWidth',3,'Color','k'); hold on;

axis off

end