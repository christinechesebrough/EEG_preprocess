function EEG = process_man_rej(eeg_file)
    % Load EEG file
    EEG = pop_loadset(eeg_file);

    % Define a command to execute after closing eegplot
    % This command will update the global TMPREJ variable with the rejection marks
    command = '[TMPREJ] = eegplot2event(TMPREJ, -1);';

    % Set up eeg_plot for manual rejection with the "REJECT" button
    eegplot(EEG.data, 'srate', EEG.srate, 'spacing', 30, 'winlength', 15, 'title', 'Manual Segment Rejection', ...
            'eloc_file', EEG.chanlocs, 'events', EEG.event, 'command', command);

    % Wait for the user to close the eeg_plot window
    uiwait(gcf);

    % Access the global TMPREJ variable updated by eegplot
    global TMPREJ;
    if ~isempty(TMPREJ)
        % Sort TMPREJ in case segments are not in chronological order
        TMPREJ = sortrows(TMPREJ, 1);

        % Remove the rejected segments
        for i = size(TMPREJ, 1):-1:1
            EEG.data(:, TMPREJ(i, 1):TMPREJ(i, 2)) = [];
            EEG.pnts = size(EEG.data, 2);

            % Adjust event latencies
            for e = 1:length(EEG.event)
                if EEG.event(e).latency >= TMPREJ(i, 1)
                    if EEG.event(e).latency <= TMPREJ(i, 2)
                        EEG.event(e).type = 'clip'; % Mark events within this segment as 'clip'
                    else
                        EEG.event(e).latency = EEG.event(e).latency - (TMPREJ(i, 2) - TMPREJ(i, 1) + 1);
                    end
                end
            end
        end
    end

    % Update EEG structure
    EEG = eeg_checkset(EEG);

    % Clear the global variable
    clear global TMPREJ;

    return;
end
