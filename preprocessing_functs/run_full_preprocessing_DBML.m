%% EEG Preprocessing Pipeline for Dynamic Mind and Brain Lab 

% Authored by Christine Chesebrough (2023)
% Written with MATLAB R20109b and EEGLAB 2023.1 (need to be using the most
% recent version of eeglab)

% Requires the MATLAB Add-Ons (download from MathWorks with License)
    % Signal Processing Toolbox
    % Statistics and Machine Learning Toolbox

% Requires the following EEGLAB plugins:
    % Fileio
    % Fieldtrip
    % IC Label
    % Cleanline
    % MARA (ICA)
    % Carbon wire loop (CWL)
    
%% Steps in the processing pipeline

% 0. If collected with concurrent fMRI, carbon-wire loop artifact regression
% 1. Initial processing and cleaning (downsample, add electrode locations, band-pass filter, remove line noise, 
% and re-reference) 
% 2. Re-label event labels
% 3. Concatenating recordings from each subject into a single recording
% 4. Run ICA 
% 5. Reject ICA components using MARA algorithm or ICLabel
% 6. Manually inspect the post- ICA component-rejected data to note noisy channels and remaining artifacts for interpolation/ rejection 
% 8. Where relevant, in the pre-ICA data, interpolate channels that are noisy or highly
% artifactual in the post-ICA data, then re-run steps 4-5 for those subjects
% 9. Manually reject segments of continous data with remaining artifacts
% 10. Epoch data around events of interest (typically, "Q1_on", i.e. onset
% of first thought-probe question. 

% An optional deep cleaning function (using ASR) can also be used for cleaning continuous data, but this step is optional / not recommended)

%% Carbon-Wire Loop Correction

% Define the main and output directories
main_directory = ''; %path to your input directory
output_main_directory = ''; % path to your output directory

% Define the file extension and output suffix
eeg_extension = '.eeg'; % should be .eeg if this is the first step, otherwise '.set'
output_suffix = '_cwregression_corrected';

% Call the process_eeg_data function with the CW regression correction function
process_eeg_data(main_directory, output_main_directory, eeg_extension, @process_CWLcorrect, output_suffix);

%% Initial Cleaning

% Define the main and output directories
main_directory = ''; %path to your input directory
output_main_directory = ''; % path to your output directory

% Define the file extension to look for in the main directory
eeg_extension = '.eeg'; % use '.eeg' if this is the first step, or if CWL regression was used as the first step, use '.set' here

% Define the suffix for the new saved files in the output directory
output_suffix = '_cleaned';

% Call the process_eeg_data function with the initial cleaning process function
process_eeg_data(main_directory, output_main_directory, eeg_extension, @process_initial_cleaning, output_suffix);

%% Automatic relabeling of events

% Define the main and output directories
main_directory = ''; %path to your input directory
output_main_directory = ''; % path to your output directory

% Define the file extension to look for in the main directory
eeg_extension = '.set'; 

% Define the suffix for the new saved files in the output directory
output_suffix = '_relabeled';

% Call the process_eeg_data function with the @process_event_relabeling function
process_eeg_data(main_directory, output_main_directory, eeg_extension, @process_event_relabeling, output_suffix);


%% Concatenate recordings across each subject
% this section calls a different global processing function called
% "process_eeg_data_for_concatenation" rather than "process_eeg_data"

% Define the main and output directories
main_directory = ''; %path to your input directory
output_main_directory = ''; % path to your output directory

% Define the file extension to look for in the main directory
eeg_extension = '.set'; % Adjust as needed

% Define the suffix for the new saved files in the output directory
output_suffix = '_concat';

% Call the process_eeg_data function with the @process_concat_recordings function
process_eeg_data_for_concatenation(main_directory, output_main_directory, eeg_extension, @process_concat_recordings, output_suffix);


%% Run ICA using RUNICA algorithm

% Define the main and output directories
main_directory = ''; %path to your input directory
output_main_directory = ''; % path to your output directory

% Define the file extension to look for in the main directory
eeg_extension = '.set'; 

% Define the suffix for the ICA processed files
output_suffix = '_ICA';

% Call the process_eeg_data function with the @process_run_ica function
process_eeg_data(main_directory, output_main_directory, eeg_extension, @process_ica_runica, output_suffix);

%% ICA Rejection
% Here, we are calling the @process_ica_rejection_mara function which uses
% the MARA plug-in instead of the ICLabel function
% @process_ica_rejection_iclabel

% Define the main and output directories
main_directory = ''; %path to your input directory
output_main_directory = ''; % path to your output directory

% Define the file extension to look for in the main directory
eeg_extension = '.set'; 

% Define the suffix for the new saved files in the output directory
output_suffix = '_ICA_rej';

% Call the process_eeg_data function with the @process_ica_rejection_mara function
process_eeg_data(main_directory, output_main_directory, eeg_extension, @process_ica_rejection_mara, output_suffix);


%% Manual inspection and bad channel interpolation

% Define the main and output directories
main_directory = ''; %path to your input directory
output_main_directory = ''; % path to your output directory

% Define the file extension to look for in the main directory
eeg_extension = '.set'; 

% Define the suffix for the new saved files in the output directory
output_suffix = '_interp';

% Decide whether you want the eeg data to be plotted on each loop or not.
% On first pass, this can be set to true, then false if you want to go back
% through and pass the indices of bad channels

show_plot = true; % Set to false to not show the plot

% Call the @process_manual_rejection function
process_eeg_data(main_directory, output_main_directory, eeg_extension, ...
                 @(eeg_file) process_interpolate_badChans(eeg_file, show_plot), ...
                 output_suffix);
             

%% Deep Cleaning: Bad channel rejection and ASR (OPTIONAL)

% Define the main and output directories
main_directory = ''; %path to your input directory
output_main_directory = ''; % path to your output directory

% Define the file extension and output suffix
eeg_extension = '.set'; 

output_suffix = '_asr';

% Call the process_eeg_data function with the EEG preprocessing function
process_eeg_data(main_directory, output_main_directory, eeg_extension, @process_deep_clean, output_suffix);

%% Manual rejection of bad segments

% Currently, this works to show the (scroll) eeg data to manually inspect,
% but rejection of continuous segments only works in the EEGLAB GUI and is
% the most reliable method. 

% Define the main and output directories
main_directory = ''; %path to your input directory
output_main_directory = ''; % path to your output directory

% Define the file extension and suffix
eeg_extension = '.set'; % Adjust as needed
output_suffix = '_manualreject';

% Call the process_eeg_data function with the manual rejection processing function
process_eeg_data(main_directory, output_main_directory, eeg_extension, @process_man_rej, output_suffix);

%% Epoching

% Define the main and output directories

main_directory = ''; %path to your input directory
output_main_directory = ''; % path to your output directory

% Define the file extension to look for in the main directory
eeg_extension = '.set';

% Define the suffix for the new saved files in the output directory
output_suffix = '_epoched';

% Specify the event label and time window for epoching
eventLabel = 'Q1_on';
timeWindow = [-5.5, 0.01];

% Call the process_eeg_data function with the process_epoching function
process_eeg_data(main_directory, output_main_directory, eeg_extension, ...
                 @(eeg_file) process_epoching(eeg_file, eventLabel, timeWindow), ...
                 output_suffix);
             
             

