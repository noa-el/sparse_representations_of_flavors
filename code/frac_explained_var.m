function frac_explained_var(data_path, params_folder, animals_names,k,stop, session_var, explained_var_flag)

    animals_db = get_animals_list(data_path, animals_names);
        frac_across_animals = [];

        for animal_i =1:length(animals_names)
        dates_list = animals_db{animal_i}.folder(animals_db{animal_i}.to_include == 2);            
        % specific animals' analysis results folder 
        animal_folder = fullfile(params_folder, 'per_animal_per_date',[animals_names{animal_i}]);

            % loop over all experiments per animal
            for date_i = 1:length(dates_list)
                % specific dates' analysis results folder 
                date_folder = fullfile(animal_folder, [dates_list{date_i}]);
   
                resfile_explained_var_fra = fullfile(date_folder, ['fraction_of_explained_var' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
                load(resfile_explained_var_fra, "explained_var_recording");

                frac_across_animals = [frac_across_animals explained_var_recording];
                frac_across_animals;
            end
        end
    end
