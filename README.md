# EEG_preprocess
EEG preprocessing and analysis pipelines for scalp EEG data developed for the Dynamic Mind & Brain Lab
This pipeline is developed for preprocessing of EEG data using the eeglab MATLAB plugin. 

The initial preprocessing steps (in preprocessing_functs) are called using the run_full_preprocessing_DMBL script. Each step of the process is associated with a different function. 
Each of these functions is called using the master process_eeg_data function, which takes as inputs the the main input directory, output directory, specific processing function, and file suffix. The exception is the concatenation step, which calls the related master function called "process_eeg_data_for_concatenation") 

This pipeline requires the MATLAB Add-Ons (download from MathWorks with License)
    Signal Processing Toolbox
    Statistics and Machine Learning Toolbox

and requires the following EEGLAB plugins:
     Fileio
     Fieldtrip
     IC Label
     Cleanline
     MARA (ICA)
     Carbon wire loop (CWL)
    
**The steps in the processing pipeline are as follows**

0. If collected with concurrent fMRI, carbon-wire loop artifact regression
1. Initial processing and cleaning (downsample, add electrode locations, band-pass filter, remove line noise, 
 and re-reference) 
2. Re-label event labels
3. Concatenating recordings from each subject into a single recording
4. Run ICA 
5. Reject ICA components using MARA algorithm or ICLabel
6. Manually inspect the post- ICA component-rejected data to note noisy channels and remaining artifacts for interpolation/ rejection 
8. Where relevant, in the pre-ICA data, interpolate channels that are noisy or highly
artifactual in the post-ICA data, then re-run steps 4-5 for those subjects
9. Manually reject segments of continous data with remaining artifacts (must use GUI)
10. Epoch data around events of interest (typically, "Q1_on", i.e. onset
of first thought-probe question)

An optional deep cleaning function (using ASR) can also be used for cleaning continuous data, but this step is optional / not recommended)

**Utils** 
Reference files for electrode locations and event labels 

**Ratings**
Code to extract the subject ratings from .mat files and then preprocess those data for further use are found in the process_ratings folder. 
The initial extraction of subject ratings is written in MATLAB, and their preprocessing as dataframes is done in R (feel free to change in the future)

**SPM analyses**
Code to run the SPM analyses can be found in the SPM folder

