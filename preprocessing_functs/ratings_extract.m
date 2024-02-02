%% Used to extract ratings from .mat files in subject folders

% Define the main directory where subfolders are located
mainDir = ''; % path to your input directory

% Create a new directory for saving output files
outputDir = ''; % path to your output directory

if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
% List all subdirectories in mainDir and select only directories
subDirs = dir(mainDir);
subDirs = subDirs([subDirs.isdir]);  
subDirs = subDirs(~ismember({subDirs.name}, {'.', '..'})); 

% Loop through subdirectories
for dirIdx = 1:numel(subDirs)
    subDir = fullfile(mainDir, subDirs(dirIdx).name);
    
    % List .mat files in the subfolder
    matFiles = dir(fullfile(subDir, '*.mat'));
    
    % initiate variables for concatenated data
    att_ratings=[]; past_ratings=[]; fut_ratings=[]; self_ratings=[]; ppl_ratings=[]; arousal_ratings=[]; valence_ratings=[];
    mvmt_ratings=[]; engage_ratings=[]; delib_ratings=[];image_ratings=[]; ling_ratings=[]; conf_ratings=[];

    % loop through all runs and concatenate ratings
    for i=1:size(matFiles,1)
        Results=[];
        load(fullfile(matFiles(i).folder, matFiles(i).name));
        att_ratings = [att_ratings; Results.att_response];
        past_ratings = [past_ratings; Results.past_response];
        fut_ratings = [fut_ratings; Results.fut_response];
        self_ratings = [self_ratings; Results.self_response];
        ppl_ratings = [ppl_ratings; Results.ppl_response];
        arousal_ratings = [arousal_ratings; Results.arou_response];
        valence_ratings = [valence_ratings; Results.aff_response];
        mvmt_ratings = [mvmt_ratings; Results.mvmt_response];
        engage_ratings = [engage_ratings; Results.eng_response];
        delib_ratings = [delib_ratings; Results.delib_response];
        image_ratings = [image_ratings; Results.image_response];
        ling_ratings = [ling_ratings; Results.ling_response];
        conf_ratings = [conf_ratings; Results.conf_response];
    end

    % create a matrix with all ratings
    all_ratings = [att_ratings past_ratings fut_ratings self_ratings ppl_ratings arousal_ratings valence_ratings...
        mvmt_ratings engage_ratings delib_ratings image_ratings ling_ratings conf_ratings];

    % define the column names
    rating_titles = {'Attention', 'Past Oriented', 'Future Oriented', 'Self', 'Others', 'Arousal', 'Valence',...
        'Freely Moving', 'Constrained', 'Deliberate', 'Visual', 'Linguistic', 'Confidence'};

    % create a table including the ratings matrix with rating_titles as
    % column names
    dataTable = array2table(all_ratings, 'VariableNames', rating_titles);

    % Generate a unique CSV file name based on the subfolder name
    csvFileName = fullfile(outputDir, [subDirs(dirIdx).name '_output.csv']);
    
    % Save the table with subject's ratings to the CSV file
    writetable(dataTable, csvFileName);
    
    fprintf('Saved data to %s\n', csvFileName);
end