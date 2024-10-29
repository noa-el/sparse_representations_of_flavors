function plot_max_acc_per_l(k, stop_vec, data_path, results_path, analysis_vec)
% NOT USED
    for stop_i = 1:length(stop_vec)
        max_ten = [];
        for analysis = analysis_vec
            % get trajectories from SPCA
            analysis_folder = fullfile(results_path, [analysis{1} '_results']);
            params_folder =  fullfile(analysis_folder, ['num_stop' num2str(abs(stop_vec(stop_i))) 'num_components' num2str(k)]);
            across_animal_folder = fullfile(params_folder, 'across_animals');
            resfile_max_acc_per_l = fullfile(across_animal_folder, 'max_acc_per_l.mat');

            if ~isfile(resfile_max_acc_per_l)
                continue;
            end
            load(resfile_max_acc_per_l, 'max_acc_per_l')
            max_ten = cat(3, max_ten, max_acc_per_l);
        end
        max_mean_mat = squeeze(nanmean(max_ten,1));
        max_var_mat = squeeze(nanstd(max_ten,[],1)/sqrt(size(max_ten,1)-1));
        max_max_mat = squeeze(max(max_ten,[],1));
        
        for l = 1:size(max_mean_mat,1)
            figure(75)
            subplot(4,3,l)
            bar(max_mean_mat(l,:))
            hold on
            errorbar(1:numel(max_mean_mat(l,:)), max_mean_mat(l,:), max_var_mat(l,:), 'k.', 'LineWidth', 1)
    
            xticklabels(analysis_vec)
    
            xlabel('analysis type')
            ylabel('max normalized accuracy')
            title(['Comparison of analyses' num2str(l)])
            hold on
            plot(max_max_mat(l,:),'o')
        end

    end
end


