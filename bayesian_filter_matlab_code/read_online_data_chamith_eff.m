function out=read_online_data_chamith_eff(number,resultdir)

if isnumeric(number)
    number=num2str(number);
end

if nargin<2
    resultdir='~/Desktop/MoodInstability';
    %resultdir='C:\Users\micha\Documents\Mike_new_scripts';
end


out=struct;

df=dir(strcat(resultdir,'/',number));

% get list of participants
%first get intro file
for ff=1:size(df,1)
    if ~isempty(strfind(df(ff).name,'zexu'))
        introf=df(ff).name;
    end
end
alldata=readonlinecsv(strcat(resultdir,'/',number,'/',introf));
ppid=[];
%split up participants
for line=2:size(alldata,2)-1
    ppid(line-1,1)=str2double(alldata{1,line}{find(strcmp(alldata{1,1},'Participant Private ID'))});
end
subids=unique(ppid);


for file=1:size(df,1)
    if df(file).isdir==0
        blankfile=0;
        %get initial data from file
        fid=fopen(strcat(resultdir,'/',number,'/',df(file).name),'r');
        fileheaders=textscan(fgetl(fid),'%q','delimiter',',');
        PPIDcol=find(strcmp(fileheaders{1,1},'Participant Private ID'));
        initpos=ftell(fid);
        dl1=textscan(fgetl(fid),'%q','delimiter',',');
        if strcmp(dl1{1,1},'END OF FILE')
            blankfile=1;
        else
            task{file,1}=dl1{1,1}{find(strcmp(fileheaders{1,1},'Task Name'))};
        end
        fseek(fid,0,1);
        filesize=ftell(fid);
        fclose(fid);
        sub='';
        fpos=initpos;
        while fpos<filesize
            [subdata, csub, fpos]=readonlinecsv_subject(strcat(resultdir,'/',number,'/',df(file).name), fpos, PPIDcol,filesize, fileheaders);
            
            if blankfile==0
            
                    sub=find(subids==csub);
                    
                    
                    out.subject(sub,1).data.ppid=subids(sub);
                    if ~isfield(out.subject(sub,1).data,'error')
                        out.subject(sub,1).data.loaderror=[];
                        out.subject(sub,1).data.loaderrortext={};
                        out.subject(sub,1).data.error=[];
                        out.subject(sub,1).data.errortext={};
                    end
                    
                    currtask=task{file,1};
                    if startsWith(currtask,'structurelearn hd')
                        
                        currtask=regexprep(currtask,' .*','');
                        
                    elseif startsWith(currtask,'intro') || startsWith(currtask,'uncorrlosefirst') || startsWith(currtask,'uncorrwinfirst')
                        currtask=regexprep(currtask,' .*','');
                        
                    end
                    
                    
                    switch currtask
                        case 'structurelearn'
                            out.subject(sub).data=parsestructurelearn(subdata,out.subject(sub).data,0);
                        case 'structurelearn-- test'
                            out.subject(sub).data=parsestructurelearntest(subdata,out.subject(sub).data);
                            %                             catch
                            %                                 out.subject(sub).errordata=subdata;
                            %                             end
                        case 'corrwinfirst'    % groups 1= corr,win first; 2=corr, loose first; 3=uncorr win first, 4=uncorr loose first
                            out.subject(sub).data.group=1;
                            out.subject(sub).data.woforder=[1 -1];
                            out.subject(sub).data.structure=1;
                        case 'corrlosefirst'
                            out.subject(sub).data.group=2;
                            out.subject(sub).data.woforder=[-1 1];
                            out.subject(sub).data.structure=1;
                        case 'nocorrwinfirst'    % groups 1= corr,win first; 2=corr, loose first; 3=uncorr win first, 4=uncorr loose first
                            out.subject(sub).data.group=5;
                            out.subject(sub).data.woforder=[1 -1];
                            out.subject(sub).data.structure=3;
                        case 'nocorrlosefirst'
                            out.subject(sub).data.group=6;
                            out.subject(sub).data.woforder=[-1 1];
                            out.subject(sub).data.structure=3;
                        case 'uncorrwinfirst'
                            out.subject(sub).data.group=3;
                            out.subject(sub).data.woforder=[1 -1];
                            out.subject(sub).data.structure=0;
                        case 'uncorrlosefirst'
                            out.subject(sub).data.group=4;
                            out.subject(sub).data.woforder=[-1 1];
                            out.subject(sub).data.structure=0;
                        case 'const mixed'
                            out.subject(sub).data.group=1;
                            out.subject(sub).data.schedorder=[-1 1];
                            out.subject(sub).data.woforder=[-1 1];
                            out.subject(sub).data.structure=99;
                        case 'vol mixed'
                            out.subject(sub).data.group=2;
                            out.subject(sub).data.schedorder=[1 -1];
                            out.subject(sub).data.woforder=[1 -1];
                            out.subject(sub).data.structure=99;
                        case 'HPS'
                            out.subject(sub).data=parsehps(subdata,out.subject(sub).data);
                        case 'cesd'
                            out.subject(sub).data=parsecesd(subdata,out.subject(sub).data);
                        case 'STAI trait'
                            out.subject(sub).data=parsetrait(subdata,out.subject(sub).data);
                        case 'STAI state'
                            out.subject(sub).data=parsestate(subdata,out.subject(sub).data,1);
                        case 'STAI state day2'
                            out.subject(sub).data=parsestate(subdata,out.subject(sub).data,2);
                        case 'intro'
                            out.subject(sub).data=parseintro(subdata,out.subject(sub).data);
                            
                        case 'intro mixed'
                            out.subject(sub).data=parseintro(subdata,out.subject(sub).data);
                            %                 otherwise
                            %                     sprintf('%s','other')
                            
                        case 'startofday2 nr'
                            out.subject(sub).data=parsestartday2(subdata,out.subject(sub).data);
                        case 'demo'
                            out.subject(sub).data=parsedemo(subdata,out.subject(sub).data);
                            
                            
                    end
                    
                
            end
            
           
        end
    end
end



if ~isfield(out.subject(1).data,'schedorder')
    for sub= 1:size(out.subject,1)
        out.subject(sub).data.schedorder=-99;
    end
    
end

for sub=1:size(out.subject,1)
    out.subject(sub).data.allmoodrate=out.subject(sub).data.intro.mr.moodrate;
    out.subject(sub).data.allmoodrate_order=out.subject(sub).data.intro.mr.moodrate;
    if isempty(out.subject(sub).data.error)
        if size(out.subject(sub).data.structurelearn.runnum,2)>4 % one participant (307) had a problem an extra blank run in their data
            nc=0;            
            for oo=1:size(out.subject(sub).data.structurelearn.runnum,2)
                if ~isempty(out.subject(sub).data.structurelearn.runnum(oo).mr)
                    nc=nc+1;
                    newdat(nc).mr=out.subject(sub).data.structurelearn.runnum(oo).mr;
                    newdat(nc).sl=out.subject(sub).data.structurelearn.runnum(oo).sl;
                end
            end
            out.subject(sub).data.structurelearn.runnum=newdat;
        end
        for kk=1:4
            out.subject(sub).data.allmoodrate_order=[ out.subject(sub).data.allmoodrate_order;out.subject(sub).data.structurelearn.runnum(kk).mr.moodrate];
        end
        if out.subject(sub).data.woforder(1)==1 | out.subject(sub).data.schedorder(1)==1
            for ii=1:4
                out.subject(sub).data.allmoodrate=[ out.subject(sub).data.allmoodrate;out.subject(sub).data.structurelearn.runnum(ii).mr.moodrate];
            end
            
        end
    end
end


% arrange data for analysis
for sub=1:size(out.subject,1)
    if isempty(out.subject(sub).data.error)
        if size(out.subject(sub).data.structurelearn.runnum,2)==4
            out.moodrate(sub,:)= out.subject(sub).data.allmoodrate;
            out.moodrate_order(sub,:)=out.subject(sub).data.allmoodrate_order;
            md=[];
            
            out.errorsummary(sub,1)=0;
        else
            
            out.moodrate(sub,:)=NaN;
            out.errorsummary(sub,1)=1;
            
        end
        
    else
        out.errorsummary(sub,1)=1;
    end
    
    
end


incompsub=out.errorsummary==1;

if ~isempty(incompsub)
    out.moodrate(incompsub,:)=[];
    out.moodrate_order(incompsub,:)=[];
    out.subject(incompsub)=[];
end

save(['onlinedata_',number],'out')