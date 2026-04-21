function out=parsedemo(rawdata,existstruct)
out=existstruct;
% check basic parameters

 ppid=str2double(rawdata{1,2}{find(strcmp(rawdata{1,1},'Participant Private ID'))});
 
 if ~isfield(out,'ppid')
     out.ppid=ppid;
 elseif out.ppid~=ppid
     error(['participant ',num2str(ppid), 'id has changed in demo!'])
 end
 


qkcol=find(strcmp(rawdata{1,1},'Question Key'));
respcol=find(strcmp(rawdata{1,1},'Response'));
abspos=1;

for ll=1:size(rawdata,2)
    if ~strcmp(rawdata{1,ll}{abspos,1},'END OF FILE')
        qkdat=rawdata{1,ll}{qkcol,1};
        
        if strcmp(qkdat,'response-1-quantised')
            out.demo.gender=str2double(rawdata{1,ll}{respcol,1});
            
        elseif strcmp(qkdat,'response-3')
             out.demo.age=str2double(rawdata{1,ll}{respcol,1});
        elseif strcmp(qkdat,'response-4')
             out.demo.yearsedu=str2double(rawdata{1,ll}{respcol,1});
            
        end
    end
    
end






