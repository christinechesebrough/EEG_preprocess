% This function is meant to help you visualize and then manually reject bad
% channels for interpolation.
 
% NOTE !!! Bad channels should be interpolated based on their characteristics AFTER
% ICA, because ICA will remove much of the artifactual components of the
% data. You should loop through the recordings post-ICA rejection to
% identify which channels should be interpolated pre-ICA. Then, reject
% those channels in the pre-ICA recording, and re-run ICA. 

% If you set show plot = true from run_full_preprocessing, it will loop through all of the files in each
% subfolder in a directory, print the kurtosis of each of the channels, and
% recommend which channels may be artifactual based on the kurtosis
% parameter. Ignore this if you are looking at the pre-ICA data. 

% Then, it plot the eeg data (scroll) for you to visually
% inspect and identify bad channels. When you close the plot, it will
% prompt you to enter the indices of the channels you want to interpolate.
% You can also run it with show plot = false if you've already manually
% inspected the data and just want to enter the bad channels for interpolation. 

% By doing this, the entire length of the channel will be interpolated, 
% You can also interpolate segments of data but to do so you need to use
% the eeglab GUI

function EEG = process_interpolate_badChans(eeg_file, show_plot)
    % Extracting subject name from the eeg_file path
    [subject_folder_path, ~, ~] = fileparts(eeg_file);
    [~, subject_name] = fileparts(subject_folder_path);
    disp(['Processing Subject: ' subject_name]);

    % Open EEG file
    EEG = pop_loadset(eeg_file);

    % Parameter for rejecting bad channels based on kurtosis
    param.chanRejKurt = 15; % channels with kurtosis > 10 may be artifactual, but visual judgment is advised. 

    % Identify channels based on kurtosis
    [EEG, badChannels] = pop_rejchan(EEG, 'elec', 1:EEG.nbchan ,'threshold', param.chanRejKurt, 'norm', 'on', 'measure', 'kurt');

    if isempty(badChannels)
        fprintf('No channels were found to be artifactual based on the given kurtosis parameter, but complete visual inspection to be sure\n');
    else
        fprintf('Channels [%s] may be artifactual\n', num2str(badChannels));
    end
    
    if show_plot
        % Review Data using GUI
        eegplot(EEG.data, 'srate', EEG.srate, 'spacing', 30, 'title', 'Scroll Dataset', ...
                'eloc_file', EEG.chanlocs, 'events', EEG.event, ...
                'command', 'EEG = eeg_rejsuperpose(EEG, 1, 1, 1, 1, 1, 1, 1, 1); EEG = pop_rejepoch(EEG, find(EEG.reject.rejmanual), 0); [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); eeglab redraw;');

        % Wait for the eegplot window to be closed
        uiwait;
        
    end
   
    % Prompt the user to input bad channels
    prompt = 'Enter bad channels to interpolate (e.g., [1, 2, 3]) or empty if none: ';
    badChannels = input(prompt);

    % Check if badChannels is not empty and interpolate
    if ~isempty(badChannels)
        EEG = eeg_interp(EEG, badChannels, 'spherical');
    end

    return
end
