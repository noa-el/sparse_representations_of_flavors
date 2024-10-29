function correlation_mat_across_animals(data_path, params_folder, animals_names, parameters)
    colors = {'r','g','b','y'}; % Red, Green, Blue, Yellow, Magenta, Cyan

    win = {'start-(-1)','(-1)-2','2-5','5-end'};
    animals_db = get_animals_list(data_path, animals_names);
    across_animals_folder = fullfile(params_folder, 'across_animals');
    % folder datapath of the current functions' results
    corr_degree_across_animals_file = fullfile(across_animals_folder, ['corr_degree_across_animals']);

    % corr_degree_across_animals: sessions X neurons X time windows
    corr_degree_across_animals = [];
    for animal_i =1:length(animals_names)           
        % specific animals' analysis results folder 
        across_dates_folder = fullfile(params_folder, 'per_animal_across_dates',[animals_names{animal_i}]);
        if ~isfolder(across_dates_folder)
            mkdir(across_dates_folder);
        end

        % folder datapath of results that the current function uses
        resfile_corr_degree_order = fullfile(across_dates_folder, ['correlation_degree_order' animals_names{animal_i} '.mat']);
        % load the data
        load(resfile_corr_degree_order,"corr_degree_across_dates_order")
        
        % create corr_degree_across_animals by concatenating
        if(isempty(corr_degree_across_animals))
            corr_degree_across_animals = corr_degree_across_dates_order;
        else
            corr_degree_across_animals = cat(2,corr_degree_across_animals, corr_degree_across_dates_order);
        end
    end

    % dist_corr_degree_dates_across_animals: sessions X sessions X time windows
    dist_corr_degree_dates_across_animals = [];
    for animal_i =1:length(animals_names) 
        % specific animals' analysis results folder 
        across_dates_folder = fullfile(params_folder, 'per_animal_across_dates',[animals_names{animal_i}]);

        % folder datapath of results that the current function uses
        resfile_dist_corr_degree_dates = fullfile(across_dates_folder, ['dist_corr_degree_dates.mat']);
        % load the data
        load(resfile_dist_corr_degree_dates, 'dist_corr_degree_dates');

        % create dist_corr_degree_dates_across_animals by concatenating
        if(isempty(dist_corr_degree_dates_across_animals))
            dist_corr_degree_dates_across_animals = dist_corr_degree_dates;
        else
            dist_corr_degree_dates_across_animals = cat(4,dist_corr_degree_dates_across_animals,dist_corr_degree_dates);
        end
    end
    % mean over animals
    dist_corr_degree_dates_across_animals_mean = nanmean(dist_corr_degree_dates_across_animals, 4);
    dist_corr_degree_dates_across_animals_std = nanstd(dist_corr_degree_dates_across_animals,[], 4)/sqrt(size(dist_corr_degree_dates_across_animals,4)-1);

    for w = 1:4
        % take relevant correlation_degree values
        correlation_degree_per_w = corr_degree_across_animals(:,:,w);
        correlation_degree_im = correlation_degree_per_w';

        % sort by sessions one by one
        % the result will be sorted by the last sorted session
        % values that are equal in the last sorted session
        % will be sorted by the previous and so on
        for date_i = 1:size(correlation_degree_im,2)
            [B,sorted_ind] = sort(correlation_degree_im(:,date_i));
            correlation_degree_im = correlation_degree_im(sorted_ind,:);
        end
        % sort by ongoing batch sessions last
        for date_i = 1:size(correlation_degree_im,2)
            if(strcmp(parameters.type_vec_across_animals{date_i},'ongoing batch'))
                [B,sorted_ind] = sort(correlation_degree_im(:,date_i));
                correlation_degree_im = correlation_degree_im(sorted_ind,:);
            end
        end
    
        figure(400)
        subplot(1,4,w)

        % display correlation_degree_im: neurons X sessions
        % for every time window
        h = imagesc(correlation_degree_im);
        % NaN values will be white
        set(h, 'AlphaData', ~isnan(correlation_degree_im));

        % color limits 
        vals = corr_degree_across_animals(corr_degree_across_animals ~= 0);
        clim([min(vals(:)) max(vals(:))])
        colormap jet;
        colorbar;

        set(gca,'XTick',1:length(parameters.type_vec_across_animals));
        set(gca,'XTickLabel',[parameters.type_vec_across_animals], 'fontsize', 8);
        xtickangle(90)
        ylabel('neurons');

        title([win{w}]);
        sgtitle(['neurons correlation across animals']);


        figure(500);
        subplot(2,2,w);

        % take relevant dist_corr_degree_dates values
        dist_corr_degree_dates_across_animals_per_w = dist_corr_degree_dates_across_animals_mean(:,:,w);
        % diag values are zeros (distance between vector to itself)
        % turn to NaN for display  - will be white
        dist_corr_degree_dates_across_animals_per_w(eye(size(dist_corr_degree_dates_across_animals_per_w))==1) = nan;
        
        % display dist_corr_degree_dates_per_w: sessions X sessions
        % for every time window        
        p =  pcolor(([dist_corr_degree_dates_across_animals_per_w nan(size(dist_corr_degree_dates_across_animals_per_w,1),1); nan(1,size(dist_corr_degree_dates_across_animals_per_w,1)+1)]));
        % NaN value will be white
        p.EdgeColor=[1 1 1];

        % color limits 
        vals = dist_corr_degree_dates_across_animals_mean(dist_corr_degree_dates_across_animals_mean ~= 0);
        clim([min(vals(:)) max(vals(:))]);
        colormap jet;
        colorbar;

        set(gca,'XTick',1:length(parameters.type_vec_across_animals));
        set(gca,'XTickLabel',[parameters.type_vec_across_animals], 'fontsize', 8);
        xtickangle(90)
        set(gca,'YTick',1:length(parameters.type_vec_across_animals));
        set(gca,'YTickLabel',[parameters.type_vec_across_animals], 'fontsize', 8);

        title([win{w}]);
        sgtitle(['neurons correlation - distance between dates across animals']);

        figure(501)
        sgtitle(['neurons correlation - distance between dates across animals\newline distance from first train batch session']);
        subplot(2,2,w)
        shadedErrorBar(1:size(dist_corr_degree_dates_across_animals_mean,1)-1, dist_corr_degree_dates_across_animals_mean(2:end,1,w), dist_corr_degree_dates_across_animals_std(2:end,1,w),'lineprops',colors{w})
        title(win{w})
        set(gca,'XTick',1:length(parameters.type_vec_across_animals) -1);
        set(gca,'XTickLabel',[parameters.type_vec_across_animals(2:end)], 'fontsize', 8);
        xtickangle(90)


        hold on;

    end

    % save results
    save(corr_degree_across_animals_file,"corr_degree_across_animals")
end 