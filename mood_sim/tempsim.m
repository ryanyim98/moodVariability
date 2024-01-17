
MdSimOutPut_1_1_1=MdSimOtpt
MdSimOutPut2=MdSimOutPut*2;
MdSimOutPut3=MdSimOutPut*3;

MdSimOutPut3=MdSimOutPut2*2;
MdSimOutPut4=MdSimOutPut2*3;

plot(MdSimOutPut3(:,2))
hold on
plot(MdSimOutPut4(:,2))
plot(MdSimOutPut4)
MdSimOutPut_1_1_2=MdSimOutPut_1_1_1+4;
plot(MdSimOutPut_1_1_1)
hold on
plot(MdSimOutPut_1_1_2)
MdSimOutPut_1_1_3=MdSimOutPut_1_1_1-4;
MdSimOutPut_1_2_2=MdSimOutPut_1_2_1+4;
MdSimOutPut_1_2_3=MdSimOutPut_1_2_1-4;
MdSimOutPut_1_3_2=MdSimOutPut_1_3_1+4;
MdSimOutPut_1_3_3=MdSimOutPut_1_3_1-4;
SimMdTS=[MdSimOutPut_1_1_1,MdSimOutPut_1_1_2,MdSimOutPut_1_1_3,...
MdSimOutPut_1_2_1,MdSimOutPut_1_2_2,MdSimOutPut_1_2_3,...
MdSimOutPut_1_3_1,MdSimOutPut_1_3_2,MdSimOutPut_1_3_3];
plot(SimMdTS)
plot(SimMdTS(100.*(1:100),:))
min(SimMdTS)
max(SimMdTS)
SimMdTS=SimMdTS';
plot(SimMdTS)
SimMdTS_long=SimMdTS(:,100.*(1:100));
C = randi([0 12],1000);
C = randi(1000)
100000-100
99901:99901+99
C = randi(99901)
C:C+99
load('SimMdTS.mat')
MakeTS
plot(SimMdTS_short(1,:))
plot(SimMdTS_short(2,:))
plot(SimMdTS_short(27,:))
99001+999
MakeTS
plot(SimMdTS_short(1,:))
plot(SimMdTS_short(27,:))
plot(SimMdTS_short(14,:))
plot(SimMdTS_short(27,:))
plot(SimMdTS_short(3,:))
plot(SimMdTS_short(2,:))
MakeTS
plot(SimMdTS_short(1,:))
plot(SimMdTS_short(2,:))
plot(SimMdTS_short(3,:))
plot(SimMdTS_short(27,:))
clear all
load('SimMdTS.mat')
MakeTS
plot(SimMdTS_short(1,:))
plot(SimMdTS_short(27,:))
plot(SimMdTS_short(3,:))
plot(SimMdTS_short')
MakeTS
plot(SimMdTS_short')
MakeTS
plot(SimMdTS_short')
%-- 15/07/2022 13:36 --%

