%take each individual's mood rating and arrange in four matricies: run1 run2 run3 run4


function [Gor_Md_run1,Gor_Md_run2,Gor_Md_run3,Gor_Md_run4]=Gor_Md_mat_fr_Model(Md_Inst_Struct)

Gor_Md_run1=nan(length(Md_Inst_Struct),41);
Gor_Md_run2=nan(length(Md_Inst_Struct),41);
Gor_Md_run3=nan(length(Md_Inst_Struct),41);
Gor_Md_run4=nan(length(Md_Inst_Struct),41);

for i=1:length(Md_Inst_Struct);
    
 a=Md_Inst_Struct(i).Gorilla.MoodRate(:,1); 
 b=Md_Inst_Struct(i).Gorilla.MoodRate(:,3);
 c=Md_Inst_Struct(i).Gorilla.MoodRate(:,5);
 d=Md_Inst_Struct(i).Gorilla.MoodRate(:,7);
 
 
Gor_Md_run1(i,:)=a';
Gor_Md_run2(i,:)=b';
Gor_Md_run3(i,:)=c';
Gor_Md_run4(i,:)=d';

 clear a b c d;
    
end




end