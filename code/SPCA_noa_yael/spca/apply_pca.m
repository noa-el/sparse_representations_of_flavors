function  apply_pca(data_path, pca_folder, animals_names)

animals_db = get_animals_list(data_path, animals_names);
addpath(genpath('SpcaSM'));
addpath(genpath('pca'));

% loop over all animals
for animal_i =1:length(animals_names)
    disp(animals_names{animal_i});
    dates_list = animals_db{animal_i}.folder(animals_db{animal_i}.to_include == 2);            

    % results folder of the specific animal
    animal_folder = fullfile(pca_folder,[animals_names{animal_i}]);
    % if folder does not exist - create it
    if ~isfolder(animal_folder)
        mkdir(animal_folder);
    end

    % loop over all experiments per animal
    for date_i = 1:length(dates_list)
        disp(dates_list{date_i});
        % data file and folder
        data_folder = fullfile(data_path, animals_names{animal_i}, dates_list{date_i});
        data_file = fullfile(data_folder, 'data.mat');
        % if data file does not exist - skip it
        if ~isfile(data_file)
            continue;
        end

        % results folder of the specific date
        date_folder = fullfile(animal_folder, [dates_list{date_i}]);
        % if folder does not exist - create it
        if ~isfolder(date_folder)
            mkdir(date_folder);
        end

        res_file = fullfile(date_folder, ['pca_explained_' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
        % if resfile already exists - skip it
        if isfile(res_file) 
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
        pca_traj_res.mu = mean(data_mat);
        x_cent = bsxfun(@minus, data_mat, pca_traj_res.mu);
        % normalize by std
        x_norm = bsxfun(@rdivide, x_cent, sqrt(sum(x_cent.^2)));

        % apply scpa
        [pca_traj_res.kernel, p, pca_traj_res.eigs] = pca(x_norm);

        explained_var = cumsum(pca_traj_res.eigs.^2) / sum(pca_traj_res.eigs.^2);

        % % get the reconstracted signal and the projections
        % % projections are the dimenionality reduced signal
        % [srecon_m, sprojeff] = linrecon(alldataNT, pcaTrajres.mu, ...
        %     pcaTrajres.kernel, 1:params.K);% may be x_norm
        % 
        % % compute reconstracted signal and the explained variance
        % spca_stat.recon_error = sum(sum((srecon_m-alldataNT).^2));
        % var_signal = sum(sum((alldataNT-mean(alldataNT(:))).^2));
        % spca_stat.explained_var = 1 - spca_stat.recon_error/var_signal;
        % 
        % % reorganize into 3dim tensores
        % for l=1:size(srecon_m,2)
        %     pcaTrajres.recon(l,:,:) = reshape(srecon_m(:,l),size(imagingData.samples,2), ...
        %         size(imagingData.samples,3));
        % end
        % for l=1:size(sprojeff,2)
        %     pcaTrajres.projeff(l,:,:) = reshape(sprojeff(:,l), size(imagingData.samples,2), ...
        %         size(imagingData.samples,3));
        % end


        % END OF ANALYSIS



        % save results
        save(res_file, 'explained_var');
        clear data_mat;
        clear pca_traj_res;

    end
end
end
