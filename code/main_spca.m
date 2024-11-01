% code:
addpath(genpath('utils'));
addpath(genpath('manage_data'));
addpath(genpath('svm'));
addpath(genpath('temporalTraj'));
addpath(genpath('SpaSM'))
addpath(genpath('log_reg'))
addpath(genpath('SPCA_noa_yael\bookkeeping'))
addpath(genpath('SPCA_noa_yael\classification'))
addpath(genpath('SPCA_noa_yael\compare_analysis'))
addpath(genpath('SPCA_noa_yael\correlation'))
addpath(genpath('SPCA_noa_yael\parameter_tuning'))
addpath(genpath('SPCA_noa_yael\parameters_and_preprocessing'))
addpath(genpath('SPCA_noa_yael\spca'))

[parameters, animals_names, k_vec, stop_vec, session_var] = get_analysis_parameters();
[classification_flags, run_parameters, data_path, results_path, pca_results_path, spca_results_path, analysis_vec, analysis_vec_title, figs_folder, excel_path] = get_run_parameters();

if run_parameters.run_pca
    apply_pca(data_path, spca_results_path, animals_names)
end

for stop = stop_vec
    for  k = k_vec
        params_folder = fullfile(spca_results_path, ['num_stop' num2str(abs(stop)) 'num_components' num2str(k) ]);
        res_folder1 = fullfile(params_folder, 'per_animal_per_date');
        res_folder2 = fullfile(params_folder, 'per_animal_across_dates');
        res_folder3 = fullfile(params_folder, 'across_animals');

        if ~isfolder(params_folder)
            mkdir(params_folder);
            mkdir(res_folder1);
            mkdir(res_folder2);
            mkdir(res_folder3);
        end

        if run_parameters.run_classification
            apply_spca(data_path, params_folder, animals_names,k,stop);
            apply_classifier(data_path, params_folder, animals_names,k,stop, parameters, classification_flags,run_parameters.to_plot);
            % save_max_acc(k, stop, data_path, spca_resultspath, animals_names, parameters, classification_flags)
        end
        if run_parameters.run_components_bookkeeping
            components_bookkeeping(data_path, params_folder, animals_names,k,stop,parameters, classification_flags)
            if run_parameters.to_plot
                plot_frac_neurons(data_path, params_folder, animals_names,k,stop,session_var, 0)  
                plot_frac_neurons(data_path, params_folder, animals_names,k,stop,session_var, 1) 
                frac_explained_var(data_path, params_folder, animals_names,k,stop,session_var) 
                neurons_bookkeeping_across_dates(data_path, params_folder, animals_names,k,stop,parameters,0)
                neurons_bookkeeping_across_animals(data_path, params_folder, animals_names,k,stop,parameters)
            end
        end
        correlation_mat(data_path, params_folder, animals_names,parameters,0);
        correlation_mat_across_animals(data_path, params_folder, animals_names, parameters);
        compare_correlation_bookkeeping(data_path, params_folder, animals_names,k,stop,parameters,0)
        compare_correlation_bookkeeping_across_animals(data_path, params_folder, animals_names,parameters)
    end
end 

for stop = stop_vec
    if run_parameters.run_spca && run_parameters.to_plot
        %plot_explained_variance_vs_k(k_vec,data_path, pca_results_path, spca_results_path, animals_names,stop)
    end
end

for  k = k_vec
    if run_parameters.compare_stop && run_parameters.to_plot
        %plot_acc_chance(k, stop_vec, data_path, spca_results_path, animals_names, parameters, classification_flags)
    end
end

% plot_max_acc(k_vec, stop_vec, data_path, results_path, analysis_vec)
% plot_max_acc_per_l(k_vec, stop_vec, data_path, results_path, analysis_vec)
% plot_max_acc_per_l_per_type(k_vec, stop, data_path, results_path, analysis_vec, analysis_vec_title, parameters) 