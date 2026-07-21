function repo_root = find_repo_root(start_dir)
%FIND_REPO_ROOT Walk upward from start_dir until moodVariability.Rproj is found.
%   Counting fixed fileparts() levels from mfilename('fullpath') is fragile: if
%   MATLAB ever runs this script from somewhere other than its real location in
%   the repo (an unsaved editor buffer, a synced/cached temp copy, etc.),
%   mfilename('fullpath') resolves to that other location and blind fileparts()
%   arithmetic silently produces a wrong-looking path instead of an error. This
%   searches upward for the same repo-root sentinel the R scripts use instead.
if nargin < 1
    start_dir = fileparts(mfilename('fullpath'));
end
p = start_dir;
while true
    if isfile(fullfile(p, 'moodVariability.Rproj'))
        repo_root = p;
        return
    end
    parent = fileparts(p);
    if strcmp(parent, p)
        error('find_repo_root:notFound', [ ...
            'Could not find moodVariability.Rproj above %s.\n' ...
            'This usually means MATLAB ran a copy of this script from somewhere ' ...
            'other than its real location in the repo (e.g. an unsaved buffer, a ' ...
            'downloaded/synced temp copy). Make sure the current file is the one at\n' ...
            '  osf_data_and_scripts/scripts/01_bayesian_filter/<name>.m\n' ...
            'inside your actual moodVariability checkout, then run it again.'], ...
            start_dir);
    end
    p = parent;
end
end
