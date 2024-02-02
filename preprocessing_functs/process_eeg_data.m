% process_eeg_data is the master call function for calling all other eeg preprocessing
% steps in this pipeline (except concatenation)

% It takes in the paths main (input) directory where your files are stored, the
% output directory where you want to save processed files, the name of the
% function you are calling, and a string suffix to add to the end of the
% new saved filename

function process_eeg_data(main_directory, output_main_directory, eeg_extension, processing_function, output_suffix)
    % Get a list of subject folders
    subject_folders = dir(main_directory);
    subject_folders = subject_folders([subject_folders.isdir]);
    subject_folders = subject_folders(~ismember({subject_folders.name}, {'.', '..', '.DS_Store'})); % Exclude system folders

    % Loop through subject folders
    for i = 1:length(subject_folders)
        subject_folder = fullfile(main_directory, subject_folders(i).name);

        % Get a list of EEG files in the subject folder
        eeg_files = dir(fullfile(subject_folder, ['*', eeg_extension]));

        % Create a new folder for the subject in the output main directory
        output_subject_directory = fullfile(output_main_directory, subject_folders(i).name);
        if ~exist(output_subject_directory, 'dir')
            mkdir(output_subject_directory);
        end

        % Loop through EEG files in the subject folder
        for j = 1:length(eeg_files)
            eeg_file = fullfile(subject_folder, eeg_files(j).name);

            % Call the provided processing function
            EEG = processing_function(eeg_file);

            % Save the processed EEG data to the subject's output folder
            [~, eeg_filename, ~] = fileparts(eeg_files(j).name);
            output_filename = fullfile(output_subject_directory, [eeg_filename, output_suffix, eeg_extension]);
            pop_saveset(EEG, 'filename', output_filename);
            fprintf('Processed and saved: %s\n', output_filename);
        end
    end
end
