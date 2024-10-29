function plot_explained_variance_vs_k(k_vec,data_path, pca_results_path, spca_results_path, animals_names,stop)
    animals_db = get_animals_list(data_path, animals_names);
    % err_vec = [];
    % name_vec = [];
    % date_vec = [];

    % loop to load data and create var_vec:
    % matrix of size length(k_vec) x #dates contains SPCA results explained variance, for a single value of k
    var_vec =[];
    for k = k_vec
        % err_vec_per_k = [];
        % name_vec_per_k = [];
        % date_vec_per_k = [];
        var_vec_per_k =[];

        params_folder = fullfile(spca_results_path, ['num_stop' num2str(abs(stop)) 'num_components' num2str(k) ]);
    
        for animal_i =1:length(animals_names)
            dates_list = animals_db{animal_i}.folder(animals_db{animal_i}.to_include == 2);            
            % specific animals' analysis results folder 
            animal_folder = fullfile(params_folder, 'per_animal_per_date',[animals_names{animal_i}]);

            for date_i = 1:length(dates_list)

                % specific dates' analysis results folder
                date_folder = fullfile(animal_folder, [dates_list{date_i}]);
                % folder datapath of results that the current function uses
                resfile_stat = fullfile(date_folder, ['spca_stat' animals_names{animal_i} '_' dates_list{date_i} '.mat']); 

                % in case the data that the current function uses does not exist,
                % run the relevant fuction
                if ~isfolder(animal_folder) | ~isfolder(date_folder) | ~isfile(resfile_stat)
                    apply_spca(data_path, params_folder, animals_names(animal_i),k,stop);
                end
                % if it still does not exist, do not run the loop on
                % this part of the data
                if ~isfolder(animal_folder) | ~isfolder(date_folder) | ~isfile(resfile_stat)
                    continue;
                end
                % load the data that the current function uses
                load(resfile_stat,'spca_stat')

                % vector of length #dates contains SPCA results explained
                % variance, for a single value of k
                var_vec_per_k =[var_vec_per_k,spca_stat.explained_var];

            end
        end
        
        % matrix of size length(k_vec) x #dates contains SPCA results explained variance, for a single value of k
        var_vec =[var_vec;var_vec_per_k];
    end

    % loop to load data and create pca_var_vec:
    % matrix of size 100 x #dates contains PCA results explained variance, for a single value of k
    % CHANGE 100 TO max(k_vec)
    pca_var_vec = [];
    for animal_i =1:length(animals_names)
        dates_list = animals_db{animal_i}.folder(animals_db{animal_i}.to_include == 2);            
        pca_animal_folder = fullfile(pca_results_path,[animals_names{animal_i}]);
        for date_i = 1:length(dates_list)
            % folder datapath of results that the current function uses
            pca_date_folder = fullfile(pca_animal_folder, [dates_list{date_i}]);
            pca_resfile = fullfile(pca_date_folder, ['pca_explained_' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
            % if it  does not exist, do not run the loop on this part
            % of the data
            if ~isfolder(pca_animal_folder) | ~isfolder(pca_date_folder) | ~isfile(pca_resfile)
                continue;
            end
            % load the data that the current function uses
            load(pca_resfile, 'explained_var');

            explained_var = explained_var(1:100)';
            pca_var_vec = [pca_var_vec;explained_var];
        end
    end
        
    pca_var_vec = pca_var_vec';


    if length(k_vec)>1
        % extract avg and std of explained variance values
        spca_var_vec_mean = mean(var_vec,2);
        spca_var_vec_std = std(var_vec,[],2);

        pca_var_vec_mean = mean(pca_var_vec,2);
        pca_var_vec_std = std(pca_var_vec,[],2);
        pca_axis = 1:100;

        % plot Trajectories Explained Variance VS Number of Components
        figure(1)
        shadedErrorBar(k_vec, spca_var_vec_mean, spca_var_vec_std/sqrt(size(var_vec,2)-1),'lineprops','b')
        hold on
        shadedErrorBar(pca_axis, pca_var_vec_mean(pca_axis), pca_var_vec_std(pca_axis)/sqrt(size(pca_var_vec,2)-1),'lineprops','g')
        xlabel('Number of Components');
        ylabel('Trajectories Explained Variance');
        title('Explained Variance vs K Components')

        across_animals_folder = fullfile(params_folder, 'across_animals');
        fig_file = fullfile(across_animals_folder, ['explained_variance_fig' num2str(1) '.fig']);
        saveas(gcf, fig_file)

    end


end
