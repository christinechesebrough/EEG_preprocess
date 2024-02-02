function EEG = process_initial_cleaning(eeg_file)
    % Load EEG file using fileIO to read BrainVision files
    % EEG = pop_fileio(eeg_file);

    EEG = pop_loadset(eeg_file);    
    
    % Resample recording to 250 Hz
    EEG = pop_resample(EEG, 250);

    % Remove non-EEG channels for filtering (will be re-added later as necessary)
    channels_to_remove = 32:36;
    EEG = pop_select(EEG, 'nochannel', channels_to_remove);

    % Add channel locations from chanfile
    EEG = pop_chanedit(EEG,'lookup','/Users/christinechesebrough/Documents/MW_EEG_dir/Utils/Standard-10-20-Cap81.locs');
    % replace with path to chan_loc file 
    
    % Band-pass filter from 1-55 Hz
    [EEG, ~, ~] = pop_eegfiltnew(EEG, 1, 50);

    % Average reference
    EEG = pop_reref(EEG, []);

    % Cleanline (remove line noise) (optional)
    EEG = pop_cleanline(EEG, 'chanlist', [1:length(EEG.chanlocs)], 'ComputeSpectralPower', 1, ...
             'SignalType', 'Channels', 'VerboseOutput', 1, ...
             'SlidingWinLength', 3, 'SlidingWinStep', 2, ...
             'LineAlpha', 0.05); 

    return
end
