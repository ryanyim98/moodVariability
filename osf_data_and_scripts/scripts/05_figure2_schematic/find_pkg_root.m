function pkg_root = find_pkg_root(start_dir)
%FIND_PKG_ROOT Walk upward from start_dir until osf_data_and_scripts/.here is found.
%   Counting fixed fileparts() levels from mfilename('fullpath') is fragile: if
%   MATLAB ever runs this script from somewhere other than its real location in
%   this package (an unsaved editor buffer, a synced/cached temp copy, etc.),
%   mfilename('fullpath') resolves to that other location and blind fileparts()
%   arithmetic silently produces a wrong-looking path instead of an error. This
%   searches upward for the same .here sentinel the R scripts anchor on.
if nargin < 1
    start_dir = fileparts(mfilename('fullpath'));
end
p = start_dir;
while true
    if isfile(fullfile(p, '.here'))
        pkg_root = p;
        return
    end
    parent = fileparts(p);
    if strcmp(parent, p)
        error('find_pkg_root:notFound', [ ...
            'Could not find osf_data_and_scripts/.here above %s.\n' ...
            'This usually means MATLAB ran a copy of this script from somewhere ' ...
            'other than its real location in this package (e.g. an unsaved buffer, ' ...
            'a downloaded/synced temp copy). Make sure the current file is the one ' ...
            'inside your actual osf_data_and_scripts checkout, then run it again.'], ...
            start_dir);
    end
    p = parent;
end
end
