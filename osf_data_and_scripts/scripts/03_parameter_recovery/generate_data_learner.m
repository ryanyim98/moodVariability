function [out, outparams, n_restarts]=generate_data_learner(params, n, param_min, param_max)
% Generate n data points using the 5 parameters in params: mean, vmu, kmu, s, vs.
% Optional param_min, param_max (each 1x5): if provided, the generated parameter
% time series is generated on the native scale and any trajectory that ever
% crosses those bounds is fully discarded and re-generated (no clamping).
%
% Param order: [mu, vmu, kmu, s, vs].
% n_restarts: number of full trajectory re-generations due to boundary hits.

if nargin < 3
    param_min = [];
end
if nargin < 4
    param_max = [];
end
use_bounds = ~isempty(param_min) && ~isempty(param_max);

max_restarts = 10000;  % if hit bound more than this, return and let caller resample start
n_restarts = 0;

done = false;
while ~done
    n_restarts = n_restarts + 1;
    if n_restarts > max_restarts
        done = true;  % break time-series generation; caller will resample starting values
        break;
    end

    out = NaN(n,1);         % generated rating values
    outparams = NaN(n+1,5); % state at 1..n+1 (121 for EMA, 42 for task)
    outparams(1,:) = params;
    outparams(1,1)=inv_logit(outparams(1,1)); %convert mu to unbounded scale (this is where its normal)

    valid_traj = true;

    for trial = 1:n
        % Observation: rating in [0,1] via inverse-logit of latent normal
        out(trial) = inv_logit(normrnd(outparams(trial,1), exp(outparams(trial,4))), 1);

        % State evolution
        outparams(trial+1,3) = outparams(trial,3);                         % kmu (assumed constant)
        outparams(trial+1,5) = outparams(trial,5);                         % vs  (assumed constant)
        outparams(trial+1,2) = normrnd(outparams(trial,2), exp(outparams(trial,3)));  % vmu drift
        outparams(trial+1,1) = normrnd(outparams(trial,1), exp(outparams(trial+1,2)));% mu drift at vmu_t+1
        outparams(trial+1,4) = normrnd(outparams(trial,4), exp(outparams(trial,5)));  % s drift

        % Clamp rating (keep same EMA scale behaviour)
        if out(trial) > 9/10
            out(trial) = 9/10;
        elseif out(trial) < 1/10
            out(trial) = 1/10;
        end

        % If bounds are provided, reject the whole trajectory as soon as any
        % parameter hits the boundary region.
        if use_bounds
            hit_bound = false;
            for i = 1:5
                if outparams(trial+1,i) < param_min(i) || outparams(trial+1,i) > param_max(i)
                    hit_bound = true;
                    break;
                end
            end
            if hit_bound
                valid_traj = false;
                break; % break out of trial loop; outer while will re-generate
            end
        end
    end

    % Only accept trajectory if we finished all n trials and stayed in bounds
    if ~use_bounds
        done = true;
    else
        done = valid_traj && (trial == n);
    end
end
% At this point, out and outparams are fully populated (no NaNs) and
% satisfy the empirical bounds if they were provided.

