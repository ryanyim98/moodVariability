 
for i=1:27
MuMat(i,:)=out(i).moddata.muEst';        
        VMuMat(i,:)=out(i).moddata.vmuEst';     
        SMat(i,:)=out(i).moddata.sEst';
end



mean(VMuMat([1,4,7,10,13,16,19,22,25],97:101),2);
 
mean(VMuMat([2,5,8,11,14,17,20,23,26],97:101),2);
  
mean(VMuMat([(1:9).*3],97:101),2);
  
  
plot(ones(9,1),mean(VMuMat([1,4,7,10,13,16,19,22,25],97:101),2))
hold on
plot(2.*(ones(9,1)), mean(VMuMat([2,5,8,11,14,17,20,23,26],97:101),2))
hold on
plot(3.*(ones(9,1)),mean(VMuMat([(1:9).*3],97:101),2))
xlim([0,4])




plot(ones(9,1),mean(MuMat([1:3,10:12,19:21],:),2));
 hold on
plot(2.*(ones(9,1)),mean(MuMat([4:6,13:15,22:24],:),2));
  hold on
plot(3.*(ones(9,1)),mean(MuMat([7:9,16:18,25:27],:),2));
xlim([0,4])


plot(ones(9,1),mean(SMat([1:9],97:101),2));
 hold on
plot(2.*(ones(9,1)),mean(SMat([10:18],97:101),2));
  hold on
plot(3.*(ones(9,1)),mean(SMat([19:27],97:101),2));
xlim([0,4])

scatter(mean(MuMat_L,2),mean(MuMat_S,2))
scatter(mean(VMuMat_L,2),mean(VMuMat_S,2))
scatter(mean(SMat_L,2),mean(SMat_S,2))




scatter(mean(MuMat_L([1:3,10:12,19:21],:),2),mean(MuMat_S([1:3,10:12,19:21],:),2))
 hold on
scatter(mean(MuMat_L([4:6,13:15,22:24],:),2),mean(MuMat_S([4:6,13:15,22:24],:),2))
  hold on
scatter(mean(MuMat_L([7:9,16:18,25:27],:),2),mean(MuMat_S([7:9,16:18,25:27],:),2))



scatter(mean(VMuMat_L([1,4,7,10,13,16,19,22,25],97:101),2),mean(VMuMat_S([1,4,7,10,13,16,19,22,25],97:101),2))
 hold on
scatter(mean(VMuMat_L([2,5,8,11,14,17,20,23,26],97:101),2),mean(VMuMat_S([2,5,8,11,14,17,20,23,26],97:101),2))
  hold on
scatter(mean(VMuMat_L([(1:9).*3],97:101),2),mean(VMuMat_S([(1:9).*3],97:101),2))

scatter(mean(SMat_L([1:9],97:101),2),mean(SMat_S([1:9],97:101),2))
 hold on
scatter(mean(SMat_L([10:18],97:101),2),mean(SMat_S([10:18],97:101),2))
  hold on
scatter(mean(SMat_L([19:27],97:101),2),mean(SMat_S([19:27],97:101),2))