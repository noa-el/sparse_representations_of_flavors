function [classification_flags, run_parameters, data_path, results_path, pca_results_path, spca_results_path, analysis_vec, analysis_vec_title, figs_folder, excel_path] = get_run_parameters()
    % 'original_log_reg'  'spca_log_reg' 'spca_sliding_log_reg'
    % 'spca_sliding_svm' 'pca'
    analysis_vec = {'spca_log_reg','spca_sliding_log_reg','spca_sliding_svm'};
    analysis_vec_title = {'log reg','sliding log reg','sliding svm'};
    
    % chosen analysis
    chosen_analysis = 'spca_sliding_log_reg';
    % plot flg
    run_parameters.to_plot = 1;
    
    % REPLACE WITH PATH TO DATA
    data_path = 'C:\Users\Hadas-stud-group1\Desktop\yael_noa\flavors_experiment\preprocessed_data\';
    % REPLACE WITH PATH TO PCA RESULTS
    pca_results_path = '../../analysisres/pca/';
    % REPLACE WITH PATH TO RESULTS
    results_path = '../../analysisres/';
    % parameter tuning graph display flag
    run_parameters.compare_stop = 1;
    % defines inner parameters for the different types of analysis
    switch chosen_analysis
        case 'original_log_reg'
            spca_results_path = '../../analysisres/original_log_reg_results/';
            classification_flags.log_reg_flag = 1;
            classification_flags.all_data_to_classifier = 1;
            classification_flags.mean_flag = 1;
            classification_flags.win_flag = 0;
            classification_flags.components_flag = 0;
            classification_flags.l1_flag = 1;
    
            run_parameters.run_pca = 0;
            run_parameters.run_spca = 1;
            run_parameters.run_classification = 1;
            run_parameters.run_components_bookkeeping = 0;
    
        case 'spca_log_reg'
            spca_results_path = '../../analysisres/spca_log_reg_results/';
            classification_flags.log_reg_flag = 1;
            classification_flags.all_data_to_classifier = 0;
            classification_flags.mean_flag = 1;
            classification_flags.win_flag= 0;
            classification_flags.components_flag = 0;
            classification_flags.l1_flag = 0;
            run_parameters.run_pca = 0;
            run_parameters.run_spca = 1;
            run_parameters.run_classification = 1;
            run_parameters.run_components_bookkeeping = 0;
        case 'spca_sliding_log_reg'
            spca_results_path = '../../analysisres/spca_sliding_log_reg_results/';
            classification_flags.log_reg_flag = 1;
            classification_flags.all_data_to_classifier = 0;
            classification_flags.mean_flag = 1;
            classification_flags.win_flag = 1;
            classification_flags.components_flag = 1;
            classification_flags.l1_flag = 0;
            run_parameters.run_pca = 0;
            run_parameters.run_spca = 1;
            run_parameters.run_classification = 1;
            run_parameters.run_components_bookkeeping = 1;
    
        case 'spca_sliding_svm'
            classification_flags.log_reg_flag = 0;
            classification_flags.all_data_to_classifier = 0;
            classification_flags.mean_flag = 1;
            classification_flags.win_flag = 1;
            classification_flags.components_flag = 1;
            classification_flags.l1_flag = 0;
            spca_results_path = '../../analysisres/spca_sliding_svm_results/';  
            run_parameters.run_pca = 0;
            run_parameters.run_spca = 1;
            run_parameters.run_classification = 1;
            run_parameters.run_components_bookkeeping = 1;
    
        case 'pca'
            spca_results_path = pca_results_path; 
            run_parameters.run_pca = 1;
            run_parameters.run_spca = 0;
            run_parameters.run_classification = 0;
            run_parameters.run_components_bookkeeping = 0;
    end
    figs_folder = '../../figs2/';
    excel_path = '../../xls2/';

    mkNewFolder(results_path);
    mkNewFolder(figs_folder);
    mkNewFolder(excel_path);
end
