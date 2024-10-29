function compare_correlation_bookkeeping(data_path, params_folder, animals_names,k,stop,parameters, to_plot)
    animals_db = get_animals_list(data_path, animals_names);
    for animal_i =1:length(animals_names)
        dates_list = animals_db{animal_i}.folder(animals_db{animal_i}.to_include == 2);

        across_dates_folder = fullfile(params_folder, 'per_animal_across_dates',[animals_names{animal_i}]);
        if ~isfolder(across_dates_folder)
            mkdir(across_dates_folder);
        end
        % folder datapath of results that the current function uses
        resfile_corr_degree_order = fullfile(across_dates_folder, ['correlation_degree_order' animals_names{animal_i} '.mat']);
        neurons_recording_across_dates_order_file = fullfile(across_dates_folder, ['neurons_recording_across_dates_order']);
        neurons_recording_acc_values_across_dates_order_file = fullfile(across_dates_folder, ['neurons_recording_acc_values_across_dates_order']);

        % folder datapath of the current functions' results
        spearman_file = fullfile(across_dates_folder, ['spearman' animals_names{animal_i} '.mat']);

        % load the data
        load(resfile_corr_degree_order,"corr_degree_across_dates_order");
        load(neurons_recording_across_dates_order_file,"neurons_recording_across_dates_order")
        load(neurons_recording_acc_values_across_dates_order_file,"neurons_recording_acc_values_across_dates_order")


        for l = 1:parameters.Q
            for w = 1:parameters.W
                for date_i = 1:parameters.S
                    bin_acc_values = squeeze(neurons_recording_across_dates_order(w,l,:,date_i));
                    % acc_values: neurons
                    % corr_values: neurons
                    % take relevant accuracy & corr_degree vectors to
                    % calculate spearman's rho
                    acc_values = squeeze(neurons_recording_acc_values_across_dates_order(w,l,:,date_i));
                    corr_values = squeeze(corr_degree_across_dates_order(date_i,:,w));
                    % spearman: time windows X questions X sessions
                    % calculate spearman's rho between accuracy & corr_degree
                    % per window, per question and per session
                    [rho, p_val] = corr(acc_values,corr_values', 'Type', 'Spearman');
                    if(p_val < 0.05)
                        spearman(w,l,date_i) = rho;
                    else 
                        spearman(w,l,date_i) = NaN;
                    end
                end
            end

            if(to_plot)
                figure(40 + animal_i);
                subplot(3,3,l)

                % display spearman: time windows X sessions
                % for every question
                h = imagesc(squeeze(spearman(:,l,:)));

                % NaN values will be white
                set(h, 'AlphaData', ~isnan(squeeze(spearman(:,l,:))));

                % color limits 
                clim([min(spearman(:)) max(spearman(:))]);
                colormap jet;
                colorbar;

                set(gca,'XTick',1:length(parameters.type_vec_across_animals));
                set(gca,'XTickLabel',[parameters.type_vec_across_animals], 'fontsize', 8);
                xtickangle(90)
                set(gca,'YTick',1:size(spearman,1));
                set(gca,'YTickLabel',[parameters.time_parameters.win_str], 'fontsize', 8);
                
                title([write_question(parameters.labels, l)]);
                sgtitle(['Spearman ' animals_names{animal_i}]);
            end
        end

        save(spearman_file,'spearman');
    end
end 