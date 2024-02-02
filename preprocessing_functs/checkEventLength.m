
% This function loops through the eeg recordings within subject folders in a
% directory and prints the number of events in each recording. This is
% helpful for checking the event structure and making sure each of the
% recordings for each subject has the same number of events. 

main_directory = ''; %path to your input folder

% Get a list of subject folders
subject_folders = dir(main_directory);
subject_folders = subject_folders([subject_folders.isdir]); % Keep only directories
subject_folders = subject_folders(~ismember({subject_folders.name}, {'.', '..'})); % Remove '.' and '..'

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
    
    % Loop through EEG files in each subject folder
    for j = 1:length(eeg_files)
        eeg_file = fullfile(subject_folder, eeg_files(j).name);
        
     % Open EEG file using fileIO to read BrainVision files
        EEG = pop_fileio(eeg_file);

        numEvents = length(EEG.event)
        numEvents
        end
end