
spm('defaults', 'eeg');

report = {};

%% SPM Convert

% define path to directory with epoched preprocessed data
main_directory = '/Users/christinechesebrough/Documents/MW_EEG_dir/MW_EEG_SPM/MW_EEG_epoched_025';

% Get a list of subject folders
subject_folders = dir(main_directory);
subject_folders = subject_folders([subject_folders.isdir]); % Keep only directories
subject_folders = subject_folders(~ismember({subject_folders.name}, {'.', '..'})); % Remove '.' and '..'

% Create a new main directory to save SPM converted files
output_main_directory = '/Users/christinechesebrough/Documents/MW_EEG_dir/MW_EEG_SPM/MW_EEG_SPM_converted_noZ_5253';
if ~exist(output_main_directory, 'dir')
    mkdir(output_main_directory);
end

% Loop through subject folders
for i = 1:length(subject_folders)
    subject_folder = fullfile(main_directory, subject_folders(i).name);
    
    % Get a list of EEG files in the subject folder
    eeg_files = dir(fullfile(subject_folder, '*.set'));
    
    % Create a new folder for the subject in the output main directory
    output_subject_directory = fullfile(output_main_directory, subject_folders(i).name);
    if ~exist(output_subject_directory, 'dir')
        mkdir(output_subject_directory);
    end

    for j = 1:length(eeg_files)
    eeg_file = fullfile(subject_folder, eeg_files(j).name);


    S = [];
    S.dataset = [eeg_file];

    %[~, subjectFolder] = fileparts(EEG.filepath);
    name = eeg_files(j).name;


% CONVERT FILE

S.outfile = [output_subject_directory,filesep,name];
S.channels = 'all';
S.mode = 'epoched';
S.blocksize = 3276800;
S.checkboundary = 0;
S.datatype = 'float32-le';
S.eventpadding = 0;
S.saveorigheader = 0;

%S.timewin = [];

% %
% S.trialdef(1).conditionlabel = 'Q1_on';
% S.trialdef(1).eventtype = 'Q1_on';
% S.trialdef(1).eventvalue = [];

S.conditionlabels = 'Undefined';


S.inputformat = [];
D = spm_eeg_convert(S);

    end
end
%% Relabel events in converted SPM .mat files with labels extracted from ratings

% Define directories with converted spm data (first directory) and .csv
% files with preprocessed subject ratings (second directory)
% make sure the subject folders in each are labeled the same!

first_directory = '/Users/christinechesebrough/Documents/MW_EEG_dir/MW_EEG_SPM/MW_EEG_SPM_converted_Z_25';  % Replace with your directory path
second_directory = '/Users/christinechesebrough/Documents/MW_EEG_dir/MW_ratings_processed_attention_z'; % Replace with your directory path

spm('defaults', 'eeg');

subject_folders = dir(first_directory);
subject_folders = subject_folders([subject_folders.isdir]);
subject_folders = subject_folders(~ismember({subject_folders.name}, {'.', '..'}));

for i = 1:length(subject_folders)
    subject_folder_name = subject_folders(i).name;
    subject_folder_path = fullfile(first_directory, subject_folder_name);

    mat_files = dir(fullfile(subject_folder_path, '*.mat'));
    if isempty(mat_files)
        fprintf('No .mat files found for subject %s\n', subject_folder_name);
        continue;
    end

    mat_file_path = fullfile(subject_folder_path, mat_files(1).name);
    D = spm_eeg_load(mat_file_path);

    corresponding_folder_path = fullfile(second_directory, subject_folder_name);
    csv_files = dir(fullfile(corresponding_folder_path, '*.csv'));
    if isempty(csv_files)
        fprintf('No .csv files found for subject %s\n', subject_folder_name);
        continue;
    end

    csv_file_path = fullfile(corresponding_folder_path, csv_files(1).name);
    conditionLabels = readcell(csv_file_path);

    % Check if the number of condition labels matches the number of trials
    if length(conditionLabels) == D.ntrials
        for j = 1:D.ntrials
            D = conditions(D, j, conditionLabels{j});
        end
        D = meeg(D)
        save(D);
    else
        fprintf('Condition labels length mismatch for subject %s\n', subject_folder_name);
    end
end

fprintf('Finished processing all subjects.\n');

