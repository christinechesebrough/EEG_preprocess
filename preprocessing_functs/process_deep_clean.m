% This function will automatically remove "bad" data segments from
% continuous data based on the criterion defined below. As an alternative
% to rejecting segments of data manually, it can throw out a lot of data
% unless the criterion are conservative. 

function EEG = process_deep_clean(eeg_file)
    % Load EEG file
    EEG = pop_loadset(eeg_file);
    
    
    % Parameters for clean_rawdata function
% -----------------------------------------------------------------------------------------------------------------------------
%       |       Criterion          | Values            |  Explanation                                                         |
% ----------------------------------------------------------------------------------------------------------------------------|
inputs = {'FlatlineCriterion',       'off',...       % | Maximum tolerated flatline duration in seconds (def: 5)              |
         'ChannelCriterion',         'off',...       % | Rej if chan is correlated with others less than thresh (def: .85)    |
         'LineNoiseCriterion',       'off',...       % | Rej if chan has more line noise than signal in unit of SD (def: 4)   |
         'Highpass',                 'off',...       % | Apply high-pass filter to the data, but already done (def: 'off')    |
         'BurstCriterion',           20,...         % | Find segment of data to clean based on cleanest portion (def: 20)    |
         'WindowCriterion',          .25,...         % | Tolerance for maximum percentage of contamintion for chan (def: .25) |
         'BurstRejection',           'on',...       % | Removes bad data caught by ASR instead of correcting (def: 'on')     |
         'Distance',                 'Euclidian',... % | Which type of distance metric to use (def: 'Euclidian')              |
         'WindowCriterionTolerances',[-Inf,7],...    % | Noise threshold for labeling a chan as contaminated (def: [-Inf 7])  |    
         'BurstCriterionRefTolerances',[-Inf 7],...
         'UseRiemannian',           true,...
         'UseGPU',                  true};
% -----------------------------------------------------------------------------------------------------------------------------


    % Apply clean_rawdata function
    EEG = pop_clean_rawdata(EEG, inputs{:});

    % Check EEG dataset
    EEG = eeg_checkset(EEG);

    return;
end
