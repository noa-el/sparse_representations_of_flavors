
function components_bookkeeping(data_path, params_folder, animals_names,k,stop,parameters, classification_flags)
    %treshold = 0.15;
    animals_db = get_animals_list(data_path, animals_names);
    
    % loop over all animals
    for animal_i =1:length(animals_names)
    
        dates_list = animals_db{animal_i}.folder(animals_db{animal_i}.to_include == 2);            
        % specific animals' analysis results folder 
        animal_folder = fullfile(params_folder, 'per_animal_per_date',[animals_names{animal_i}]);
    
        % loop over all experiments per animal
        for date_i = 1:length(dates_list)
    
            % specific dates' analysis results folder 
            date_folder = fullfile(animal_folder, [dates_list{date_i}]);
    
            % folder datapath of results that the current function uses
            resfile_traj = fullfile(date_folder, ['/spca_trajectories_' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
            resfile_acc = fullfile(date_folder, ['acc' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
            resfile_stat = fullfile(date_folder, ['spca_stat' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
    
            % folder datapath of the current functions' results
            resfile_comp_rec = fullfile(date_folder, ['components_recording' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
            resfile_neurons_rec = fullfile(date_folder, ['neurons_recording' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
            resfile_neurons_rec_acc_values = fullfile(date_folder, ['neurons_recording_acc_values' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
            resfile_neurons_fra = fullfile(date_folder, ['fraction_of_neurons' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
            resfile_explained_var_fra = fullfile(date_folder, ['fraction_of_explained_var' animals_names{animal_i} '_' dates_list{date_i} '.mat']);
            % NO CODE FOR THE CASE RESULTS ALREADY EXIST - WILL RUN ANALYSIS ANYWAY
    
            % in case the data that the current function uses does not exist,
            % run the relevant fuction
            if (~isfolder(animal_folder) | ~isfolder(date_folder) | ~isfile(resfile_traj)) | (~isfile(resfile_acc)) | (~isfile(resfile_stat)) 
                apply_spca(data_path, params_folder, animals_names(animal_i),k,stop);
                apply_classifier(data_path, params_folder, animals_names(animal_i),k,stop, parameters, classification_flags,0);
            end
            % if it still does not exist, do not run the loop on this part of
            % the data
            if (~isfolder(animal_folder) | ~isfolder(date_folder) | ~isfile(resfile_traj)) | (~isfile(resfile_acc)) | (~isfile(resfile_stat)) 
                continue;
            end
            % load the data that the current function uses
            load(resfile_traj,'spca_traj_res')
            load(resfile_acc,'acc')
            load(resfile_stat,'spca_stat')
    
            % ANALYSIS STARTS HERE
    
            % thresholding to get components_recording
            % components_recording:  time windows x questions x components
            % contains accuracy - chance > threshold meaning
            % is the component relevant for answering the question in the time window
    
            % components_recording = acc.acc_mean_norm > treshold;
            components_recording = NaN(size(acc.mean));
            for l = 1:size(acc.sigma3,2)
                components_recording(:,l,:) = acc.sigma3(:,l,:);
            end
            components_recording_acc_values = acc.acc_mean_norm .* components_recording;
    
            % SPCA kernel with 1 replacing any nonzero value
            % meaning does the component consistof the neuron
            binary_kernel = spca_traj_res.kernel ~= 0;
    
            % using matrix multiplication with binary_kernel to create neurons_recording
            % components_recording:  time windows x questions x components
            % binary_kernel: neurons x components
            % for every question:
            % contains matrix multiplication of components_recording with binary_kernel
            % meaning is the neuron relevant for answering the question in the time window 
    
            % neurons_recording_acc_values: time windows x questions x neurons
            % contains acc_values for classifier that passed the threshold, else 0 
            neurons_recording_acc_values = zeros(size(acc.mean,1),size(acc.mean,2),size(spca_traj_res.kernel,1));
            for l = 1:parameters.Q
                temp = (binary_kernel * squeeze(components_recording_acc_values(:,l,:))')';
                neurons_recording_acc_values(:, l, :) = reshape(temp,[size(temp,1), 1, size(temp,2)]);
            end
    
            % neurons_recording: time windows X questions X neurons
            % contains 1 for classifier that passed the threshold, else 0 
            neurons_recording = zeros(size(acc.mean,1),size(acc.mean,2),size(spca_traj_res.kernel,1));
            for l = 1:parameters.Q           
                temp = (binary_kernel * squeeze(components_recording(:,l,:))')';
                neurons_recording(:, l, :) = reshape(temp,[size(temp,1), 1, size(temp,2)]);
            end
    
            % neurons_recording_acc_values: matrix multiplication could get more than for neurons of some components
            % in this case, take mean accuracy
            neurons_recording_acc_values = neurons_recording_acc_values./neurons_recording;
            neurons_recording_acc_values(isnan(neurons_recording_acc_values)) = 0;
            % neurons_recording: matrix multiplication could get also int 2,3,4... for neurons of some components
            % turn non neurons_recording zero valeus to 1
            neurons_recording(~isnan(neurons_recording)) = double(neurons_recording(~isnan(neurons_recording)) > 0);
    
            % explained_var_recording: time windows X questions
            % using matrix multiplication with comp_explained_var to create neurons_recording
            % components_recording:  time windows x questions x components
            % comp_explained_var: components
            % for every question:
            % contains matrix multiplication of components_recording with comp_explained_var
            % meaning total explained variance of the part of the net that encodes the question in the time window 
    
            explained_var_recording = zeros(size(acc.mean,1),size(acc.mean,2));
            for l = 1:parameters.Q
                temp = (spca_stat.comp_explained_var' * squeeze(components_recording(:,l,:))')';
                explained_var_recording(:, l) = temp;
            end
    
    
            % fraction_of_neurons = "Neurons Bookkeeping "(𝑖,𝑗,:)>0 / neurons
            fraction_of_neurons = sum(neurons_recording == 1,3)/size(neurons_recording,3);
    
            % ANALYSIS ENDS HERE
    
            % save results
            save(resfile_comp_rec, 'components_recording');
            save(resfile_neurons_rec, 'neurons_recording');
            save(resfile_neurons_rec_acc_values, 'neurons_recording_acc_values');
            save(resfile_neurons_fra, 'fraction_of_neurons');
            save(resfile_explained_var_fra, "explained_var_recording");
    
        end  
    end
end