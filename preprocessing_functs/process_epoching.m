function EEG = process_epoching(eeg_file, eventLabel, timeWindow)
    % Open EEG file
    EEG = pop_loadset(eeg_file);

    % Check if the event exists
    if sum(strcmp({EEG.event.type}, eventLabel)) == 0
        disp(['Event "' eventLabel '" not found in: ' eeg_file]);
        return;
    end

    % Create epochs around the event
    EEG = pop_epoch(EEG, {eventLabel}, timeWindow, 'epochinfo', 'yes');

    return;
end
