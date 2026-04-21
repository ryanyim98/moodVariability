function out=parsecesd(rawdata,existstruct)
out=existstruct;
% check basic parameters

 ppid=str2double(rawdata{1,2}{find(strcmp(rawdata{1,1},'Participant Private ID'))});
 
 if ~isfield(out,'ppid')
     out.ppid=ppid;
 elseif out.ppid~=ppid
     error(['participant ',num2str(ppid), 'id has changed in cesd!'])
 end
 


qkcol=find(strcmp(rawdata{1,1},'Question Key'));
respcol=find(strcmp(rawdata{1,1},'Response'));
abspos=1;

for ll=1:size(rawdata,2)
    if ~strcmp(rawdata{1,ll}{abspos,1},'END OF FILE')
        qkdat=rawdata{1,ll}{qkcol,1};
        
        if strcmp(regexprep(qkdat,'.*-',''),'quantised')
            qnum=str2double(regexprep(regexprep(qkdat,'response-',''),'-.*',''))-1;
            out.cesd.qnum(qnum,1)=qnum;
            out.cesd.qans(qnum,1)=str2double(rawdata{1,ll}{respcol,1});
            out.cesd.asbsoluteposition(qnum,1)=str2double(rawdata{1,ll}{abspos,1});
            
        end
    end
    
end

out.cesd.totalscore=sum(out.cesd.qans(1:20,1)-1);

% check they were paying attention
if out.cesd.qans(21)==3
    out.catchquestion=1;
else
    out.catchquestion=0;
end






