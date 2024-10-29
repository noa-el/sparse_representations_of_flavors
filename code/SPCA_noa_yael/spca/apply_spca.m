function  apply_spca(data_path, params_folder, animals_names,k,stop)

animals_db = get_animals_list(data_path, animals_names);
addpath(genpath('SpcaSM'));
addpath(genpath('pca'));

% parameters for scpa
params.K = k; % how many components we want to extract
params.stop= -stop; % controls how many cells will be selected

% loop over all animals
for animal_i =1:length(animals_names)
    % display animals name
    disp(animals_names{animal_i});

    % specific animals' analysis results folder 
    animal_folder = fullfile(params_folder, 'per_animal_per_date',[animals_names{animal_i}]);
    % if folder doesn't exist create it
    if ~isfolder(animal_folder)
        mkdir(animal_folder);
    end

    % loop over all experiments per animal
    dates_list = animals_db{animal_i}.folder(animals_db{animal_i}.to_include == 2);            
    for date_i = 1:length(dates_list)
        % display date
        disp(dates_list{date_i});

        % specific dates' original data folder
        curr_folder = fullfile(data_path, animals_names{animal_i}, dates_list{date_i});
        % specific dates' original data file
        data_file = fullfile(curr_folder, 'data.mat');
        
        % if folder doesn't exist create it
        if ~isfile(data_file)
            continue;
        end
        
        % specific dates' analysis results folder 
        date_folder = fullfile(animal_folder, [dates_list{date_i}]);
        % if datafile doesn't exists then skip it
        if ~isfolder(date_folder)
            mkdir(date_folder);
        end

        % analysis results files 
        resfile_traj = fullfile(date_folder, ['spca_trajectories_' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
        resfile_stat = fullfile(date_folder, ['spca_stat' animals_names{animal_i} '_' dates_list{date_i} '.mat']);

        % if resfile already exists then skip it
        if isfile(resfile_traj) & isfile(resfile_stat)
            continue;
        end
        % resfile does not exist, we apply the analysis

        % load the data
        load(data_file, 'imagingData', 'BehaveData');


        % BEGINING OF ANALYSIS


        % reorganize the samples into a matrix of neurons over time*trials
        for k = 1:size(imagingData.samples,1)
            data_mat(:, k) = reshape(imagingData.samples(k,:,:), ...
                size(imagingData.samples,3)*size(imagingData.samples,2),1);
        end

        % remove the mean
        spca_traj_res.mu = mean(data_mat);
        x_cent = bsxfun(@minus, data_mat, spca_traj_res.mu);
        % normalize by std
        x_norm = bsxfun(@rdivide, x_cent, sqrt(sum(x_cent.^2)));

        % apply scpa
        [spca_traj_res.kernel, spca_traj_res.eigs] = spca(x_norm, [], params.K, inf, params.stop);

        % get the reconstracted signal and the projections
        % projections are the dimenionality reduced signal
        [recon, proj] = linrecon(x_norm, mean(x_norm), ...
            spca_traj_res.kernel, 1:params.K);% may be x_norm

        % compute reconstracted signal and the explained variance
        spca_stat.recon_error = sum(sum((recon-x_norm).^2));
        var_signal = sum(sum((x_norm).^2));
        spca_stat.explained_var = 1 - spca_stat.recon_error/var_signal;
        spca_stat.comp_explained_var = zeros(params.K,1);

        for comp = 1:params.K
            sum_explained = sum(spca_stat.comp_explained_var);
            comp_recon = x_norm * spca_traj_res.kernel(:,1:comp) * spca_traj_res.kernel(:,1:comp)';
            comp_recon_error = sum(sum((comp_recon-x_norm).^2));
            spca_stat.comp_explained_var(comp) = (1 - comp_recon_error/var_signal) - sum_explained;
        end

        % reorganize into 3dim tensores
        for l=1:size(recon,2)
            spca_traj_res.recon(l,:,:) = reshape(recon(:,l),size(imagingData.samples,2), ...
                size(imagingData.samples,3));
        end
        for l=1:size(proj,2)
            spca_traj_res.projeff(l,:,:) = reshape(proj(:,l), size(imagingData.samples,2), ...
                size(imagingData.samples,3));

        end

        % END OF ANALYSIS


        % save results
        save(resfile_traj, 'spca_traj_res');
        save(resfile_stat, 'spca_stat')
        clear data_mat;
        clear spca_traj_res;

    end
end
end
