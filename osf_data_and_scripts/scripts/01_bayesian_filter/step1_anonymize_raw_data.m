% Purpose: produces de-identified copies of every raw .mat file in
% data/raw/raw_mat/, suffixed "_anonymized", so the raw data can be shared
% (e.g. on OSF) without exposing identifiers.
%
% Needs the private data/raw/raw_mat/ originals, which are not included in
% this package -- see the README for details.
%
% What gets scrubbed (RawData.mat is the only file with identifiers):
% PANAS.ProlifID, Gorilla.participant, and InitQStruct's ID field (named in
% INITQ_ID_FIELDS below) are each replaced with a sequential integer
% (1..339), keeping the original field's data type so downstream code (e.g.
% char(...ProlifID)) keeps working -- see anonymize_id() below. PANAS.RawData
% / InitQStruct.RawData / Gorilla.RawData (raw per-response export tables,
% themselves identifying and unused by anything here) are dropped entirely
% rather than scrubbed field-by-field. The other raw .mat files contain plain
% numeric arrays with no identifier field, so they're copied through unchanged.
%
% Output goes to osf_data_and_scripts/data/raw_mat/ (the OSF-upload folder).
% Also writes data/raw/subject_id_crosswalk.csv (Prolific.Id -> subject) so
% subject numbers here match the "subject" column in osf_data_and_scripts/data/;
% write_anonymized_data.R reads this crosswalk. It contains real Prolific IDs,
% so it must never be shared. Run this script before write_anonymized_data.R.

clear; clc;
script_dir = "~/Desktop/MoodInstability/moodVariability/osf_data_and_scripts/scripts/01_bayesian_filter"; % EDIT: path to this folder on your machine
addpath(script_dir);
repo_root = find_repo_root(script_dir);
raw_mat_dir = fullfile(repo_root, "data", "raw", "raw_mat"); % source (originals, not shared)
out_mat_dir = fullfile(repo_root, "osf_data_and_scripts", "data", "raw_mat"); % destination (for OSF upload)
if ~isfolder(out_mat_dir), mkdir(out_mat_dir); end

%% ---- CONFIG: verify against the printed fieldnames() before trusting this ----
INITQ_ID_FIELDS = {'ProlifID'};  % confirmed via fieldnames(Md_Inst_Struct(1).InitQStruct)

%% 1. RawData.mat -- the one file with real identifiers
S = load(fullfile(raw_mat_dir, "RawData.mat"));
Md_Inst_Struct = S.Md_Inst_Struct;
n = numel(Md_Inst_Struct);

initq_fields_actual = fieldnames(Md_Inst_Struct(1).InitQStruct);
fprintf('InitQStruct fields (subject 1) -- verify INITQ_ID_FIELDS above matches one of these:\n');
disp(initq_fields_actual);

matched_initq_fields = INITQ_ID_FIELDS(ismember(INITQ_ID_FIELDS, initq_fields_actual));
if isempty(matched_initq_fields)
    error('anonymize_raw_data:noInitQMatch', [ ...
        'None of INITQ_ID_FIELDS (%s) match an actual field in InitQStruct ' ...
        '(printed above). Edit INITQ_ID_FIELDS at the top of this script to the ' ...
        'correct name(s), then re-run.'], strjoin(INITQ_ID_FIELDS, ', '));
end

%% Crosswalk (Prolific.Id -> subject), BEFORE any scrubbing -- read the real ID now
prolific_id = strings(n, 1);
for i = 1:n
    prolific_id(i) = string(char(Md_Inst_Struct(i).PANAS.ProlifID));
end
crosswalk = table((1:n)', prolific_id, 'VariableNames', {'subject', 'Prolific_Id'});
writetable(crosswalk, fullfile(repo_root, "data", "raw", "subject_id_crosswalk.csv"));
fprintf('Wrote %s (%d rows) -- private, do not share.\n', ...
    fullfile(repo_root, "data", "raw", "subject_id_crosswalk.csv"), n);

for i = 1:n
    Md_Inst_Struct(i).PANAS.ProlifID = anonymize_id(Md_Inst_Struct(i).PANAS.ProlifID, i);
    Md_Inst_Struct(i).Gorilla.participant = anonymize_id(Md_Inst_Struct(i).Gorilla.participant, i);
    for k = 1:numel(matched_initq_fields)
        fld = matched_initq_fields{k};
        Md_Inst_Struct(i).InitQStruct.(fld) = anonymize_id(Md_Inst_Struct(i).InitQStruct.(fld), i);
    end

    % Drop raw per-response export tables entirely (identifying, unused downstream)
    if isfield(Md_Inst_Struct(i).PANAS, 'RawData')
        Md_Inst_Struct(i).PANAS = rmfield(Md_Inst_Struct(i).PANAS, 'RawData');
    end
    if isfield(Md_Inst_Struct(i).InitQStruct, 'RawData')
        Md_Inst_Struct(i).InitQStruct = rmfield(Md_Inst_Struct(i).InitQStruct, 'RawData');
    end
    if isfield(Md_Inst_Struct(i).Gorilla, 'RawData')
        Md_Inst_Struct(i).Gorilla = rmfield(Md_Inst_Struct(i).Gorilla, 'RawData');
    end
end

% NOTE: no "-v7.3" flag here -- using it previously bloated this file from ~20MB
% to ~2GB. MATLAB's v7.3 (HDF5) format stores each struct field as its own
% dataset with per-dataset overhead; multiplied across hundreds of subjects x
% many small fields, that overhead dwarfs the actual data. Default save() uses
% the same (compressed) format the original RawData.mat was saved in.
save(fullfile(out_mat_dir, "RawData_anonymized.mat"), "Md_Inst_Struct");
fprintf('Wrote %s (scrubbed %d subjects)\n', fullfile(out_mat_dir, "RawData_anonymized.mat"), n);

%% 2. Files with no identifier field -- straight byte-for-byte copy under the new name
passthrough_files = { ...
    "PANASPosMinNegFrMod.mat", ...
    "PANASfrBaysMod.mat", ...
    "PANASPosMinNegFrMod_noCloseResponse.mat", ...
    "d1r1ModDat.mat", ...
    "d1r2ModDat.mat", ...
    "d2r1ModDat.mat", ...
    "d2r2ModDat.mat" ...
};
for k = 1:numel(passthrough_files)
    src = fullfile(raw_mat_dir, passthrough_files{k});
    [~, name, ext] = fileparts(passthrough_files{k});
    dst = fullfile(out_mat_dir, name + "_anonymized" + ext);
    copyfile(src, dst);
    fprintf('Copied %s -> %s (no identifier field in this file)\n', src, dst);
end

fprintf('\nDone. Spot-check RawData_anonymized.mat, e.g.:\n');
fprintf('  a = load(fullfile(out_mat_dir, "RawData_anonymized.mat"));\n');
fprintf('  a.Md_Inst_Struct(1).PANAS.ProlifID, a.Md_Inst_Struct(5).Gorilla.participant\n');
fprintf('  isfield(a.Md_Inst_Struct(1).PANAS, ''RawData'')  %% should be false (0)\n');
d1 = dir(fullfile(raw_mat_dir, "RawData.mat"));
d2 = dir(fullfile(out_mat_dir, "RawData_anonymized.mat"));
fprintf('  RawData.mat: %.1f MB -- RawData_anonymized.mat: %.1f MB (should be similar, not 100x)\n', ...
    d1.bytes/1e6, d2.bytes/1e6);

%% Helper: replace an identifier value with `newnum`, preserving its original type
% (local functions in a script must be defined after all executable statements)
function newval = anonymize_id(original, newnum)
    if iscategorical(original)
        newval = categorical(newnum);
    elseif isstring(original)
        newval = string(newnum);
    elseif ischar(original)
        newval = num2str(newnum);
    elseif isnumeric(original)
        newval = newnum;
    else
        warning('anonymize_id:unknownType', ...
            'Unrecognized identifier type "%s" -- replacing with a plain number.', class(original));
        newval = newnum;
    end
end
