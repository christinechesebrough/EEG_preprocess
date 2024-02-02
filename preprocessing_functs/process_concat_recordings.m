
%% Concatenates across all recordings in a subject folder to create a single longer recording

function allEEG = process_concat_recordings(eeg_file_paths)
    allEEG = [];
    cumulativeLatency = 0;  % Initialize cumulative latency
    cumulativeEventNum = 0; % Initialize cumulative urevent (event #)

    % Loop through each .set file and load EEG data
    for j = 1:length(eeg_file_paths)
        eeg_file = eeg_file_paths{j};

        % Load EEG file
        EEG = pop_loadset(eeg_file);

        % Adjust event latencies and numbers for concatenated data
        if ~isempty(allEEG)
            for e = 1:length(EEG.event)
                EEG.event(e).latency = EEG.event(e).latency + cumulativeLatency;
                EEG.event(e).urevent = EEG.event(e).urevent + cumulativeEventNum;
            end
        end

        % Update cumulativeLatency and cumulativeEventNum
        cumulativeLatency = cumulativeLatency + EEG.pnts * EEG.trials;
        cumulativeEventNum = cumulativeEventNum + length(EEG.urevent);

        % Append EEG data to the existing data
        if isempty(allEEG)
            allEEG = EEG;
        else
            allEEG = pop_mergeset(allEEG, EEG, 1); % Keeps the boundary event if present
        end
    end
end

