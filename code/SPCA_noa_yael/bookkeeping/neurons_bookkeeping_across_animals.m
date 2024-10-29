function neurons_bookkeeping_across_animals(data_path, params_folder, animals_names,k,stop,parameters)

    animals_db = get_animals_list(data_path, animals_names);

    neurons_recording_across_animals = [];
    neurons_recording_acc_values_across_animals = [];

    across_animals_folder = fullfile(params_folder, 'across_animals');
    % folder datapath of the current functions' results
    neurons_recording_across_animals_file = fullfile(across_animals_folder, ['neurons_recording_across_animals']);
    neurons_recording_acc_values_across_animals_file = fullfile(across_animals_folder, ['neurons_recording_acc_values_across_animals']);
    across_animals_hamming_file = fullfile(across_animals_folder, ['hamming.mat']);

    for animal_i =1:length(animals_names)           
        % specific animals' analysis results folder 
        across_dates_folder = fullfile(params_folder, 'per_animal_across_dates',[animals_names{animal_i}]);
        if ~isfolder(across_dates_folder)
            mkdir(across_dates_folder);
        end

        % folder datapath of results that the current function uses
        neurons_recording_across_dates_order_file = fullfile(across_dates_folder, ['neurons_recording_across_dates_order']);
        neurons_recording_acc_values_across_dates_order_file = fullfile(across_dates_folder, ['neurons_recording_acc_values_across_dates_order']);

        % load the data
        load(neurons_recording_across_dates_order_file,"neurons_recording_across_dates_order")
        load(neurons_recording_acc_values_across_dates_order_file,"neurons_recording_acc_values_across_dates_order")

        % create neurons_recording_across_animals by concatenating
        if(isempty(neurons_recording_across_animals))
            neurons_recording_across_animals = neurons_recording_across_dates_order;
        else
            neurons_recording_across_animals = cat(3,neurons_recording_across_animals, neurons_recording_across_dates_order);
        end
        % create neurons_recording_acc_values_across_animals by concatenating
        if(isempty(neurons_recording_acc_values_across_animals))
            neurons_recording_acc_values_across_animals = neurons_recording_acc_values_across_dates_order;
        else
            neurons_recording_acc_values_across_animals = cat(3,neurons_recording_acc_values_across_animals, neurons_recording_acc_values_across_dates_order);
        end
    end

    hamming_mat_across_animals = [];
    for animal_i =1:length(animals_names) 
        across_dates_folder = fullfile(params_folder, 'per_animal_across_dates',[animals_names{animal_i}]);
        % folder datapath of results that the current function uses
        hamming_file = fullfile(across_dates_folder, ['hamming.mat']);
        load(hamming_file,"hamming_mat")
        if(isempty(hamming_mat_across_animals))
            hamming_mat_across_animals = hamming_mat;
        else
            hamming_mat_across_animals = cat(5,hamming_mat_across_animals,hamming_mat);
        end
    end
    hamming_mat_across_animals_mean = nanmean(hamming_mat_across_animals, 5);
    hamming_mat_across_animals_std = nanstd(hamming_mat_across_animals,[], 5)/sqrt(size(hamming_mat_across_animals,5)-1);
    hamming_mat_across_animals = hamming_mat_across_animals_mean;

    % plot neurons coding - neurons_recording values
    % for every time window for every question
    for w = 1:size(neurons_recording_across_animals,1)
        l_mat = [[1 2 3];[4 5 6];[7 8 9]];
        for l_group_ind = 1:size(l_mat,1)
            figure(200 + l_group_ind * 10)
            l_group =l_mat(l_group_ind,:);
            for l_num_ind = 1:length(l_group)
                % neurons_recording_across_dates_im: neurons X sessions
                % for every time window and every question
                % contains neurons_recording_across_dates_im                 
                neurons_recording_across_dates_im = squeeze(neurons_recording_across_animals(w,l_group(l_num_ind),:,:));
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
                subplot(size(l_mat,2),size(neurons_recording_across_animals,1),(l_num_ind - 1)* size(neurons_recording_across_animals,1)+ w)
                imagesc(neurons_recording_across_dates_im);

                colormap(gray)
                colorbar
                clim([0 1])

                set(gca,'XTick',1:length(parameters.type_vec_across_animals));
                set(gca,'XTickLabel',[parameters.type_vec_across_animals], 'fontsize', 8);
                xtickangle(90)
                win = {'start-(-1)','(-1)-2','2-5','5-end'};
                ylabel('neurons')

                title([write_question(parameters.labels, l_group(l_num_ind)),'\newline',win{w}]);
                sgtitle('neurons bookkeeping across animals')
            end
        end


        % plot hamming_mat hamming distance between sessions
        % for any question and time window
        for l_group_ind = 1:size(l_mat,1)
            figure(300 + l_group_ind * 10)
            l_group =l_mat(l_group_ind,:);
            for l_num_ind = 1:length(l_group)
                % take relevant hamming_mat values
                hamming_mat_per_w_per_l = hamming_mat_across_animals(:,:,l_group(l_num_ind),w);
                % diag values are zeros (distance between vector to itself)
                % turn to NaN for display  - will be white
                hamming_mat_per_w_per_l(eye(size(hamming_mat_per_w_per_l))==1) = nan;

                % display hamming_mat_per_w_per_l: sessions X sessions
                % for every time window and every question 
                subplot(size(l_mat,2),size(neurons_recording_across_animals,1),(l_num_ind - 1)* size(neurons_recording_across_animals,1)+ w);
                p =  pcolor(([hamming_mat_per_w_per_l nan(size(hamming_mat_per_w_per_l,1),1); nan(1,size(hamming_mat_per_w_per_l,1)+1)]));
                % NaN value will be white
                p.EdgeColor=[1 1 1];
                
                % color limits
                vals = hamming_mat_across_animals(hamming_mat_across_animals ~= 0);
                clim([min(vals(:)) max(vals(:))]);
                colormap jet;
                colorbar;

                set(gca,'XTick',1:length(parameters.type_vec_across_animals));
                set(gca,'XTickLabel',[parameters.type_vec_across_animals], 'fontsize', 8);
                xtickangle(90)
                set(gca,'YTick',1:length(parameters.type_vec_across_animals));
                set(gca,'YTickLabel',[parameters.type_vec_across_animals], 'fontsize', 8);
                win = {'start-(-1)','(-1)-2','2-5','5-end'};

                title([write_question(parameters.labels, l_group(l_num_ind)),'\newline',win{w}]);
                sgtitle(['hamming across animals']);
                % save figure
                fig_file = fullfile(across_animals_folder, ['neurons_bookkeeping_fig' num2str(200 + l_group_ind * 10 + animal_i) '.fig']);
                saveas(gcf, fig_file);
            end
        end
    end

    figure(340)
    hold on;
    title(['hamming distance between dates across animals\newline distance from first train batch session\newlinefailure vs success failure']);
    shadedErrorBar(1:size(hamming_mat_across_animals,1)-1, hamming_mat_across_animals(2:end,1,1,1), hamming_mat_across_animals_std(2:end,1,1,1),'lineprops','r');
    shadedErrorBar(1:size(hamming_mat_across_animals,1)-1, hamming_mat_across_animals(2:end,1,1,3), hamming_mat_across_animals_std(2:end,1,1,3),'lineprops','b');
    %legend(win{w})
    set(gca,'XTick',1:length(parameters.type_vec_across_animals) -1);
    set(gca,'XTickLabel',[parameters.type_vec_across_animals(2:end)], 'fontsize', 8);
    xtickangle(90)
    c=get(gcf, 'Children');
    c = get(c,'Children');
    legend(c(end:-4:1),'start-(-1)','2-5');


    figure(350)
    title(['hamming distance between dates across animals\newline distance from first batch session\newlinequinines vs  sucroses grains regulars']);
    shadedErrorBar(1:size(hamming_mat_across_animals,1)-3, hamming_mat_across_animals(4:end,3,6,3), hamming_mat_across_animals_std(4:end,3,6,3),'lineprops','b');
    %legend(win{w})
    set(gca,'XTick',1:length(parameters.type_vec_across_animals) -3);
    set(gca,'XTickLabel',[parameters.type_vec_across_animals(4:end)], 'fontsize', 8);
    xtickangle(90)

    figure(360)
    title(['hamming distance between dates across animals\newline distance from first batch session\newlinegrains regulars vs quinines vs sucroses']);
    shadedErrorBar(1:size(hamming_mat_across_animals,1)-3, hamming_mat_across_animals(4:end,3,8,3), hamming_mat_across_animals_std(4:end,3,8,3),'lineprops','b');
    %legend(win{w})
    set(gca,'XTick',1:length(parameters.type_vec_across_animals) -3);
    set(gca,'XTickLabel',[parameters.type_vec_across_animals(4:end)], 'fontsize', 8);
    xtickangle(90)

    % save results
    save(neurons_recording_across_animals_file,"neurons_recording_across_animals")
    save(neurons_recording_acc_values_across_animals_file,"neurons_recording_acc_values_across_animals")
    save(across_animals_hamming_file,"hamming_mat_across_animals")
    
end 