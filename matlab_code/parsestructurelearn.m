function out=parsestructurelearn(rawdata,existstruct,runmodel)
out=existstruct;
% check basic parameters
 day=str2double(rawdata{1,2}{find(strcmp(rawdata{1,1},'day'))});
 ppid=str2double(rawdata{1,2}{find(strcmp(rawdata{1,1},'Participant Private ID'))});
 runnum=str2double(rawdata{1,2}{find(strcmp(rawdata{1,1},'runnum'))});
 loaderror=str2double(rawdata{1,2}{find(strcmp(rawdata{1,1},'loaderror'))});
 totmononstart=str2double(rawdata{1,2}{find(strcmp(rawdata{1,1},'totmon'))});
  pubpid=rawdata{1,2}{find(strcmp(rawdata{1,1},'Participant Public ID'))};
 
 if isfield(out,'runnum')
     if ~isempty(out.runnum(runnum))
         error(['already have data for this run of structure learn task participant ',num2str(ppid), ' , run number ', num2str(runnum), '!'])
     end
 end
 
 if loaderror==1
    out.loaderror=1;
    out.loaderrortext=[out.loaderrortext;['load error in structure learn, run number ', num2str(runnum)]];
 end
 
 if ~isfield(out,'ppid')
     out.ppid=ppid;
 elseif out.ppid~=ppid
     error(['participant ',num2str(ppid), 'id has changed in structurelearn, run number ', num2str(runnum), '!'])
 end
 
  if ~isfield(out,'pubpid')
     out.pubpid=pubpid;
 elseif ~strcmp(out.pubpid,pubpid)
     error(['participant ',pubpid, ' public id has changed in structurelearn, run number ', num2str(runnum), '!'])
 end
 
 
ticol=find(strcmp(rawdata{1,1},'Trial Index'));
compcol=find(strcmp(rawdata{1,1},'component'));
tc1col=find(strcmp(rawdata{1,1},'treecode1'));
tc2col=find(strcmp(rawdata{1,1},'treecode2'));
tcchcol=find(strcmp(rawdata{1,1},'treechoicecode'));
tpos1col=find(strcmp(rawdata{1,1},'tree1pos'));
tpos2col=find(strcmp(rawdata{1,1},'tree2pos'));
rtcol=find(strcmp(rawdata{1,1},'Reaction Time'));
mrcol=find(strcmp(rawdata{1,1},'moodrate'));
rncol=find(strcmp(rawdata{1,1},'ratenumber'));
schcol=find(strcmp(rawdata{1,1},'sched'));
t1magcol=find(strcmp(rawdata{1,1},'tree1mag'));
t2magcol=find(strcmp(rawdata{1,1},'tree2mag'));
t1infocol=find(strcmp(rawdata{1,1},'tree1info'));
t2infocol=find(strcmp(rawdata{1,1},'tree2info'));
tmcol=find(strcmp(rawdata{1,1},'totalmon'));
t1colcol=find(strcmp(rawdata{1,1},'tree1col'));
t2colcol=find(strcmp(rawdata{1,1},'tree2col'));
abspos=1; % first column is "event index" but contains a noncoding character that buggers up strcmp



for ll=1:size(rawdata,2)
    if ~strcmp(rawdata{1,ll}{abspos,1},'END OF FILE')
        if strcmp(rawdata{1,ll}{compcol,1},'present')
            trial=str2double(rawdata{1,ll}{ticol,1});
            out.structurelearn.runnum(runnum).sl.trial(trial,1)=trial;
            out.structurelearn.runnum(runnum).sl.choice(trial,1)=str2double(rawdata{1,ll}{tcchcol,1});
            out.structurelearn.runnum(runnum).sl.tc1(trial,1)=str2double(rawdata{1,ll}{tc1col,1});
            out.structurelearn.runnum(runnum).sl.tc2(trial,1)=str2double(rawdata{1,ll}{tc2col,1});
            out.structurelearn.runnum(runnum).sl.tpos1(trial,1)=str2double(rawdata{1,ll}{tpos1col,1});
            out.structurelearn.runnum(runnum).sl.tpos2(trial,1)=str2double(rawdata{1,ll}{tpos1col,1});
            out.structurelearn.runnum(runnum).sl.rt(trial,1)=str2double(rawdata{1,ll}{rtcol,1});
            out.structurelearn.runnum(runnum).sl.asbsoluteposition(trial,1)=str2double(rawdata{1,ll}{abspos,1});
            out.structurelearn.runnum(runnum).sl.totalmon(trial,1)=str2double(rawdata{1,ll}{tmcol,1});
            out.structurelearn.runnum(runnum).sl.treecolour{trial,1}=rawdata{1,ll}{t1colcol,1};
            out.structurelearn.runnum(runnum).sl.treecolour{trial,2}=rawdata{1,ll}{t2colcol,1};
            
            if ~isempty(t1magcol)
            out.structurelearn.runnum(runnum).sl.tree1mag(trial,1)=str2double(rawdata{1,ll}{t1magcol,1});
              out.structurelearn.runnum(runnum).sl.tree2mag(trial,1)=str2double(rawdata{1,ll}{t2magcol,1});
              out.structurelearn.runnum(runnum).sl.tree1info(trial,1)=str2double(rawdata{1,ll}{t1infocol,1});
              out.structurelearn.runnum(runnum).sl.tree2info(trial,1)=str2double(rawdata{1,ll}{t2infocol,1});
            end
            
            
        elseif(strcmp(rawdata{1,ll}{compcol,1},'moodrate'))
             ratenum=str2double(rawdata{1,ll}{rncol,1})+1; % nb ratenums start at 0
             out.structurelearn.runnum(runnum).mr.moodrate(ratenum,1)=str2double(rawdata{1,ll}{mrcol,1});
             out.structurelearn.runnum(runnum).mr.absoluteposition(ratenum,1)=str2double(rawdata{1,ll}{abspos,1});
             
        elseif isempty(rawdata{1,ll}{compcol,1})
try
            out.structurelearn.runnum(runnum).sl.sched=jsondecode(rawdata{1,ll}{schcol,1});
catch
            out.structurelearn.runnum(runnum).sl.sched=NaN;
end
        end
    end
    
end

if isempty(t1magcol)
    out.structurelearn.runnum(runnum).sl.tree1mag=cellfun(@str2num,out.structurelearn.runnum(runnum).sl.sched.Shape1mag);
    out.structurelearn.runnum(runnum).sl.tree2mag=cellfun(@str2num,out.structurelearn.runnum(runnum).sl.sched.Shape2mag);
end

if isempty(t1infocol)
    out.structurelearn.runnum(runnum).sl.tree1info=cellfun(@str2num,out.structurelearn.runnum(runnum).sl.sched.Shape1out);
    out.structurelearn.runnum(runnum).sl.tree2info=cellfun(@str2num,out.structurelearn.runnum(runnum).sl.sched.Shape2out);
end

if runmodel
modelparams.choice=out.structurelearn.runnum(runnum).sl.choice==out.structurelearn.runnum(runnum).sl.tc1;
modelparams.info=[out.structurelearn.runnum(runnum).sl.tree1info out.structurelearn.runnum(runnum).sl.tree2info];
modelparams.mag=[out.structurelearn.runnum(runnum).sl.tree1mag out.structurelearn.runnum(runnum).sl.tree2mag];
out.structurelearn.runnum(runnum).sl.modelfit=fitsimplelrstructurelearn(modelparams);
end


