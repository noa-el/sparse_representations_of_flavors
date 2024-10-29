function correlation_mat(data_path, params_folder, animals_names, parameters, to_plot)
    win = {'start-(-1)','(-1)-2','2-5','5-end'};
    animals_db = get_animals_list(data_path, animals_names);
    tone_time = 4;
    f_sample = 30;
    first_sec_ind = 1 + f_sample;
    t = (0:f_sample*12-1)/f_sample - tone_time;
    t = t(first_sec_ind:end);
    
    % loop over all animals
    for animal_i =1:length(animals_names)
        dates_list = animals_db{animal_i}.folder(animals_db{animal_i}.to_include == 2);            
        % specific animals' analysis results folder 
        animal_folder = fullfile(params_folder, 'per_animal_per_date',[animals_names{animal_i}]);
        across_dates_folder = fullfile(params_folder, 'per_animal_across_dates',[animals_names{animal_i}]);
        if ~isfolder(across_dates_folder)
            mkdir(across_dates_folder);
        end

        % folder datapath of results that the current function uses
        type1_file = fullfile(across_dates_folder, ['type1']);
        type2_file = fullfile(across_dates_folder, ['type2']);
        type_file = fullfile(across_dates_folder, ['type']);
        order_file = fullfile(across_dates_folder, ['order']);

        % folder datapath of the current functions' results
        resfile_dist_corr_degree_dates = fullfile(across_dates_folder, ['dist_corr_degree_dates.mat']);
        resfile_corr_degree = fullfile(across_dates_folder, ['correlation_degree' animals_names{animal_i} '.mat']);
        resfile_corr_degree_order = fullfile(across_dates_folder, ['correlation_degree_order' animals_names{animal_i} '.mat']);
    
        % load the data
        load(type1_file,'type1_vec');
        load(type2_file,'type2_vec');
        load(type_file,'type_vec');
        load(order_file,'order_vec');

        % correlation_degree: sessions X neurons X time windows
        correlation_degree = NaN(length(dates_list),600, 4);
        % loop over all experiments per animal
        for date_i = 1:length(dates_list)
            % specific dates' analysis results folder 
            date_folder = fullfile(animal_folder, [dates_list{date_i}]);
    
            % specific dates' original data folder
            curr_folder = fullfile(data_path, animals_names{animal_i}, dates_list{date_i});
            % specific dates' original data file
            data_file = fullfile(curr_folder, 'data.mat');
          
            % NO CODE FOR THE CASE RESULTS ALREADY EXIST - WILL RUN ANALYSIS ANYWAY
          
            % if it does not exist, do not run the loop on this part of
            % the data
            if (~isfolder(animal_folder) | ~isfolder(date_folder)) 
                continue;
            end
    
             % load the data
            load(data_file, 'imagingData', 'BehaveData');
           
            win_st_sec = [t(1),-1,2,5];
            win_end_sec = [-1,2,5,t(end)];

            % ANALYSIS STARTS HERE
            for w = 1:length(win_st_sec)
                % reorganize the time window samples into a matrix of 
                % data_mat: neurons X (time*trials)
                for k = 1:size(imagingData.samples,1)
                    data_mat(:, k) = reshape(imagingData.samples(k,t >= win_st_sec(w) & t <= win_end_sec(w),:), ...
                        [],1);
                end
                % correlation_mat: neurons X neurons
                % calculate correlation_mat
                correlation_mat = corr(data_mat);
                % calculate correlation_degree
                correlation_vec = mean(correlation_mat,1);
                correlation_degree(date_i,imagingData.roiNames(:,1),w) = correlation_vec;
                clear data_mat;
            end
        end

        % take only sessions that are not all NaN
        all_nan = all(isnan(correlation_degree),2);
        correlation_degree(squeeze(all_nan(:,1,1)),:,:) = [];
        % then we will take only neurons that were recorded in all sessions
        any_nan = any(isnan(correlation_degree),1);
        correlation_degree(:,squeeze(any_nan(1,:,1)),:) = [];

        % corr_degree_across_dates_order: sessions X neurons X time windows
        % order corr_degree_across_dates by the order of dates so
        % there will be 7 dates of the same types for any animal
        % not all animals have all 7 types of sessions
        % in the case of a missing session, we take NaN
        corr_degree_across_dates_order = NaN(7,size(correlation_degree,2),size(correlation_degree,3));
        for o = 1:parameters.S
            for order_vec_ind = 1:length(order_vec)
                if(order_vec(order_vec_ind) == o)
                    corr_degree_across_dates_order(o,:,:) = correlation_degree(order_vec_ind,:,:);
                end
            end
        end

        % dist_corr_degree_dates: sessions X sessions X time windows
        % euclidian distance between sessions degree vectors
        % for every time window
        dist_corr_degree_dates = [];
        for w = 1:length(win_st_sec)
            % take relevant correlation_degree values
            correlation_degree_per_w = corr_degree_across_dates_order(:,:,w);
            % calculate dist_corr_degree_dates
            % euclidian distance between sessions degree vectors
            % one number for each dist between two dates
            dist_corr_degree_dates_per_w = dist(correlation_degree_per_w');   
            % concatenate dist_corr_degree of the different time windows
            if(isempty(dist_corr_degree_dates))
                dist_corr_degree_dates = dist_corr_degree_dates_per_w;
            else
                dist_corr_degree_dates = cat(3,dist_corr_degree_dates,dist_corr_degree_dates_per_w);
            end
        end

        if to_plot
            for w = 1:length(win_st_sec)
                % take relevant correlation_degree values
                correlation_degree_per_w = corr_degree_across_dates_order(:,:,w);
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

                figure(400 + animal_i * 10)
                subplot(1,4,w)

                % display correlation_degree_im: neurons X sessions
                % for every time window
                h = imagesc(correlation_degree_im);
                % NaN values will be white
                set(h, 'AlphaData', ~isnan(correlation_degree_im));

                % color limits 
                vals = corr_degree_across_dates_order(corr_degree_across_dates_order ~= 0);
                clim([min(vals(:)) max(vals(:))]);
                colormap jet;
                colorbar;

                set(gca,'XTick',1:length(parameters.type_vec_across_animals));
                set(gca,'XTickLabel',[parameters.type_vec_across_animals], 'fontsize', 8);
                xtickangle(90)
                ylabel('neurons');

                title([win{w}]);
                sgtitle(['correlation degree ' animals_names{animal_i}]);
            

                figure(500 + animal_i * 10);
                subplot(2,2,w)
                % take relevant dist_corr_degree_dates values
                dist_corr_degree_dates_per_w = dist_corr_degree_dates(:,:,w);

                % diag values are zeros (distance between vector to itself)
                % turn to NaN for display  - will be white
                dist_corr_degree_dates_per_w(eye(size(dist_corr_degree_dates_per_w))==1) = nan;

                % display dist_corr_degree_dates_per_w: sessions X sessions
                % for every time window
                p =  pcolor(([dist_corr_degree_dates_per_w nan(size(dist_corr_degree_dates_per_w,1),1); nan(1,size(dist_corr_degree_dates_per_w,1)+1)]));
                % NaN value will be white
                p.EdgeColor=[1 1 1];

                % color limits 
                vals = dist_corr_degree_dates(dist_corr_degree_dates ~= 0);
                clim([min(vals(:)) max(vals(:))]);
                colormap jet;
                colorbar;

                set(gca,'XTick',1:length(parameters.type_vec_across_animals));
                set(gca,'XTickLabel',[parameters.type_vec_across_animals], 'fontsize', 8);
                xtickangle(90)
                set(gca,'YTick',1:length(parameters.type_vec_across_animals));
                set(gca,'YTickLabel',[parameters.type_vec_across_animals], 'fontsize', 8);

                title([win{w}]);
                sgtitle(['neurons correlation - distance between dates ' animals_names{animal_i}]);
            end
        end

        % save results
        save(resfile_dist_corr_degree_dates, 'dist_corr_degree_dates');
        save(resfile_corr_degree, 'correlation_degree');
        save(resfile_corr_degree_order,"corr_degree_across_dates_order")
        
    end
end