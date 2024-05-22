function out=parsestartday2(rawdata,existstruct)
out=existstruct;
% check basic parameters

 ppid=str2double(rawdata{1,2}{find(strcmp(rawdata{1,1},'Participant Private ID'))});
 
 if ~isfield(out,'ppid')
     out.ppid=ppid;
 elseif out.ppid~=ppid
     error(['participant ',num2str(ppid), 'id has changed in start day2!'])
 end
 
 loaderror=str2double(rawdata{1,2}{find(strcmp(rawdata{1,1},'loaderror'))});

  if loaderror==1
     error(['loaderror start day 2 task participant ',num2str(ppid), '!'])
 end
if size(rawdata,2)>2
    out.error=1;
    out.errortext=['data too big start day 2 for participant ',num2str(ppid), '!'];
  %  error(['data too big start day 2 for participant ',num2str(ppid), '!'])
end





