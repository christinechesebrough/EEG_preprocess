%% Initialize loop through converted and relabeled .mat files

% Define path to directory to SPM converted files
main_directory = '/Users/christinechesebrough/Documents/MW_EEG_dir/MW_EEG_SPM/MW_EEG_SPM_converted_Z_25'

% Loop through subject folders
subject_folders = dir(main_directory);
subject_folders = subject_folders([subject_folders.isdir]);
subject_folders = subject_folders(~ismember({subject_folders.name}, {'.', '..'}));

for i = 1:length(subject_folders)
    subject_folder = fullfile(main_directory, subject_folders(i).name);
    mat_files = dir(fullfile(subject_folder, '*.mat'));

    for j = 1:length(mat_files)
        mat_file = fullfile(subject_folder, mat_files(j).name);
        name = mat_files(j).name;
        

        % Load the .mat file containing the SPM MEEG object
        D = spm_eeg_load(mat_file);


%% FFT w/HANNING


        S = [];
        S.D = [subject_folder,filesep,name];
        S.channels = {'all'};
        S.frequencies = 1:50;
        S.timewin = [-Inf Inf];
        S.phase = 0;
        S.method = 'mtmfft';
        S.settings.taper = 'hanning';
        %S.prefix = 'tf_'
        D = spm_eeg_tf(S);



%% ROBUST AVERAGE

        S = [];
        S.D = [subject_folder,filesep,'tf_',name(1:end-4),'.mat'];
        S.robust.ks = 3;
        S.robust.bycondition = true;
        S.robust.savew = false;
        S.robust.removebad = false;
        S.circularise = false;
        S.prefix = 'm_';
        D = spm_eeg_average(S);


        %% TF RESCALE
        S = [];
        S.D = [subject_folder,filesep,'m_tf_',name(1:end-4),'.mat'];
        S.method = 'log';
        S.prefix = 'log_';
        S.timewin = [-Inf Inf];
        D = spm_eeg_tf_rescale(S);


        %% Convert to image

        % % % 1)For time frequency
        % % S.D = [savePath,'r_rm_tf_',name,'.mat'];
        % % S.mode = 'time x frequency';
        % 
        % 2)For scalp frequency
        S.D = [subject_folder,filesep,'log_m_tf_',name(1:end-4),'.mat'];

        S.mode = 'scalp x frequency';

        % Freqwin = [];
        %S.freqwin = Freqwin; % Modifying frequency window to only certain frequencies

        S.prefix = 'temp_';
        S.timewin = [-Inf Inf];
        S.freqwin = [-Inf Inf];
        S.channels = 'all';
        D = spm_eeg_convert2images(S);



%% Z-transform
% Create folder to save z-transformed image

        % Z-transform "mental" condition
        % Copy files to destFolder
        destFolder = [subject_folder,filesep 'z_',name(1:end-4)];

        if ~exist(destFolder, 'dir')
            mkdir(destFolder)
        end
        copyfile([subject_folder,filesep,'temp_log_m_tf_',name(1:end-4),'/condition_mental.nii'], destFolder, 'f');
        file2process = [destFolder filesep 'condition_mental.nii'];

        v1n = spm_vol(file2process);

        v1  = spm_read_vols(spm_vol(file2process));  % the actual volume
        
            
            boundaryMask = isnan(v1(:,:,1));
            v1(isnan(v1)) = 0;   % replace NaN if they are present
            
            voldim = size(v1);
            
            % bands = [2,4;...  % Delta: 2- 3.5 Hz
            %         4,8;...  % Theta: 4.0 - 7.5 Hz
            %         8,10;...  % Alpha1: 8.0 - 9.5 Hz
            %         10,13;..1.% Alpha2: 10.0 -12.5 Hz
            %         13,18;...% Beta1: 13.0 - 17.5 Hz
            %         18,25;...% Beta2: 18.0 - 24.5 Hz
            %         25,30;...% Beta3: 25.0 - 29.5 Hz
            %         30,35;...% Gamma1: 30.0 - 34.5 Hz
            %         35,45;...% Gamma2: 35.0 - 44.5 Hz
            %         45,55];     % Gamma3: 45.0 - 55.0 Hz
            
            
  
            if length(voldim) == 2
                for i = 1:voldim(1,2) %In case of two dimensions (time x frequency)
                    fstep = v1(i,:); %select only freqency bin i
                    v = fstep(fstep~=0); % select only non-zero values
                    m  = mean(v);
                    sd = std(v);
                    fstep = (fstep - m) / sd;
                    fstep(boundaryMask) = NaN;
                    vol(i,:,image) = fstep;
                end
            else
                if length(voldim) == 3
                    for i = 1:voldim(1,3) % In case of three dimensions (scalp x frequency, scalp x time)
                        fstep = v1(:,:,i); %select only freqency bin i
                        v = fstep(fstep~=0); % select only non-zero values
                        m  = mean(v);
                        sd = std(v);
                        fstep = (fstep - m) / sd;
                        fstep(boundaryMask) = NaN;
                        vol(:,:,i) = fstep;
                        %vol(:,:,i,image) = fstep;
                    end
                    
                end       
            
        end

        v1n = spm_write_vol(v1n,vol);
        
        % Z-transform "physical" condition
        % Copy files to destFolder
        destFolder = [subject_folder,filesep 'z_',name(1:end-4)];

        if ~exist(destFolder, 'dir')
            mkdir(destFolder)
        end
        copyfile([subject_folder,filesep,'temp_log_m_tf_',name(1:end-4),'/condition_physical.nii'], destFolder, 'f');
        file2process = [destFolder filesep 'condition_physical.nii'];

        v1n = spm_vol(file2process);

        v1  = spm_read_vols(spm_vol(file2process));  % the actual volume
        
            
            boundaryMask = isnan(v1(:,:,1));
            v1(isnan(v1)) = 0;   % replace NaN if they are present
            
            voldim = size(v1);
            
            % bands = [2,4;...  % Delta: 2- 3.5 Hz
            %         4,8;...  % Theta: 4.0 - 7.5 Hz
            %         8,10;...  % Alpha1: 8.0 - 9.5 Hz
            %         10,13;..1.% Alpha2: 10.0 -12.5 Hz
            %         13,18;...% Beta1: 13.0 - 17.5 Hz
            %         18,25;...% Beta2: 18.0 - 24.5 Hz
            %         25,30;...% Beta3: 25.0 - 29.5 Hz
            %         30,35;...% Gamma1: 30.0 - 34.5 Hz
            %         35,45;...% Gamma2: 35.0 - 44.5 Hz
            %         45,55];     % Gamma3: 45.0 - 55.0 Hz
            
            
  
            if length(voldim) == 2
                for i = 1:voldim(1,2) %In case of two dimensions (time x frequency)
                    fstep = v1(i,:); %select only freqency bin i
                    v = fstep(fstep~=0); % select only non-zero values
                    m  = mean(v);
                    sd = std(v);
                    fstep = (fstep - m) / sd;
                    fstep(boundaryMask) = NaN;
                    vol(i,:,image) = fstep;
                end
            else
                if length(voldim) == 3
                    for i = 1:voldim(1,3) % In case of three dimensions (scalp x frequency, scalp x time)
                        fstep = v1(:,:,i); %select only freqency bin i
                        v = fstep(fstep~=0); % select only non-zero values
                        m  = mean(v);
                        sd = std(v);
                        fstep = (fstep - m) / sd;
                        fstep(boundaryMask) = NaN;
                        vol(:,:,i) = fstep;
                        %vol(:,:,i,image) = fstep;
                    end
                    
                end
            
            
            
            
        end



        % if ~contains(file2process,',1')
        % 	% OK
        % else
        % 	% get rid of the suffix
        % 	file1 = file1(1:strfind(file2process,',1')-1);
        % end

        v1n = spm_write_vol(v1n,vol);

            end
        end 

