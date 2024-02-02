function EEG = process_event_relabeling(eeg_file)
    % Open EEG file
    EEG = pop_loadset(eeg_file);

    % Load event labels from a CSV file depending on subs being analyzed (event
    % labeling changed between sub 13 - 15, 15-18, and 19+)
    % Note: from subject 19 on, you will only need 'sub_25_eventLabs.csv'
    %event_labels = readcell('event_labels.csv');
    %event_labels = readcell('subs_19on_eventLabs.csv');
    %event_labels = readcell('subs15_18_eventLabs.csv');
    event_labels = readcell('sub_25_eventLabs.csv');

    % Ensure that the number of event labels matches the number of events in the EEG dataset
    if length(event_labels) ~= length(EEG.event)
        warning('Number of event labels does not match the number of events in the EEG dataset.');
    else
        % Loop through each event and replace the event type
        for eventIndex = 1:length(EEG.event)
            EEG.event(eventIndex).type = event_labels{eventIndex};
        end
    end

    return
end
