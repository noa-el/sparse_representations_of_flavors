function plot_acc_chance(k, stop_vec, data_path, spca_resultspath, animals_names, parameters, classification_flags)

    animals_db = get_animals_list(data_path, animals_names);
    
    for stop_i = 1:length(stop_vec)
        % get trajectories from SPCA
        params_folder =  fullfile(spca_resultspath, ['num_stop' num2str(abs(stop_vec(stop_i))) 'num_components' num2str(k) ]);
        across_animal_folder = fullfile(params_folder, 'across_animals');
        date_num = 0;


        for animal_i =1:length(animals_names)
            dates_list = animals_db{animal_i}.folder(animals_db{animal_i}.to_include == 2);            
            % specific animals' analysis results folder 
            animal_folder = fullfile(params_folder, 'per_animal_per_date',[animals_names{animal_i}]);

            % loop over all experiments per animal
            for date_i = 1:length(dates_list)
                % specific dates' analysis results folder 
                date_folder = fullfile(animal_folder, [dates_list{date_i}]);
                % folder datapath of results that the current function uses
                resfile_acc = fullfile(date_folder, ['acc' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
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
                l_mat = [[1 2 3]; [4 5 6]; [7 8 9]]; 
                for l_fig_ind = 1:size(l_mat,1)
                    l_num = l_mat(l_fig_ind,:);
                    % WHY DO WE NEED THIS LOOP?????
                    for l_ind = 1:length(l_num)
                        % calculate accuracy minus chance
                        % MAYBE THIS CAN BE WRITTEN IN A SIMPLE WAY USING acc.acc_mean_norm
                        acc_chance = (((squeeze(acc.mean(:, l_num(l_ind), :)))'-acc.chance(l_num(l_ind)))/acc.chance(l_num(l_ind)));
                    end
                end

                for l_fig_ind = 1:size(l_mat,1)
                    l_num =l_mat(l_fig_ind,:);
                    for l_ind = 1:length(l_num)
                        % plot accuracy minus chance
                        figure(100 + 10 *date_num + l_fig_ind);
                        subplot(length(l_num),length(stop_vec),stop_i+(l_ind-1)*length(stop_vec))            
                        % MAYBE THIS CAN BE WRITTEN IN A SIMPLE WAY USING acc.acc_mean_norm
                        imagesc(acc.wind_mid, 1:size(acc.mean,3), (((squeeze(acc.mean(:, l_num(l_ind), :)))'-acc.chance(l_num(l_ind)))/acc.chance(l_num(l_ind))), [-1, 1]);
                        xlabel('time');
                        ylabel('SPC');
                        title([acc.labels{l_num(l_ind)} ' STOP=' num2str(stop_vec(stop_i))]);
                        colorbar;
                        sgtitle([animals_db{animal_i}.type2{date_i},', ',animals_db{animal_i}.type1{date_i}]);
                        fig_file = fullfile(date_folder, ['acc_chance_fig' num2str(100 + 10 *date_num + l_fig_ind) '.fig']);
                        saveas(gcf, fig_file)
                    end
                end


                acc_to_hist = acc.acc_mean_norm(:,1:9,:);

                figure(100 + 10 *date_num + 5);
                subplot(1,length(stop_vec),stop_i) 
                histogram(acc_to_hist(:))
                title('accuracy minus chance histogram')
                xlabel('accuracy minus chance')
                ylabel('count')
                xlim([-1,1])
                fig_file = fullfile(date_folder, ['acc_chance_hist_fig' num2str(100 + 10 *date_num + 5) '.fig']);
                saveas(gcf, fig_file)
            end
        end


        % END OF ANALYSIS




    end
end


