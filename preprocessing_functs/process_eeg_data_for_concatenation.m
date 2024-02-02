% process_eeg_data_for_concatenation is the master call function for
% calling the concatenation step in the eeg processing pipeline. Because it
% it involves binding multiple EEG recordings, it uses the ALLEEG structure
% rather than the singular EEG struct type.

% It takes in the paths main (input) directory where your files are stored, the
% output directory where you want to save processed files, the name of the
% function you are calling (usually, and a string suffix to add to the end of the
% new saved filename

function process_eeg_data_for_concatenation(main_directory, output_main_directory, eeg_extension, processing_function, output_suffix)
    % Get a list of subject folders
    subject_folders = dir(main_directory);
    subject_folders = subject_folders([subject_folders.isdir]);
    subject_folders = subject_folders(~ismember({subject_folders.name}, {'.', '..', '.DS_Store'})); % Exclude system folders

    % Loop through subject folders
    for i = 1:length(subject_folders)
        subject_folder = fullfile(main_directory, subject_folders(i).name);

        % Get a list of EEG files in the subject folder
        eeg_files = dir(fullfile(subject_folder, ['*', eeg_extension]));
        eeg_file_paths = arrayfun(@(f) fullfile(subject_folder, f.name), eeg_files, 'UniformOutput', false);

        % Create a new folder for the subject in the output main directory
        output_subject_directory = fullfile(output_main_directory, subject_folders(i).name);
        if ~exist(output_subject_directory, 'dir')
            mkdir(output_subject_directory);
        end

        % Call the provided processing function with all EEG files in the subject folder
        if ~isempty(eeg_file_paths)
            concatenated_EEG = processing_function(eeg_file_paths);

            % Save the concatenated EEG data to the subject's output folder
            [~, eeg_filename, ~] = fileparts(eeg_files(1).name); % Use the first file's name as base
            output_filename = fullfile(output_subject_directory, [eeg_filename, output_suffix, eeg_extension]);
            pop_saveset(concatenated_EEG, 'filename', output_filename);
            fprintf('Processed and saved: %s\n', output_filename);
        else
            fprintf('No EEG files found in: %s\n', subject_folder);
        end
    end
end
