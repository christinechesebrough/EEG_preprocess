function EEG = process_ica_runica(eeg_file)
    % Open EEG file
    EEG = pop_loadset(eeg_file);
    
    % Run ICA
    EEG = pop_runica(EEG, 'icatype', 'runica');
    
    return
end
