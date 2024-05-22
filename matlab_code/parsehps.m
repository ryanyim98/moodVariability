function out=parsehps(rawdata,existstruct)
out=existstruct;
% check basic parameters

 ppid=str2double(rawdata{1,2}{find(strcmp(rawdata{1,1},'Participant Private ID'))});
 
 if ~isfield(out,'ppid')
     out.ppid=ppid;
 elseif out.ppid~=ppid
     error(['participant ',num2str(ppid), 'id has changed in hps!'])
 end
 


qkcol=find(strcmp(rawdata{1,1},'Question Key'));
respcol=find(strcmp(rawdata{1,1},'Response'));
abspos=1;

for ll=1:size(rawdata,2)
    if ~strcmp(rawdata{1,ll}{abspos,1},'END OF FILE')
        qkdat=rawdata{1,ll}{qkcol,1};
        
        if strcmp(regexprep(qkdat,'.*-',''),'quantised')
            qnum=str2double(regexprep(regexprep(qkdat,'response-',''),'-.*',''))-1;
            out.hps.qnum(qnum,1)=qnum;
            out.hps.qans(qnum,1)=str2double(rawdata{1,ll}{respcol,1});
            out.hps.asbsoluteposition(qnum,1)=str2double(rawdata{1,ll}{abspos,1});
            
        end
    end
    
end

pnhps=[0;1;1;0;1;0;1;1;1;1;1;1;1;0;0;1;1;1;1;1;1;0;1;0]; % whether items are scored positively or negatively

scorehps=out.hps.qans;
scorehps(pnhps==0)=6-scorehps(pnhps==0);
out.hps.totalscore=sum(scorehps);






