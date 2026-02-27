function out=maglearn_func_vardiff_flat_miss(input,params)


% deal with missing data by performing information leak (transitional
% matrices dealing with structure of world) in the absence of likelihood
% updating (should relax posterior). Missing data should be a NaN

%NB this version has been tweaked to allow compilation of mex file (it was
%slower than the uncompiled version).

% the cose has been made as efficient as possible.

%It allows variable grid_acc per
%dimension (grid acc needs to be a 5 item vector). dimsize is the lenght of
%each dimension
%default values
if nargin<2; params=struct; end
if ~isfield(params,'murange'); params.murange=[inv_logit(-5,1) inv_logit(5,1)]; end
if ~isfield(params,'vmurange'); params.vmurange=[0.001 100]; end
if ~isfield(params,'kmurange'); params.kmurange=[5e-5 100]; end
if ~isfield(params,'srange'); params.srange=[0.01 10]; end
if ~isfield(params,'vsrange'); params.vsrange=[0.001 100]; end
if ~isfield(params,'dimsize'); params.dimsize=[36 27 21 27 27]; end
if ~isfield(params,'flattenpoints'); params.flattenpoints=[]; end

% define ranges for each dimension. mu is in logit space, other dimensions
% are in log space
out.muvec = inv_logit(params.murange(1)):((inv_logit(params.murange(2))-inv_logit(params.murange(1)))/(params.dimsize(1)-1)):inv_logit(params.murange(2));  
out.vmulog = log(params.vmurange(1)):((log(params.vmurange(2))-log(params.vmurange(1)))/(params.dimsize(2)-1)):log(params.vmurange(2));
out.kmulog = log(params.kmurange(1)):((log(params.kmurange(2))-log(params.kmurange(1)))/(params.dimsize(3)-1)):log(params.kmurange(2));
out.slog=log(params.srange(1)):((log(params.srange(2))-log(params.srange(1)))/(params.dimsize(4)-1)):log(params.srange(2));
out.vslog=log(params.vsrange(1)):((log(params.vsrange(2))-log(params.vsrange(1)))/(params.dimsize(5)-1)):log(params.vsrange(2));

out.musize=params.dimsize(1);
out.vmusize = params.dimsize(2);
out.kmusize = params.dimsize(3);
out.ssize=params.dimsize(4);
out.vssize=params.dimsize(5);

li=length(input);

out.ntrials=li;

out.muDist=zeros(li,params.dimsize(1));
out.muEst=zeros(li,1);
out.vmuDist=zeros(li,params.dimsize(2));
out.vmuEst=zeros(li,1);
out.kmuDist=zeros(li,params.dimsize(3));
out.kmuEst=zeros(li,1);
out.sDist=zeros(li,params.dimsize(4));
out.sEst=zeros(li,1);
out.vsDist=zeros(li,params.dimsize(5));
out.vsEst=zeros(li,1);
out.volnoise=zeros(li,params.dimsize(2),params.dimsize(4));
out.KLdiv=zeros(li,1);
out.entropy=zeros(li,1);
% Optimal Bayesian Magnitude Learner with 5 variables
%
% the additional input item mu_gridacc gives a separate grid accuracy for
% mu this is to checck whether differential output caused by grid_acc is
% driven by effects on mu. Theoretically, if true, this would allow us to
% have a precise mu with less precise higher factors, which would make
% computational time feasible.

% 2/3/2018 some minor alterations of code to increase efficancy

% 18/4/2017 add a line of code to calculate KL divergence

% 05-09-2016
% update 7-10-2016 -- change to the final update-- update performed on
% dummy variable rather than directly back onto joint distribution (which
% lead to a small numerical error).
%
% Adapted from volatility learner of Meltem Sevgi.
% Also see the original .cpp code by Tim Behrens.
% This learner estimates 5 variables from the following generative model
%
% Data are continuous numbers between 0 and 1. Data are transformed using the inverse
% logit so that they are on the real line.

% This model assumes the (transformed) data are generated from a gaussian
% process with mean mu and SD exp(s).  that mu can change over time with probabilty
% of mu at time i+1 being given by a gaussian function centred on mu at
% time i and with a SD of exp(vmu). vmu itself changes over time with probability of value at
% time i+1 being given by a gaussian with mean of vmu at time i and a SD of
% exp(kmu). NB the part above is essentially identical to Tim's volatility
% learner with the expception that the process is gaussian rather than
% beta.

% In addition to the above s (log of the SD of the generative gaussian) can
% change over time. s at i+1 is given by s at i with sd exp(vs). Note this
% differs from the initial magnitude learner in that there is no ks
% variable

% Hopefully this will allow the model to differentiate between changing
% mean of the process (i.e. first set of variables) and changing SD of
% generative distribution.

% Note grid_acc controls the size of the grid used to represent each
% parameter (and therefore the size of the joint distribution). A higher
% number gives a larger grid (and so is generally better), however a higher
% number also makes execution slower and uses more memory. Generally I : 1)
% run initially using a small grid_acc (e.g. 0.3/0.4) when I am happy it is
% working I 2) increase grid_acc until it is the maximum tolerable (i.e.
% wrt to memory and time to run analysis). Finally I run the analysis using
% grid_acc which range up to this maximum to check whether I am getting
% different results or whether they are levelling off (i.e. using a very
% coarse grid will alter results).

% write_file saves a mat file of the output %fig_out flags whether to
% generate summary plots




%%%%%%%%%%%%%%%%%%%%Transform Input Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data are assumed to lie either between 0 and 1 or 0 and 100. In the later
% case they are first transformed to 0 to 1 scale. In both cases the data
% are then transformed using inv_logit to the infinite real line.

%reward=load('trial1.txt');
reward=input;
%reward=reward(121:end);
% transform data to real line
if max(reward)>1
    reward=reward./100;
end
trans_reward=inv_logit(reward);

%tic;

%%%%%%%%%%%%%%%%%%%%%Define Parameter Grids %%%%%%%%%%%%%%%%%%%%%%%

% first define limits of the parameters which deal with a moving process.
% For each parameter there is a minimum and maximum value and then a
% spacing parameter (further divided by grid_acc) which controls number of
% points between these values on the grid. Values for each parameter are
% selected to cover range, then tweaked having fed data to learner to make
% sure potential values are covered


%%%%%%%%%%%%%%%%%% Initialise Joint Distribution %%%%%%%%%%%%%%%%%%%%%%%%

% joint dist is the full joint distribution of all parameters. Initialised
% to a flat prior
jointdist = (ones(out.musize, out.vmusize, out.kmusize,out.ssize,out.vssize))./(out.musize*out.vmusize*out.kmusize*out.ssize*out.vssize);

jd_old=jointdist; % use this to hold the previous joint dist to calculare the KL divergence



%%%%%%%%%%%%%%%%%%%Calcuate Transistional Matrices for Updating Joint Dist
%%%%%%%%%%%%%%%%%%%


% precompute p(vmui+1|vmui,k) for every vmu_{i+1}, vmu_i, kmu

vmup1gvmukmu = zeros(out.vmusize, out.vmusize, out.kmusize); % 3d array for vmu transition.
tmpvmu = zeros(out.vmusize, out.vmusize);  % to keep N(I_{i+1},k2

for k = 1 : out.kmusize
    for I = 1:out.vmusize
        for Ip1 = 1:out.vmusize
            
            var = exp(out.kmulog(k)*2); % k is stdev
            % below is the probability density function of a gaussian with
            % mean vmu and SD kmu at point vmu(i+1). It essentially provides the probability of
            % vmup1 given vmu and kmu
            % tmpI(Ip1, I) = (exp(-power((Ilog(I) - Ilog(Ip1)),2))/(2*var)) / (sqrt(2*pi*var)); % there is an error in the brackets here (the (2*var) should be part of the exponential)
            tmpvmu(Ip1, I) = (exp(-power((out.vmulog(I) - out.vmulog(Ip1)),2)/(2*var))) / (sqrt(2*pi*var)); % this is corrected
        end
        % normalise across range of vmu;
        tmpvmu(:,I) = tmpvmu(:,I)./sum(tmpvmu(:,I)); % this is a right stochastic (transitional) matrix.
    end
    
    %Probability of vmu on next trial given vmu and kmu on current trial.
    vmup1gvmukmu(:,:,k) = tmpvmu; % place tmpI in it. (overall this should sum to ksize*Isize).
end


% precompute p(mui+1|mui,vmui+1) for every mu_{i+1}, mu_i, vmu_{i+1}
rmup1muvmup1 = zeros(out.musize, out.musize, out.vmusize);
tmpp = zeros(out.musize, out.musize);
for Ip1 = 1:out.vmusize
    for r = 1:out.musize
        for rp1 = 1:out.musize
            %Normal distribution of mu given previous mu and vmu
            var=exp(out.vmulog(Ip1)*2); % variance of normal pdf
            
            tmpp(rp1,r)=(exp(-power((out.muvec(r) - out.muvec(rp1)),2)/(2*var))) / (sqrt(2*pi*var));
            
        end
        tmpp(:,r) = tmpp(:,r)./sum(tmpp(:,r)); % normalise across each range of mu
    end
    rmup1muvmup1(:,:,Ip1) = tmpp; % place tmpp in it. Probability of r on next trial given r on this trial and I on next trial
end


%update of vs-- not needed with 5 variables
% vsp1gvsks = zeros(out.vssize, out.vssize, kssize); % 3d array for vmu transition.
% tmpvs = zeros(out.vssize, out.vssize);  % to keep N(I_{i+1},k2
% tmpvmu2=tmpvs;
% for k = 1 : kssize
%     for I = 1:out.vssize
%         for Ip1 = 1:out.vssize
%             % N(I_{i+1},k2)
%             var = exp(kslog(k)*2); % k is stdev
%             % below is the probability density function of a gaussian with
%             % mean vmu and SD kmu at point vmu(i+1). It essentially provides the probability of
%             % vmup1 given vmu and kmu
%
%             tmpvs(Ip1, I) = (exp(-power((out.vslog(I) - out.vslog(Ip1)),2)/(2*var))) / (sqrt(2*pi*var)); % this is corrected
%         end
%         % normalise so p(i_i+1|I_i,k) sums to 1;
%         tmpvs(:,I) = tmpvs(:,I)./sum(tmpvs(:,I)); % this is a right stochastic (transitional) matrix.
%     end
%
%     %Probability of vmu on next trial given vmu and kmu on current trial.
%     vsp1gvsks(:,:,k) = tmpvs; % place tmpI in it. (overall this should sum to ksize*Isize).
% end

% precompute update on s
rsp1svsp1 = zeros(out.ssize, out.ssize, out.vssize);
tmpp = zeros(out.ssize, out.ssize);
for vsp1 = 1:out.vssize
    for ss = 1:out.ssize
        for ss1 = 1:out.ssize
            %Normal distribution of mu given previous mu and vmu
            var=exp(out.vslog(vsp1)*2); % variance of normal pdf
            
            tmpp(ss1,ss)=(exp(-power((out.slog(ss) - out.slog(ss1)),2)/(2*var))) / (sqrt(2*pi*var));
            
        end
        tmpp(:,ss) = tmpp(:,ss)./sum(tmpp(:,ss)); % normalise across each range of s
    end
    rsp1svsp1(:,:,vsp1) = tmpp; % place tmpp in it. Probability of s on next trial given s on this trial and vs on next trial
end

%
%%%%%%%%%%%%%% Allocate Output Variables for Memory %%%%%%%%%%%%%%%%%%%%
%note parameters are mu, vmu, kmu, s, vs. Each parameters outputs the
%marginal distribution for that parameter on each trial as well as the
%expected value. volnoise is the 2D marginal distribution of vmu and s-- these are
% equivalent to unexpected and expected uncertainty and so this
% distribution shows the models current belief about the value of these
% parameters. KLdiv holds the KL divergence for each trial (distance
% measure across the whole joint distribution, can be considered a measure
% of information gained per trial).




% initialise arrays
pp1Ip1k = zeros(out.musize, out.vmusize, out.kmusize,out.ssize,out.vssize);
pvmup1kmu = zeros(out.musize, out.vmusize, out.kmusize,out.ssize,out.vssize);

%%%%%%%%%%%%Iterate through Trials, Updating Joint Distribution %%%%%%%%


for trial = 1:length(reward)
    %for trial=1
    %trial
    %   t(trial,1)=toc;
    if sum(trial==params.flattenpoints)>0
        
        % jointdist=flattenmu_mex(jointdist);
        jointdist=repmat(mean(jointdist),out.musize,1,1,1,1);
        jd_old=jointdist;
    end
    
    
    %entropy
    out.entropy(trial,1)=jointdist(jointdist>eps)'*(-log2(jointdist(jointdist>eps)));  % numbers less than 1e-15 are 0
    
    % GET MARGINALS
    %
    
    % mu
    
    out.muDist(trial,:) = sum(sum(sum(sum(jointdist,2),3),4),5); % sum over each row.
    out.muEst(trial,:)  = inv_logit(sum(out.muDist(trial,:).*out.muvec),1); % transform back to reward space after estimating expected value
    
    % vmu(volatility)
    out.vmuDist(trial,:) = sum(sum(sum(sum(jointdist,1),3),4),5);
    out.vmuEst(trial,:)  = sum(out.vmuDist(trial,:).*out.vmulog);
    
    %kmu (k for mu)
    out.kmuDist(trial,:) = sum(sum(sum(sum(jointdist,1),2),4),5);
    out.kmuEst(trial,:)  = sum(out.kmuDist(trial,:).*out.kmulog);
    
    % sd (expected uncertainty)
    out.sDist(trial,:)=sum(sum(sum(sum(jointdist,1),2),3),5);
    out.sEst(trial,:)=sum(out.sDist(trial,:).*out.slog);
    
    %sd vol
    out.vsDist(trial,:)=sum(sum(sum(sum(jointdist,1),2),3),4);
    out.vsEst(trial,:)=sum(out.vsDist(trial,:).*out.vslog);
    
    % surface of volatility vs. noise
    out.volnoise(trial,:,:)=sum(sum(sum(jointdist,1),3),5);
    
    % ks (k for s)
    %      ksDist(trial,:)=sum(sum(sum(sum(sum(jointdist,1),2),3),4),5);
    %     ksEst(trial,:)=sum(ksDist(trial,:).*kslog);
    
    
    
    %%%%%%%%%%% Perform BAYESIAN UPDATE %%%%%%%%%%%%%%%%%%%%%%%
    %
    % this is liklihood of the observation given the model, multiplied by the
    % prior (i.e. joint distribution from previous trial). No correction for
    % other parameters yet.
    %
    %  t(trial,2)=toc;
    if ~isnan(trans_reward(trial))
        for ss=1:out.ssize
            var=exp(out.slog(ss)*2); % var of normal pdf
            for r=1:out.musize
                jointdist(r,:,:,ss,:)=jointdist(r,:,:,ss,:).*((exp(-power((out.muvec(r) - trans_reward(trial)),2)/(2*var))) / (sqrt(2*pi*var)));
                %jointdist(r,:,:,ss,:)=jointdist(r,:,:,ss,:).*normpdf(out.muvec(r), trans_reward(trial),sdv);
                
            end
        end
    end
    %   t(trial,3)=toc;
    
    % now do normalization (note liklihood does not sum to 1)
    jointdist = jointdist ./ sum(sum(sum(sum(sum(jointdist)))));
    %     t(trial,4)=toc;
    
    %
    % Now account for other parameters. First deal with the variation in mu
    %
    
    % I) multiply jointdist (after bayes update) by vmup1gvmukmu (probability of vmu on
    %next trial given vmu and kmu on this trial), and integrate out vmu on this trial. This
    %will give pvmup1kmu (probability of vmu on next trial given kmu).
    % for k = 1:out.kmusize
    
  for Ip1 = 1:out.vmusize
        tmp3=repmat(vmup1gvmukmu(Ip1,:,:),[1 1 1 out.ssize,out.vssize]);
        for r = 1:out.musize
            pvmup1kmu(r,Ip1,:,:,:) = sum(tmp3.*jointdist(r,:,:,:,:)); % for a given k calcuate the probability of r given the updated I
        end
    end
    
    % t(trial,5)=toc;
    % II) multiply pIp1k (probability of r on next trial given I) by
    %pp1gpIp1 (probability of on next trial given r on this trial and
    %I on next trial), and integrate out r on this trial. This will give pp1Ip1k
    %(probability of r on next trial given I on nextr trial and k).
    
    for Ip1 = 1:out.vmusize
        tmp=pvmup1kmu(:,Ip1,:,:,:);
        for rp1 = 1:out.musize
            pp1Ip1k(rp1,Ip1,:,:,:) = sum(tmp.*repmat(rmup1muvmup1(rp1,:,Ip1)',[1 1 out.kmusize out.ssize,out.vssize]),1);
        end
    end
    %            t(trial,6)=toc;
    
    % then the variation in s
    % first the change in volatility
    %         pvsp1ks = zeros(out.musize, out.vmusize, out.kmusize,out.ssize,out.vssize,kssize);
    %          for Ip1 = 1:out.vssize
    %             for r = 1:out.ssize
    %                 pvsp1ks(:,:,:,r,Ip1,:) = sum(permute(repmat(vsp1gvsks(Ip1,:,:),[1,1,1,out.musize,out.vmusize,out.kmusize]),[4 5 6 1 2 3]).*jointdist(:,:,:,r,:,:),5); % for a given k calcuate the probability of r given the updated I
    %             end
    %          end
    %       t(trial,7)=toc;
    % then the change in sd
    
    for Ip1 = 1:out.vssize
        tmp2=pp1Ip1k(:,:,:,:,Ip1);
        for rp1 = 1:out.ssize
            
            jointdist(:,:,:,rp1,Ip1) = sum(tmp2.*permute(repmat(rsp1svsp1(rp1,:,Ip1)',[1 1 out.musize,out.vmusize,out.kmusize]),[3 4 5 1 2]),4);
        end
    end
    
    
    %   t(trial,8)=toc;
    %
    
    % calculate KL divergence
    idx=jointdist>eps & jd_old>eps;
    
    %zz(trial,1)=sum(sum(sum(sum(sum(jointdist.*(log2(jointdist+eps)-log2(jd_old+eps)))))));  % NB add eps to avoid infinities with logs, don't dick around with the actual joint distributions though.
    out.KLdiv(trial,1)=sum(sum(sum(sum(sum(jointdist(idx).*(log2(jointdist(idx))-log2(jd_old(idx))))))));   % definition of kldiv when prob is 0 is 0-- give identical value to above (but is faster).
   %  out.KLdiv(trial,1)=sum(sum(sum(sum(sum(jointdist(jointdist>eps ).*(log2(jointdist(jointdist>eps ))-log2(jd_old(jointdist>eps ))))))));   % definition of kldiv when prob is 0 is 0-- give identical value to above (but is faster).
   
    jd_old=jointdist;
    
end


%get last estimates
trial=trial+1;


    
    %entropy
    out.entropy(trial,1)=sum(sum(sum(sum(sum(jointdist(jointdist>eps).*(log2(1./(jointdist(jointdist>eps)))))))));  % numbers less than 1e-15 are 0
    
    % GET MARGINALS
    %
    
    % mu
    
    out.muDist(trial,:) = sum(sum(sum(sum(jointdist,2),3),4),5); % sum over each row.
    out.muEst(trial,:)  = inv_logit(sum(out.muDist(trial,:).*out.muvec),1); % transform back to reward space after estimating expected value
    
    % vmu(volatility)
    out.vmuDist(trial,:) = sum(sum(sum(sum(jointdist,1),3),4),5);
    out.vmuEst(trial,:)  = sum(out.vmuDist(trial,:).*out.vmulog);
    
    %kmu (k for mu)
    out.kmuDist(trial,:) = sum(sum(sum(sum(jointdist,1),2),4),5);
    out.kmuEst(trial,:)  = sum(out.kmuDist(trial,:).*out.kmulog);
    
    % sd (expected uncertainty)
    out.sDist(trial,:)=sum(sum(sum(sum(jointdist,1),2),3),5);
    out.sEst(trial,:)=sum(out.sDist(trial,:).*out.slog);
    
    %sd vol
    out.vsDist(trial,:)=sum(sum(sum(sum(jointdist,1),2),3),4);
    out.vsEst(trial,:)=sum(out.vsDist(trial,:).*out.vslog);
    
    % surface of volatility vs. noise
    out.volnoise(trial,:,:)=sum(sum(sum(jointdist,1),3),5);




