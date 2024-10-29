function plot_frac_neurons(data_path, params_folder, animals_names,k,stop, session_var, explained_var_flag)

    types_mat = {'train', 'batch';'first', 'batch';'ongoing', 'batch';'ongoing', 'random'};
    animals_db = get_animals_list(data_path, animals_names);


    frac_across_animals_mean_t = [];
    frac_across_animals_std_t = [];
    for t = 1:size(types_mat,1)

        frac_across_animals = [];

        for animal_i =1:length(animals_names)
        dates_list = animals_db{animal_i}.folder(animals_db{animal_i}.to_include == 2);            
        % specific animals' analysis results folder 
        animal_folder = fullfile(params_folder, 'per_animal_per_date',[animals_names{animal_i}]);
        
        frac_across_dates = [];
        type2_vec = [];
        type1_vec = [];
            % loop over all experiments per animal
            for date_i = 1:length(dates_list)
                % specific dates' analysis results folder 
                date_folder = fullfile(animal_folder, [dates_list{date_i}]);
                % folder datapath of results that the current function uses
                resfile_acc = fullfile(date_folder, ['acc' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
                resfile_neurons_fra = fullfile(date_folder, ['fraction_of_neurons' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
                resfile_explained_var_fra = fullfile(date_folder, ['fraction_of_explained_var' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
    
    
                % in case the data that the current function uses does not exist,
                % skip it
                % WE CAN RUN THE RELEVANT FUNCTIONS IN THIS CASE INSTEAD
                if (~isfolder(animal_folder)) | ~isfolder(date_folder) | (~isfile(resfile_acc)) | (~isfile(resfile_neurons_fra))  
                    continue;
                end
                
                load(resfile_neurons_fra,'fraction_of_neurons')
                load(resfile_explained_var_fra, "explained_var_recording");
                load(resfile_acc,'acc')
    
                if explained_var_flag
                    frac_across_dates = cat(3,frac_across_dates,explained_var_recording);
                else
                    frac_across_dates = cat(3,frac_across_dates,fraction_of_neurons);
                end
                type2_vec = [type2_vec animals_db{animal_i}.type2(date_i)];
                type1_vec = [type1_vec animals_db{animal_i}.type1(date_i)];
    
            end
    
            frac = frac_across_dates(:,:,strcmp(type2_vec,types_mat{t,2}) & strcmp(type1_vec,types_mat{t,1}));
            frac_mean = nanmean(frac,3);
            frac_std = nanstd(frac,[],3)/sqrt(size(frac,3)-1);
            % fraction across animals - if wa want animal variance - take
            % means here.
            if(session_var == 1)
                frac_across_animals = cat(3,frac_across_animals,frac);
            else
                frac_across_animals = cat(3,frac_across_animals,frac_mean);
            end
        end
        % fraction to display - mean and SEM of fraction across
        % animals\sessions
        frac_across_animals_mean = nanmean(frac_across_animals,3);
        frac_across_animals_std = nanstd(frac_across_animals,[],3)/sqrt(size(frac_across_animals,3)-1);

        if(isempty(frac_across_animals_mean_t))
            frac_across_animals_mean_t = frac_across_animals_mean;
        else 
            frac_across_animals_mean_t = cat(3, frac_across_animals_mean_t, frac_across_animals_mean);
        end

        if(isempty(frac_across_animals_std_t))
            frac_across_animals_std_t = frac_across_animals_std;
        else 
            frac_across_animals_std_t = cat(3, frac_across_animals_std_t, frac_across_animals_std);
        end

    end

    if (explained_var_flag)
        figure(60)
    else
        figure(50)
    end
    for l=1:9
        subplot(3,3,l)
        h = barwitherr(squeeze(frac_across_animals_std_t(:,l,:)), squeeze(frac_across_animals_mean_t(:,l,:)));% Plot with errorbars
        if (explained_var_flag)
            ylabel('fraction of \newlineexplaind variance')
        else
            ylabel('fraction of neurons')
        end
        ylim([0,1])
        legend('train batch','first batch','ongoing batch','ongoing random')
        set(gca,'XTickLabel',{'start-(-1)','(-1)-2','2-5','5-end'}, 'fontsize', 14)
        title(acc.labels{l})

        across_animals_folder = fullfile(params_folder, 'across_animals');

        if (explained_var_flag)
            fig_file = fullfile(across_animals_folder, ['frac_explained_var_fig' num2str(60) '.fig']);
        else
            fig_file = fullfile(across_animals_folder, ['frac_neurons_fig' num2str(50) '.fig']);
        end

        saveas(gcf, fig_file)


    end


    % l_mat = [[1 2 3];[4 5 6];[7 8 9]];
    % for l_num_ind = 1:size(l_mat,1)
    %     l_num =l_mat(l_num_ind,:);
    %     if (explained_var_flag)
    %         figure(60 + l_num_ind)
    %     else
    %         figure(50 + l_num_ind)
    %     end
    % 
    %     subplot(2,2,t)
    %     h = barwitherr(frac_across_animals_std(:,l_num)', frac_across_animals_mean(:,l_num)');% Plot with errorbars
    % 
    %     set(gca,'XTickLabel',replace(acc.labels(l_num), 'vs', '\newlinevs'), 'fontsize', 14)
    %     legend('start-(-1)','(-1)-2','2-5','5-end')
    %     if (explained_var_flag)
    %         ylabel('fraction of \newlineexplaind variance')
    %     else
    %         ylabel('fraction of neurons')
    %     end
    % 
    %     title([types_mat{t,1} ' ' types_mat{t,2}])
    %     set(h(1),'FaceColor','k');
    %     ylim([0,1])
    % 
    %     across_animals_folder = fullfile(params_folder, 'across_animals');
    %     if (explained_var_flag)
    %         fig_file = fullfile(across_animals_folder, ['frac_explained_var_fig' num2str(60 + l_num_ind) '.fig']);
    %     else
    %         fig_file = fullfile(across_animals_folder, ['frac_neurons_fig' num2str(50 + l_num_ind) '.fig']);
    %     end
    % 
    %     saveas(gcf, fig_file)
    % end
end 