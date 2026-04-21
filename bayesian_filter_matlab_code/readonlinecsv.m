function out=readonlinecsv(in)

fid=fopen(in,'r');

out=[];
while ~feof(fid)
    out=[out,textscan(fgetl(fid),'%q','delimiter',',')];
end

fclose(fid);