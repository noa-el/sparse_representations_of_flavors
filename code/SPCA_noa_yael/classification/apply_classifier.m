function  apply_classifier(data_path, params_folder, animals_names,k,stop, parameters, classification_flags,to_plot)

    animals_db = get_animals_list(data_path, animals_names);
    addpath(genpath('SpcaSM'));
    addpath(genpath('pca'));
    
    % plot_colors = 'rygk'; % matching the labels - red for failure, yellow for sucroses, etc
    
    % parameters for scpa
    params.K = k; % how many components we want to extract
    params.stop= -stop; % controls how many cells will be selected
    
    % params for svm
    params.sliding_win_len = 1;
    params.sliding_win_hop = 0.5;
    params.folds_num = 5;
    params.to_norm = 1;
    
    
    % loop over all animals
    for animal_i = 1:length(animals_names)
        % DISPLAY ANIMALS NAME
        disp(animals_names{animal_i});
    
        % specific animals' analysis results folder 
        animal_folder = fullfile(params_folder, 'per_animal_per_date',[animals_names{animal_i}]);
    
        % if folder doesn't exist create it
        if ~isfolder(animal_folder)
            mkdir(animal_folder);
        end
    
        % loop over all experiments per animal
        dates_list = animals_db{animal_i}.folder(animals_db{animal_i}.to_include == 2);            
    
        for date_i = 1:length(dates_list)
            % DISPLAY DATE
            disp(dates_list{date_i});
            % specific dates' original data folder
            curr_folder = fullfile(data_path, animals_names{animal_i}, dates_list{date_i});
            % specific dates' original data file
            data_file = fullfile(curr_folder, 'data.mat');
    
            % if datafile doesn't exists then skip it
            if ~isfile(data_file)
                continue;
            end
    
            % specific dates' analysis results folder 
            date_folder = fullfile(animal_folder, [dates_list{date_i}]);
    
            % if folder doesn't exist create it
            if ~isfolder(date_folder)
                mkdir(date_folder);
            end
    
            % folder datapath of results that the current function uses
            resfile_traj = fullfile(date_folder, ['spca_trajectories_' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
            % analysis results files 
            resfile_acc = fullfile(date_folder, ['acc' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
    
            
            % if resfile already exists then skip it
            if isfile(resfile_acc)
                continue;
            end
            % resfile does not exist, we apply the analysis
    
            % in case the data that the current function uses does not exist,
            % run the relevant fuction
            if (~isfolder(animal_folder) | ~isfolder(date_folder) | ~isfile(resfile_traj))
                apply_spca(data_path, params_folder, animals_names(animal_i),k,stop);
            end
    
            % if it still does not exist, do not run the loop on this part of
            % the data
            if (~isfolder(animal_folder) | ~isfolder(date_folder) | ~isfile(resfile_traj))
                continue;
            end
    
            % load the data
            load(data_file, 'imagingData', 'BehaveData');
            load(resfile_traj,'spca_traj_res')
    
    
            % BEGINING OF ANALYSIS
    
            labels2cluster = create_labels(parameters.labels, imagingData, BehaveData, parameters.multi_flag_vec);
    
            % classifier per time windows
            % get time windows
            %[winstSec, winendSec] = getFixedWinsFine(round(t(end)), params.slidingWinLen, params.slidingWinHop);
            if classification_flags.win_flag
                win_st_sec = parameters.time_parameters.win_st_sec;
                win_end_sec = parameters.time_parameters.win_end_sec;
            else
                win_st_sec = [parameters.time_parameters.t(1)];
                win_end_sec = [parameters.time_parameters.t(end)];
            end
    
            if (classification_flags.all_data_to_classifier)
                data2classify = imagingData.samples;
            else
                data2classify = spca_traj_res.projeff;
            end
    
    
    
            % loop per label vs the rest
            for l = 1:parameters.Q
                % create the name of the question
                acc.labels{l} = write_question(parameters.labels, l);
                acc.wind_mid = (win_st_sec + win_end_sec)/2;
                % get the label of each trial
                labels2classify = labels2cluster(:, l);
                multi_flag = parameters.multi_flag_vec(l);
                if isnan(sum(labels2classify))
                    for k = 1:params.K
                        % labels are NaN, no classification
                        acc.mean(:, l, k) = NaN(length(win_st_sec),1,1) ;
                    end
                    acc.chance(l) = NaN;
                else
                    
                    % create the name of the question
    
                    X = data2classify(:, :, labels2classify~=0);
                    Y = labels2classify(labels2classify~=0) - 1;
    
                    if multi_flag
                        acc.chance(l) = max(sum(Y==1)/length(Y),sum(Y==2)/length(Y));
                        acc.chance(l) = max(acc.chance(l), sum(Y==0)/length(Y));
                    else
                        acc.chance(l) = sum(Y==1)/length(Y);
                        acc.chance(l) = max(acc.chance(l), 1-acc.chance(l));
                    end 
    
                    % loop over each component
                    if classification_flags.components_flag
                        for k = 1:params.K
                            acc_res = sliding_classifier(X(k, :, :), Y, win_st_sec, win_end_sec, parameters.time_parameters.t, params.folds_num, params.to_norm, classification_flags, multi_flag);
                            acc.mean(:, l, k) = acc_res.mean;
                            % permutations
                            for i=1:100
                                perm_ind = randperm(length(Y));
                                perm_new_labels = Y(perm_ind);
                                acc_perm_res = sliding_classifier(X(k, :, :), perm_new_labels, win_st_sec, win_end_sec, parameters.time_parameters.t, params.folds_num, params.to_norm, classification_flags, multi_flag);
                                acc_perm.mean(:, l, k, i) = acc_perm_res.mean; % the second component is 1 so for any question there will be new acc_perm.mean
                            end 
                            for w = 1:size(acc_perm.mean,1)
                                alpha = 0.01;
                                acc_perm.x_n = mean(squeeze(acc_perm.mean(w,l,k,:)));
                                acc_perm.s = std(squeeze(acc_perm.mean(w,l,k,:)));
                                acc_perm.n = length(acc_perm.mean(w,l,k,:));
                                t_cr = tinv(1-alpha, acc_perm.n-1);
                                acc_cr = acc_perm.x_n + t_cr*(acc_perm.s/sqrt(acc_perm.n));
                                acc_cr3sigma = acc_perm.x_n + 3 * acc_perm.s;
                                acc_cr2sigma = acc_perm.x_n + 2 * acc_perm.s;
                                acc_cr2_5sigma = acc_perm.x_n + 2.5 * acc_perm.s;
                                % [acc.t_test(w, l, k),~,~,stats] = ttest(squeeze(acc_perm.mean(w,1,k,:)),acc.mean(w, l, k),"Tail","right");
    
                                if (acc.mean(w, l, k) > acc_cr) && (acc.mean(w, l, k) > acc.chance(l))
                                    acc.t_test(w, l, k) = 1;
                                else
                                    acc.t_test(w, l, k) = 0;
                                end 
                                if (acc.mean(w, l, k) > acc_cr3sigma) && (acc.mean(w, l, k) > acc.chance(l))
                                    acc.sigma3(w, l, k) = 1;
                                else
                                    acc.sigma3(w, l, k) = 0;
                                end 
                                if (acc.mean(w, l, k) > acc_cr2sigma) && (acc.mean(w, l, k) > acc.chance(l))
                                    acc.sigma2(w, l, k) = 1;
                                else
                                    acc.sigma2(w, l, k) = 0;
                                end 
    
                                if (acc.mean(w, l, k) > acc_cr2_5sigma) && (acc.mean(w, l, k) > acc.chance(l))
                                    acc.sigma2_5(w, l, k) = 1;
                                else
                                    acc.sigma2_5(w, l, k) = 0;
                                end 

                                if to_plot
                                    figure(1000 + date_i*100 + l*10 + k);
                                    sgtitle([animals_names{animal_i} ' ' replace(dates_list{date_i},'_','.') ' component ' num2str(k) '\newline ' write_question(parameters.labels, l)])
                                    subplot(2,2,w);
                                    histogram(squeeze(acc_perm.mean(w,l,k,:)),10);
                                    hold on
                                    plot(acc.mean(w, l, k),0,'*');
                                    plot(acc_cr,0,'*');
                                    plot(acc.chance(l),0,'*');
                                    plot(acc_res.empiric_chance(w),0,'*');
                                    legend('Histogram of Permuted Means', 'Accuracy', 'Critical Accuracy', 'Chance Level','empiric chance');
                                    title(['acc cr: ' num2str(acc_cr) ' acc val: ' num2str(acc.mean(w, l, k)) '\newlinedecision: ' num2str(acc.t_test(w, l, k))])
                                    xlabel('accuracy')
                                    ylabel('amount')
                                    fig_file = fullfile(date_folder, ['t_test' num2str(1000 +date_i*100 + l*10 + k) '.fig']);
                                    saveas(gcf, fig_file)
                                end 
                            end
                        end
                    else
                        acc_res = sliding_classifier(X, Y, win_st_sec, win_end_sec, parameters.time_parameters.t, params.folds_num, params.to_norm, classification_flags, multi_flag);
                        acc.mean(:, l, 1) = acc_res.mean;
                        % for i=1:50
                        %     perm_ind = randperm(length(Y));
                        %     perm_new_labels = labels2classify(perm_ind);
                        %     acc_perm_res = sliding_classifier(X, Y, win_st_sec, win_end_sec, parameters.time_parameters.t, params.folds_num, params.to_norm, classification_flags, multi_flag);
                        %     acc_perm.mean(:, 1, i) = acc_perm_res.mean; % the second component is 1 so for any question there will be new acc_perm.mean
                        % end 
                        % for w = 1:size(acc_perm.mean,1)
                        %     figure(2000 + l)
                        %     subplot(2,2,w);
                        %     histogram(squeeze(acc_perm.mean(w,1,:)),10);
                        % end
    
                    end
                end
    
            end
            % acc_mean_norm : accuracy - chance
            acc.acc_mean_norm = acc.mean;
            for l = 1:length(acc.labels)           
                acc.acc_mean_norm(:, l, :) = (acc.mean(:, l, :)-acc.chance(l))/acc.chance(l);
            end
    
            % END OF ANALYSIS
    
            % save results
            acc.perm = acc_perm;
            save(resfile_acc, 'acc')
            clear alldataNT;
            clear spca_traj_res;
        end
    end
end
