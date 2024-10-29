function  preprocess_data(original_data_path,new_data_path, animals_names, parameters)

    animals_db = get_animals_list(original_data_path, animals_names);

    % loop over all animals
    for animal_i = 1:length(animals_names)
        % DISPLAY ANIMALS NAME
        disp(animals_names{animal_i});
    
        % specific animals' analysis results folder 
        animal_folder = fullfile(new_data_path,[animals_names{animal_i}]);
    
        % if folder doesn't exist create it
        if ~isfolder(animal_folder)
            mkdir(animal_folder);
        end
    
        % loop over all experiments per animal
        dates_list = animals_db{animal_i}.folder(animals_db{animal_i}.to_include == 2);

        % will be 1 only for neurons that are recorded in *all* sessions
        neurons = ones(600,1);
        for date_i = 1:length(dates_list)
            % DISPLAY DATE
            disp(dates_list{date_i});
    
            % specific dates' original data folder
            curr_folder = fullfile(original_data_path, animals_names{animal_i}, dates_list{date_i});
            % specific dates' original data file
            original_data_file = fullfile(curr_folder, 'data.mat');
    
            % if datafile doesn't exists then skip it
            if ~isfile(original_data_file)
                continue;
            end
    
            % specific dates' analysis results folder 
            date_folder = fullfile(animal_folder, [dates_list{date_i}]);
    
            % if folder doesn't exist create it
            if ~isfolder(date_folder)
                mkdir(date_folder);
            end
    
            % folder datapath of results that the current function uses
            new_data_file = fullfile(date_folder, 'data.mat');
    
            % if resfile already exists then skip it
            if isfile(new_data_file)
                continue;
            end
            % resfile does not exist, we apply the analysis
    
            % load the data
            load(original_data_file, 'imagingData', 'BehaveData');

            % 1 only for neurons that are recorded in *all* sessions
            for trial = 1:size(imagingData.roiNames,2)
                trial_neurons = zeros(600,1);
                trial_neurons(imagingData.roiNames(:,trial)) = 1;
                neurons = neurons & trial_neurons;
            end
        end
    
        for date_i = 1:length(dates_list)
            % DISPLAY DATE
            disp(dates_list{date_i});
    
            % specific dates' original data folder
            curr_folder = fullfile(original_data_path, animals_names{animal_i}, dates_list{date_i});
            % specific dates' original data file
            original_data_file = fullfile(curr_folder, 'data.mat');
    
            % if datafile doesn't exists then skip it
            if ~isfile(original_data_file)
                continue;
            end
    
            % specific dates' analysis results folder 
            date_folder = fullfile(animal_folder, [dates_list{date_i}]);
    
            % if folder doesn't exist create it
            if ~isfolder(date_folder)
                mkdir(date_folder);
            end
    
            % folder datapath of results that the current function uses
            new_data_file = fullfile(date_folder, 'data.mat');
    
            % if resfile already exists then skip it
            if isfile(new_data_file)
                continue;
            end
            % resfile does not exist, we apply the analysis
    
            % load the data
            load(original_data_file, 'imagingData', 'BehaveData');
    
    
            % BEGINING OF ANALYSIS
            % drop the first second (to avoid the artificial effect in the
            % first few samples
            imagingData.samples = imagingData.samples(:, parameters.time_parameters.first_sec_ind:parameters.time_parameters.f_sample*12, :);
            % the same data sorted by roiNames, NaN for not recorded roiNames 
            new_samples = NaN(600,size(imagingData.samples,2),size(imagingData.samples,3));
            new_roiNames = NaN(600,size(imagingData.roiNames,2));
            for trial = 1:size(imagingData.samples,3)
                new_samples(imagingData.roiNames(:,trial),:,trial) = imagingData.samples(:,:,trial);
                new_roiNames(imagingData.roiNames(:,trial),trial) = imagingData.roiNames(:,trial);
            end
            % take only neurons that are recorded in all sessions
            imagingData.samples = new_samples(neurons == 1,:,:);
            imagingData.roiNames = new_roiNames(neurons == 1,:);
            save(new_data_file, 'imagingData', 'BehaveData');
            % END OF ANALYSIS
        end
    end
end
