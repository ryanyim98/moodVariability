
load('SimMdTS.mat')

SimMdTS_long=SimMdTS(:,100.*(1:100));

for i=1:27
    
C=randi(95001);
SimMdTS_temp(i,1:3000)=SimMdTS(i,C:C+2999); 

end

SimMdTS_short=SimMdTS_temp(:,30.*(1:100))