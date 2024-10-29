function [parameters, animals_names, k_vec, stop_vec, session_var] = get_analysis_parameters()
    % animals to run the code
    animals_names = {'4458' ,'4575' ,'4754',  '4756', '4880' ,'4882'};%'4940'
    %animals_names = {'4575' ,'4754'};%'4940'
    %animals_names = {'4882'};
    % SPCA number of components
    k_vec = [10];
    % SPCA sparsity parameter
    stop_vec = [30];
    % get the variance of different sessions
    session_var = 1;

    % labels for plots
    labels = {{{'failure'},{'success','failure'}} , {{'sucroses'},{'sucrose'}} , {{'quinines'},{'quinine'}},...
        {{'grains','regulars'},{'grain','regular'}} , {{'grains'},{'quinines','sucroses'}} , {{'quinines'},{'sucroses','grains','regulars'}},...
        {{'grain','regular'},{'quinine'},{'sucrose'}},{{'grains','regulars'},{'quinines'},{'sucroses'}},{{'grainf','regularf'},{'quininef'},{'sucrosef'}}};
    % labels' multyclass flags 
    multi_flag_vec = [0 0 0 0 0 0 1 1 1];
    
    % time parameters
    time_parameters.f_sample = 30;
    time_parameters.tone_time = 4;
    time_parameters.first_sec_ind = 1 + time_parameters.f_sample;

    % time
    time_parameters.original_t = (0:time_parameters.f_sample*12-1)/time_parameters.f_sample - time_parameters.tone_time;
    time_parameters.t = time_parameters.original_t(time_parameters.first_sec_ind:end);
    % get time windows
    time_parameters.win_str = {'start-(-1)','(-1)-2','2-5','5-end'};
    time_parameters.win_st_sec = [time_parameters.t(1),-1,2,5];
    time_parameters.win_end_sec = [-1,2,5,time_parameters.t(end)];

    % experimental session types
    type_vec_across_animals = {'train batch','train batch','first batch','ongoing batch','ongoing batch','ongoing random','ongoing random'};
    
    % number of questions
    parameters.Q = 9;
    % number of time windows
    parameters.W = 4;
    % number of sessions
    parameters.S = 7;
    parameters.labels = labels;
    parameters.multi_flag_vec = multi_flag_vec;
    parameters.time_parameters = time_parameters;
    parameters.type_vec_across_animals = type_vec_across_animals;
end
