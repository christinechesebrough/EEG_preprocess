%% Concatenates across all recordings in a subject folder to create a single longer recording

function allEEG = process_concat_recordings(eeg_file_paths)
    allEEG = [];
    % Loop through each .set file and load EEG data
    for j = 1:length(eeg_file_paths)
        eeg_file = eeg_file_paths{j};
                
        % Load EEG file
        EEG = pop_loadset(eeg_file);
        
        if isempty(allEEG)
            allEEG = EEG;
        else
            allEEG = pop_mergeset(allEEG, EEG, 1); 
        end
    end
    
