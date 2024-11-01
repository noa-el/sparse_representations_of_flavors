function plot_max_acc_per_l_per_type(k, stop_vec, data_path, results_path, analysis_vec, analysis_vec_title, parameters)

    for stop_i = 1:length(stop_vec)
        max_tensor = [];
        for analysis = analysis_vec
            % get trajectories from SPCA
            analysis_folder = fullfile(results_path, [analysis{1} '_results']);
            across_analysis_folder = fullfile(results_path, 'across_analysis_results');
            params_folder =  fullfile(analysis_folder, ['num_stop' num2str(abs(stop_vec(stop_i))) 'num_components' num2str(k)]);
            across_animal_folder = fullfile(params_folder, 'across_animals');
            resfile_max_acc_per_l = fullfile(across_animal_folder, 'max_acc_per_l.mat');
            resfile_type1 = fullfile(across_animal_folder, 'type1_vec.mat');
            resfile_type2 = fullfile(across_animal_folder, 'type2_vec.mat');
            resfile_flavors = fullfile(across_animal_folder, 'flavors_vec.mat');

            if ~isfile(resfile_max_acc_per_l)
                continue;
            end
            load(resfile_max_acc_per_l, 'max_acc_per_l')
            load(resfile_type1, 'type1_vec')
            load(resfile_type2, 'type2_vec')
            load(resfile_flavors, 'flavors_vec')


            max_tensor = cat(3, max_tensor, max_acc_per_l);
        end


        types_mat = {'train', 'batch';'first', 'batch';'ongoing', 'batch';'ongoing', 'random'};
        for t = 1:size(types_mat,1)
            ind = [];
            type_ind = strcmp(type2_vec,types_mat{t,2}) & strcmp(type1_vec,types_mat{t,1});
            if t == 3 || t == 4
                flavors_ind = ones(1,size(flavors_vec,2));
                for flavor = 1:length(flavors_vec)
                    if contains(flavors_vec{flavor},'f')
                        flavors_ind(flavor) = 0;
                    end
                    if length(flavors_vec{flavor}) ~= 5
                        flavors_ind(flavor) = 0;
                    end
                end
                ind = type_ind & flavors_ind;
            else
                ind = type_ind;
            end
            
            max_tensor_type = max_tensor(ind,:,:);
            max_mean_mat = squeeze(nanmean(max_tensor_type,1));
            max_var_mat = squeeze(nanstd(max_tensor_type,[],1)/sqrt(size(max_tensor_type,1)-1));
            max_max_mat = squeeze(max(max_tensor_type,[],1));
            
            figure(70 + t)
            sgtitle([types_mat{t,1} ' ' types_mat{t,2}])
            for l = 1:size(max_mean_mat,1)
                subplot(4,3,l)
                bar(max_mean_mat(l,:))
                hold on
                errorbar(1:numel(max_mean_mat(l,:)), max_mean_mat(l,:), max_var_mat(l,:), 'k.', 'LineWidth', 1)
        
                xticklabels(analysis_vec_title)
        
                xlabel('analysis type')
                ylabel('max normalized accuracy')
                title(write_question(parameters.labels, l))
                hold on
                plot(max_max_mat(l,:),'o')
            end
            fig_file = fullfile(across_analysis_folder, ['max_acc_per_l_per_type_fig' num2str(70 + t) '.fig']);
            saveas(gcf, fig_file)

        end



    end
end


