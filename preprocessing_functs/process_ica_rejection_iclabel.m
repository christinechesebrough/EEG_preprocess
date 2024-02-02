function EEG = process_ica_rejection_iclabel(eeg_file)
    % Open EEG file
    EEG = pop_loadset(eeg_file);
    EEG = eeg_checkset(EEG);

    % Define ICA rejection thresholds
    rejThreshold = [0   0;    % Brain
                    0.65 1;    % Muscle
                    0.6  1;    % Eye
                    0.6  1;    % Heart
                    0.6  1;    % Line noise
                    0.6  1;    % Channel noise
                    0.6  1];   % Other

    % Label and flag ICA components
    EEG = pop_iclabel(EEG, 'default');
    EEG = pop_icflag(EEG, rejThreshold);

    % Identify and remove flagged ICs
    remCompsFinal = find(EEG.reject.gcompreject);
    EEG = pop_subcomp(EEG, remCompsFinal, 0);

    % Log rejected components in EEG struct
    EEG.rej_comp = remCompsFinal;

    % Update EEG structure
    EEG = eeg_checkset(EEG);

    return
end
