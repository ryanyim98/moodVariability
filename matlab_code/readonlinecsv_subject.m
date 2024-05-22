function [out,subpp, endpos]=readonlinecsv_subject(in, start,PPIDcol, filesize, headers)

fid=fopen(in,'r');
fseek(fid,start,-1);
nl=textscan(fgetl(fid),'%q','delimiter',',');
subpp=str2double(nl{1,1}{PPIDcol});
nextpp=subpp;
endpos=start;
out=headers;
while nextpp==subpp && endpos<filesize
   
    out=[out,nl];
    endpos=ftell(fid);
     if endpos<filesize
    nl=textscan(fgetl(fid),'%q','delimiter',',');
    end
    
    if ftell(fid)<filesize
        nextpp=str2double(nl{1,1}{PPIDcol});
     else
            endpos=filesize;
    end

end

fclose(fid);