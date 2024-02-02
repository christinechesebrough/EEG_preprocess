function EEG = process_ica_rejection_mara(eeg_file)
    % Load EEG file
    EEG = pop_loadset(eeg_file);
    EEG = eeg_checkset(EEG);

    MARAinput = [0, 0, 0, 0, 0];

    % Assuming ALLEEG and CURRENTSET are properly set up in your environment
    ALLEEG = EEG;
    CURRENTSET = 1;

    [~, EEG, ~] = processMARA(ALLEEG, EEG, CURRENTSET, MARAinput);

    % Remove flagged ICs
    remCompsFinal = find(EEG.reject.gcompreject);
    EEG = pop_subcomp(EEG, remCompsFinal, 0);

    % Update EEG structure and save the updated dataset
    EEG = eeg_checkset(EEG);

    % Log rejected components in EEG struct
    EEG.rej_comp = remCompsFinal;

    return
end
