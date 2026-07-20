function [ out ] = inv_logit( innum, direction )
%inv_logit returns the logit of input. If direction = 1 then perform
%inverse logit

if nargin < 2
    direction=0;
end

if direction==0 
    if any(innum < 0) || any(innum > 1)
        error('logit only defined for numbers between 0 and 1');
    end
    out=-log((1./innum)-1); %logit(p) = log(p/(1-p))
elseif direction ==1
    out=1./(1+exp(-innum));%inverse logit = 1/(1+exp(-x))
    
else
    error('direction must be 0 or 1')
end


end

