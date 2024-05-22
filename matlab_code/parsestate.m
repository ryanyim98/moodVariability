function out=parsestate(rawdata,existstruct,day)
out=existstruct;
% check basic parameters

 ppid=str2double(rawdata{1,2}{find(strcmp(rawdata{1,1},'Participant Private ID'))});
 
 if ~isfield(out,'ppid')
     out.ppid=ppid;
 elseif out.ppid~=ppid
     error(['participant ',num2str(ppid), 'id has changed in state, day ', num2str(day), '!'])
 end
 


qkcol=find(strcmp(rawdata{1,1},'Question Key'));
respcol=find(strcmp(rawdata{1,1},'Response'));
abspos=1;

for ll=1:size(rawdata,2)
    if ~strcmp(rawdata{1,ll}{abspos,1},'END OF FILE')
        qkdat=rawdata{1,ll}{qkcol,1};
        
        if strcmp(regexprep(qkdat,'.*-',''),'quantised')
            qnum=str2double(regexprep(regexprep(qkdat,'response-',''),'-.*',''))-1;
            out.state.qnum(qnum,day)=qnum;
            out.state.qans(qnum,day)=str2double(rawdata{1,ll}{respcol,1});
            out.state.asbsoluteposition(qnum,day)=str2double(rawdata{1,ll}{abspos,1});
            
        end
    end
    
end

pnstate=[0;0;1;1;0;1;1;0;1;0;0;1;1;1;0;0;1;1;0;0]; % whether items are scored positively or negatively

scorestate=out.state.qans(:,day);
scorestate(pnstate==0)=5-scorestate(pnstate==0);
out.state.totalscore(day)=sum(scorestate);






