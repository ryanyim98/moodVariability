function out=parseintro(rawdata,existstruct)
out=existstruct;
% check basic parameters
 ppid=str2double(rawdata{1,2}{find(strcmp(rawdata{1,1},'Participant Private ID'))});
 
 
 if ~isfield(out,'ppid')
     out.ppid=ppid;
 elseif out.ppid~=ppid
     error(['participant ',num2str(ppid), 'id has changed in intro!'])
 end
 
 
mrcol=find(strcmp(rawdata{1,1},'moodrate'));
compcol=find(strcmp(rawdata{1,1},'component'));

abspos=1; % first column is "event index" but contains a noncoding character that buggers up strcmp



for ll=1:size(rawdata,2)
    if ~strcmp(rawdata{1,ll}{abspos,1},'END OF FILE')
      if(strcmp(rawdata{1,ll}{compcol,1},'moodrate'))

             out.intro.mr.moodrate(1,1)=str2double(rawdata{1,ll}{mrcol,1});
            
        end
    end
    
end





