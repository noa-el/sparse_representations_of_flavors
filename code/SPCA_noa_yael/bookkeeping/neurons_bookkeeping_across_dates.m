function neurons_bookkeeping_across_dates(data_path, params_folder, animals_names,k,stop,parameters, to_plot)

    animals_db = get_animals_list(data_path, animals_names);

    for animal_i =1:length(animals_names)
        dates_list = animals_db{animal_i}.folder(animals_db{animal_i}.to_include == 2);            
        % specific animals' analysis results folder 
        animal_folder = fullfile(params_folder, 'per_animal_per_date',[animals_names{animal_i}]);
        across_dates_folder = fullfile(params_folder, 'per_animal_across_dates',[animals_names{animal_i}]);
        if ~isfolder(across_dates_folder)
            mkdir(across_dates_folder);
        end
        % folder datapath of the current functions' results
        neurons_recording_across_dates_file = fullfile(across_dates_folder, ['neurons_recording_across_dates']);
        neurons_recording_acc_values_across_dates_file = fullfile(across_dates_folder, ['neurons_recording_acc_values_across_dates']);
        neurons_recording_across_dates_order_file = fullfile(across_dates_folder, ['neurons_recording_across_dates_order']);
        neurons_recording_acc_values_across_dates_order_file = fullfile(across_dates_folder, ['neurons_recording_acc_values_across_dates_order']);

        type1_file = fullfile(across_dates_folder, ['type1']);
        type2_file = fullfile(across_dates_folder, ['type2']);
        type_file = fullfile(across_dates_folder, ['type']);
        order_file = fullfile(across_dates_folder, ['order']);

        hamming_file = fullfile(across_dates_folder, ['hamming.mat']);

        % neurons_recording_across_dates: time windows X questions X neurons X sessions
        % contain neurons_recording values across sessions
        % neurons_recording_acc_values_across_dates: time windows X questions X neurons X sessions
        % contain neurons_recording_acc_values_across_dates values across sessions
        % take all neurons recorded (600 is more than the amount), 
        % not recorded will first be NaN
        % then we will take only neurons that were recorded in all sessions
        neurons_recording_acc_values_across_dates = NaN(4,9,600,length(dates_list));
        neurons_recording_across_dates = NaN(4,9,600,length(dates_list));
        % type and order vectors: sessions, contain all sessions types
        % we will take only sessions that are not all NaN
        type2_vec = [];
        type1_vec = [];
        type_vec = [];
        order_vec = [];
        % loop over all experiments per animal
        for date_i = 1:length(dates_list)
            % specific dates' analysis results folder 
            date_folder = fullfile(animal_folder, [dates_list{date_i}]);
            % specific dates' original data folder
            curr_folder = fullfile(data_path, animals_names{animal_i}, dates_list{date_i});
            % specific dates' original data file
            data_file = fullfile(curr_folder, 'data.mat');
            % if folder doesn't exist create it
            if ~isfile(data_file)
                continue;
            end

            % folder datapath of results that the current function uses
            resfile_acc = fullfile(date_folder, ['acc' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
            resfile_neurons_recording = fullfile(date_folder, ['neurons_recording' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
            resfile_neurons_rec_acc_values = fullfile(date_folder, ['neurons_recording_acc_values' animals_names{animal_i} '_' dates_list{date_i} '.mat']);

            % WE CAN RUN THE RELEVANT FUNCTIONS IN THIS CASE INSTEAD
            if (~isfolder(animal_folder)) | ~isfolder(date_folder) | (~isfile(resfile_acc)) | (~isfile(resfile_neurons_recording)) | (~isfile(resfile_neurons_rec_acc_values))
                continue;
            end

            % load the data
            load(data_file, 'imagingData', 'BehaveData');
            load(resfile_acc,'acc')
            load(resfile_neurons_recording, "neurons_recording");
            load(resfile_neurons_rec_acc_values, "neurons_recording_acc_values");

            % type and order vectors: sessions, contain all sessions types
            type2_vec = [type2_vec animals_db{animal_i}.type2(date_i)];
            type1_vec = [type1_vec animals_db{animal_i}.type1(date_i)];
            type_vec = [type_vec {[type1_vec{date_i} ' ' type2_vec{date_i}]}];
            order_vec = [order_vec animals_db{animal_i}.order(date_i)];


            % neurons_recording_acc_values_across_dates: time windows X questions X neurons X sessions
            % contain neurons_recording_acc_values_across_dates values across sessions
            neurons_recording_acc_values_across_dates(:,:,imagingData.roiNames(:,1),date_i) = neurons_recording_acc_values;
            % neurons_recording_across_dates: time windows X questions X neurons X sessions
            % contain neurons_recording values across sessions
            neurons_recording_across_dates(:,:,imagingData.roiNames(:,1),date_i) = neurons_recording;

        end

        % take only sessions that are not all NaN
        type1_vec(all(isnan(neurons_recording_across_dates),[1,2,3])) = [];
        type2_vec(all(isnan(neurons_recording_across_dates),[1,2,3])) = [];
        type_vec(all(isnan(neurons_recording_across_dates),[1,2,3])) = [];
        order_vec(all(isnan(neurons_recording_across_dates),[1,2,3])) = [];

        % take only sessions that are not all NaN
        neurons_recording_across_dates(:,:,:,all(isnan(neurons_recording_across_dates),[1,2,3])) = [];
        % then we will take only neurons that were recorded in all sessions
        neurons_recording_across_dates(:,:,any(isnan(neurons_recording_across_dates(:,1,:,:)),[1,2,4]), :) = [];        

        % take only sessions that are not all NaN
        neurons_recording_acc_values_across_dates(:,:,:,all(isnan(neurons_recording_acc_values_across_dates),[1,2,3])) = [];
        % take only neurons that were recorded in all sessions
        neurons_recording_acc_values_across_dates(:,:,any(isnan(neurons_recording_acc_values_across_dates(:,1,:,:)),[1,2,4]), :) = [];     

        % neurons_recording_across_dates_order: time windows X questions X neurons X sessions
        % neurons_recording_acc_values_across_dates_order: time windows X questions X neurons X sessions
        % order neurons_recording_across_dates by the order of dates so
        % there will be 7 dates of the same types for any animal
        % not all animals have all 7 types of sessions
        % in the case of a missing session, we take NaN
        neurons_recording_across_dates_order = NaN(size(neurons_recording_across_dates,1),size(neurons_recording_across_dates,2),size(neurons_recording_across_dates,3),7);
        neurons_recording_acc_values_across_dates_order =  NaN(size(neurons_recording_acc_values_across_dates,1),size(neurons_recording_acc_values_across_dates,2),size(neurons_recording_acc_values_across_dates,3),7);
        for o = 1:parameters.S
            for order_vec_ind = 1:length(order_vec)
                if(order_vec(order_vec_ind) == o)
                    neurons_recording_across_dates_order(:,:,:,o) = neurons_recording_across_dates(:,:,:,order_vec_ind);
                    neurons_recording_acc_values_across_dates_order(:,:,:,o) = neurons_recording_acc_values_across_dates(:,:,:,order_vec_ind);
                end
            end
        end

        % plot neurons coding - neurons_recording values
        % for every time window for every question
        if to_plot
            for w = 1:parameters.W
                l_mat = [[1 2 3];[4 5 6];[7 8 9]];
                for l_group_ind = 1:size(l_mat,1)
                    figure(200 + l_group_ind * 10 + animal_i)
                    l_group =l_mat(l_group_ind,:);
                    for l_num_ind = 1:length(l_group)
                        % neurons_recording_across_dates_im: neurons X sessions
                        % for every time window and every question
                        % contains neurons_recording_across_dates_im 
                        neurons_recording_across_dates_im = squeeze(neurons_recording_across_dates_order(w,l_group(l_num_ind),:,:));
                        % sort by sessions one by one
                        % the result will be sorted by the last sorted session
                        % values that are equal in the last sorted session
                        % will be sorted by the previous and so on
                        for date_i = 1:size(neurons_recording_across_dates_im,2)
                            [B,sorted_ind] = sort(neurons_recording_across_dates_im(:,date_i));
                            neurons_recording_across_dates_im = neurons_recording_across_dates_im(sorted_ind,:);
                        end
                        % sort by ongoing batch sessions last
                        for date_i = 1:size(neurons_recording_across_dates_im,2)
                            if(strcmp(parameters.type_vec_across_animals{date_i},'ongoing batch'))
                                [B,sorted_ind] = sort(neurons_recording_across_dates_im(:,date_i));
                                neurons_recording_across_dates_im = neurons_recording_across_dates_im(sorted_ind,:);
                            end
                        end
                        % for display NaN values will be 0.5 so that they
                        % will be gray
                        neurons_recording_across_dates_im(isnan(neurons_recording_across_dates_im)) = 0.5;
    
                        % display neurons_recording_across_dates_im: neurons X sessions
                        % for every time window and every question
                        subplot(size(l_mat,2),size(neurons_recording_across_dates_order,1),(l_num_ind - 1)* size(neurons_recording_across_dates_order,1)+ w);
                        imagesc(neurons_recording_across_dates_im);
    
                        colormap(gray);
                        colorbar;
                        clim([0 1]);
    
                        set(gca,'XTick',1:length(parameters.type_vec_across_animals));
                        set(gca,'XTickLabel',[parameters.type_vec_across_animals], 'fontsize', 8);
                        xtickangle(90);
                        ylabel('neurons');
    
                        title([acc.labels{l_group(l_num_ind)},'\newline',parameters.time_parameters.win_str{w}]);
                        sgtitle(['neurons bookkeeping ' animals_names{animal_i}]);
                    end
                end
            end
        end % if to_plot

 
        % hamming_mat: sessions X sessions X questions X time windows
        % for any question and time window contain a hamming distance
        % matrix between sessions neurons_recording (does the neuron encode the question in the time window?)
        % long distance means different neurons encoding
        l_mat = [1 2 3; 4 5 6; 7 8 9];
        hamming_mat = [];
        for w = 1:parameters.W
            hamming_mat_per_w = [];
            for l_group_ind = 1:size(l_mat,1)
                l_group =l_mat(l_group_ind,:);
                for l_num_ind = 1:length(l_group)
                    % take relevant neurons_recording values
                    x = squeeze(neurons_recording_across_dates_order(w,l_group(l_num_ind),:,:));
                    % create hamming mat per time window per question
                    hamming_mat_per_w_per_l = squareform(pdist(x','hamming'));
                    % concatenate hamming_mat of different questions
                    if(isempty(hamming_mat_per_w))
                        hamming_mat_per_w = hamming_mat_per_w_per_l;
                    else
                        hamming_mat_per_w = cat(3,hamming_mat_per_w,hamming_mat_per_w_per_l);
                    end
                end
            end
            % concatenate hamming_mat of different time windows
            if(isempty(hamming_mat))
                hamming_mat = hamming_mat_per_w;
            else
                hamming_mat = cat(4,hamming_mat,hamming_mat_per_w);
            end
        end

        % plot hamming_mat hamming distance between sessions
        % for any question and time window
        if to_plot
            for w = 1:parameters.W
                l_mat = [[1 2 3];[4 5 6];[7 8 9]];
                for l_group_ind = 1:size(l_mat,1)
                    figure(300 + l_group_ind * 10 + animal_i)
                    l_group =l_mat(l_group_ind,:);
                    for l_num_ind = 1:length(l_group)
                        % take relevant hamming_mat values
                        hamming_mat_per_w_per_l = hamming_mat(:,:,l_group(l_num_ind),w);
                        % diag values are zeros (distance between vector to itself)
                        % turn to NaN for display  - will be white
                        hamming_mat_per_w_per_l(eye(size(hamming_mat_per_w_per_l))==1) = nan;

                        % display hamming_mat_per_w_per_l: sessions X sessions
                        % for every time window and every question
                        subplot(size(l_mat,2),size(neurons_recording_across_dates_order,1),(l_num_ind - 1)* size(neurons_recording_across_dates_order,1)+ w);
                        p =  pcolor(([hamming_mat_per_w_per_l nan(size(hamming_mat_per_w_per_l,1),1); nan(1,size(hamming_mat_per_w_per_l,1)+1)]));
                        % NaN value will be white
                        p.EdgeColor=[1 1 1];
                        % color limits
                        vals = hamming_mat(hamming_mat ~= 0);
                        clim([min(vals(:)) max(vals(:))]);
                        colormap jet;
                        colorbar

                        set(gca,'XTick',1:length(parameters.type_vec_across_animals));
                        set(gca,'XTickLabel',[parameters.type_vec_across_animals], 'fontsize', 8);
                        xtickangle(90)
                        set(gca,'YTick',1:length(parameters.type_vec_across_animals));
                        set(gca,'YTickLabel',[parameters.type_vec_across_animals], 'fontsize', 8);


                        title([acc.labels{l_group(l_num_ind)},'\newline',parameters.time_parameters.win_str{w}]);
                        sgtitle(['hamming ' animals_names{animal_i}]);
                        
                        % save figure
                        fig_file = fullfile(across_dates_folder, ['neurons_bookkeeping_fig' num2str(200 + l_group_ind * 10 + animal_i) '.fig']);
                        saveas(gcf, fig_file)
    
                    end
                end
            end
        end % if to_plot

        % save results
        save(neurons_recording_across_dates_file,"neurons_recording_across_dates")
        save(neurons_recording_acc_values_across_dates_file,"neurons_recording_acc_values_across_dates")
        save(neurons_recording_across_dates_order_file,"neurons_recording_across_dates_order")
        save(neurons_recording_acc_values_across_dates_order_file,"neurons_recording_acc_values_across_dates_order")

        save(type1_file,"type1_vec")
        save(type2_file,"type2_vec")
        save(type_file,"type_vec")
        save(order_file,"order_vec")

        save(hamming_file,"hamming_mat")

    end
end 