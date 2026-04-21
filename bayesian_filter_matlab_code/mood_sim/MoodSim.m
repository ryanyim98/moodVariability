



function [MdSimOtpt]=MoodSim()


a=rand(100000,1);
b=a<0.01;
c=a>0.99;
c=-c;
d=b+c;

MdSimOtpt=nan(100000,5);

for k=1:3; 

    xy=[0.5,1.25,2]
    
    H=100^(-xy(k));

    
x2=nan(100000,1);

for t=1:100000;

j=(1:t)';
x2(t,:)=sum(d(j).*exp(H.*(j-t)));
 
end

MdSimOtpt(:,k)=x2;

end




% for k=3:4; 
% 
%     H=100^(-(k-2));
% 
%     d=d*2;
%     
% x2=nan(size(100000,1),1);
% 
% for t=1:100000;
% 
% j=(1:t)';
% x2(t,:)=sum(d(j).*exp(H.*(j-t)));
%  
% end
% 
% MdOtpt(:,k)=x2;
% 
% end

end
