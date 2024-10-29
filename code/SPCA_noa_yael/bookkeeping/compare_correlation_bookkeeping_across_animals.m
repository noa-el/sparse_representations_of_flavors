function compare_correlation_bookkeeping_across_animals(data_path, params_folder, animals_names, parameters)

    animals_db = get_animals_list(data_path, animals_names);
    across_animals_folder = fullfile(params_folder, 'across_animals');

    % folder datapath of the current functions' results
    across_animals_spearman_file = fullfile(across_animals_folder, ['spearman.mat']);

    % spearman: time windows X questions X sessions
    spearman_across_animals = [];
    for animal_i =1:length(animals_names) 
        across_dates_folder = fullfile(params_folder, 'per_animal_across_dates',[animals_names{animal_i}]);

        % folder datapath of the current functions' results
        spearman_file = fullfile(across_dates_folder, ['spearman' animals_names{animal_i} '.mat']);
        % load the data
        load(spearman_file,'spearman');

        % create spearman_across_animals by concatenating
        if(isempty(spearman_across_animals))
            spearman_across_animals = spearman;
        else
            spearman_across_animals = cat(4,spearman_across_animals,spearman);
        end
    end
    % mean over animals
    spearman_across_animals = nanmean(spearman_across_animals, 4);

        
    for l = 1:parameters.Q
        figure(40);
        subplot(3,3,l)
        
        % display spearman: time windows X sessions
        % for every question
        imagedata = squeeze(spearman_across_animals(:,l,:));
        h = imagesc(imagedata);

        % NaN values will be white
        set(h, 'AlphaData', ~isnan(imagedata));

        % color limits 
        clim([min(spearman_across_animals(:)) max(spearman_across_animals(:))]);
        colormap jet;
        colorbar

        set(gca,'XTick',1:length(parameters.type_vec_across_animals));
        set(gca,'XTickLabel',[parameters.type_vec_across_animals], 'fontsize', 8);
        xtickangle(90)
        set(gca,'YTick',1:size(spearman_across_animals,1));
        set(gca,'YTickLabel',[parameters.time_parameters.win_str], 'fontsize', 8);

        title([write_question(parameters.labels, l)]);
        sgtitle('Spearman across animals');
    end

    % save results
    save(across_animals_spearman_file,'spearman');
end
