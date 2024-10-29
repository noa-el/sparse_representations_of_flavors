function save_max_acc(k, stop_vec, data_path, spca_resultspath, animals_names, parameters, classification_flags)

    animals_db = get_animals_list(data_path, animals_names);
    
    for stop_i = 1:length(stop_vec)
        % get trajectories from SPCA
        params_folder =  fullfile(spca_resultspath, ['num_stop' num2str(abs(stop_vec(stop_i))) 'num_components' num2str(k) ]);
        across_animal_folder = fullfile(params_folder, 'across_animals');
        resfile_max_acc = fullfile(across_animal_folder, 'max_acc.mat');
        resfile_max_acc_per_l = fullfile(across_animal_folder, 'max_acc_per_l.mat');
        resfile_type1 = fullfile(across_animal_folder, 'type1_vec.mat');
        resfile_type2 = fullfile(across_animal_folder, 'type2_vec.mat');
        resfile_flavors = fullfile(across_animal_folder, 'flavors_vec.mat');

        date_num = 0;
        max_acc_vec = [];
        max_acc_per_l = [];
        type2_vec = [];
        type1_vec = [];
        flavors_vec = [];

        for animal_i =1:length(animals_names)
            dates_list = animals_db{animal_i}.folder(animals_db{animal_i}.to_include == 2);            
            % specific animals' analysis results folder 
            animal_folder = fullfile(params_folder, 'per_animal_per_date',[animals_names{animal_i}]);

            % loop over all experiments per animal
            for date_i = 1:length(datesList)
                % specific dates' analysis results folder 
                date_folder = fullfile(animal_folder, [datesList{date_i}]);
                % folder datapath of results that the current function uses
                resfile_acc = fullfile(date_folder, ['acc' animals_names{animal_i} '_' datesList{date_i} '.mat']);
                % in case the data that the current function uses does not exist,
                % run the relevant fuction
                if ~isfolder(animal_folder) | ~isfolder(date_folder) | ~isfile(resfile_acc) 
                    apply_spca(data_path, params_folder, animals_names,k,stop_vec(stop_i));
                    apply_classifier(data_path, params_folder, animals_names,k,stop_vec(stop_i), parameters, classification_flags,0);
                end
                % if it still does not exist, do not run the loop on this part of
                % the data
                if ~isfolder(animal_folder) | ~isfolder(date_folder) | ~isfile(resfile_acc) 
                    continue;
                end

                load(resfile_acc,'acc')


                % BEGINING OF ANALYSIS


                date_num = date_num +1;
                % matrix contains the numbers of labels/ questions to plot, different figures for rows
                l_mat = [[1 2 3]; [4 5 6];[7 8 9]]; 

                max_per_l_vec = [];
                for l_fig_ind = 1:size(l_mat,1)
                    l_num = l_mat(l_fig_ind,:);
                    for l_ind = 1:length(l_num)
                        % calculate accuracy minus chance
                        % MAYBE THIS CAN BE WRITTEN IN A SIMPLE WAY USING acc.acc_mean_norm
                        acc_chance = (((squeeze(acc.mean(:, l_num(l_ind), :)))'-acc.chance(l_num(l_ind)))/acc.chance(l_num(l_ind)));
                        % maximum value of accuracy minus chance
                        max_per_l = max(acc_chance,[],'all');
                        max_per_l_vec = [max_per_l_vec max_per_l];
                    end
                end
                % maximum value of accuracy minus chance over l
                max_val = max(max_per_l_vec);
                max_acc_vec = [max_acc_vec max_val];
                max_acc_per_l = [max_acc_per_l ;max_per_l_vec];
                type2_vec = [type2_vec animals_db{animal_i}.type2(date_i)];
                type1_vec = [type1_vec animals_db{animal_i}.type1(date_i)];
                flavors_vec = [flavors_vec animals_db{animal_i}.flavors(date_i)];
            end
        end


        % END OF ANALYSIS


        save(resfile_max_acc, 'max_acc_vec')
        save(resfile_max_acc_per_l, 'max_acc_per_l')
        save(resfile_type1, 'type1_vec')
        save(resfile_type2, 'type2_vec')
        save(resfile_flavors, 'flavors_vec')


    end
end


