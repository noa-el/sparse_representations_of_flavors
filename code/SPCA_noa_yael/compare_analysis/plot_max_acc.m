function plot_max_acc(k, stop_vec, data_path, results_path, analysis_vec)
% NOT USED
    for stop_i = 1:length(stop_vec)
        max_vec = [];
        for analysis =analysis_vec
            % get trajectories from SPCA
            analysis_folder = fullfile(results_path, [analysis{1} '_results']);
            params_folder =  fullfile(analysis_folder, ['num_stop' num2str(abs(stop_vec(stop_i))) 'num_components' num2str(k)]);
            across_animal_folder = fullfile(params_folder, 'across_animals');
            resfile_max_acc = fullfile(across_animal_folder, 'max_acc.mat');

            if ~isfile(resfile_max_acc)
                continue;
            end
            load(resfile_max_acc, 'max_acc_vec')
            max_vec = [max_vec ; max_acc_vec];
        end


        max_mean = mean(max_vec,2);
        max_var = std(max_vec,[],2)/sqrt(size(max_vec,2)-1);
        max_max = max(max_vec');
        
        figure(70)
        bar(max_mean)
        hold on
        errorbar(1:numel(max_mean), max_mean, max_var, 'k.', 'LineWidth', 1)

        xticklabels(analysis_vec)

        xlabel('analysis type')
        ylabel('max normalized accuracy')
        title('Comparison of analyses')
        hold on
        plot(max_max,'o')
        

    end
end


