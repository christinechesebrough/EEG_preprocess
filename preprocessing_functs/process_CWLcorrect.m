function EEG = process_CWLcorrect(eeg_file)
    % Import EEG file using pop_fileio
    EEG = pop_fileio(eeg_file);

    % Define parameters for CWL regression
    srate = 5000; % Sampling rate
    windowduration = 4.0; % Window duration
    delay = 0.021; % Delay
    taperingfactor = 1; % Tapering factor
    taperingfunction = '@hann'; % Hann function for tapering
    regressorinds = [33:36]; % Regressor channel indices
    channelinds = [1:31]; % EEG channel indices
    method = 'taperedhann'; % Correction method
    doui = 0; % Do not show UI

    % Call the CWL regression function
    EEG = pop_cwregression(EEG, srate, windowduration, delay, taperingfactor, taperingfunction, regressorinds, channelinds, method, doui);

    return;
end
