function  sparse_linear_analysis(datapath, params_folder, animals_names,k,stop)

animals_db = get_animals_list(datapath, animals_names);
addpath(genpath('SpcaSM'));
addpath(genpath('pca'));

% labels for plots
toplot = 0;% if 1 then we plot results but figures are not saved

labels2plot = {{{'failure'},{'success','failure'}} , {{'sucroses'},{'success','failure'}} , {{'quinines'},{'success','failure'}},...
    {{'sucroses'},{'success'}} , {{'grains','regulars'},{'success'}} , {{'quinines','fakes'},{'success'}},...
    {{'quinines','fakes'},{'sucroses'}} , {{'quinine','fake'},{'sucrose'}} , {{'quininef','fakef'},{'sucrosef'}},...
    {{'quininef','fakef'},{'failure'}} , {{'sucrosef'},{'failure'}} , {{'grainf','regularf'},{'failure'}}};
plotcolors = 'rygk'; % matching the labels - red for failure, yellow for sucroses, etc

% parameters for scpa
params.K = k; % how many components we want to extract
params.stop= -stop; % controls how many cells will be selected
% params for svm
fsample = 30;
tonetime = 4;
params.slidingWinLen = 1;
params.slidingWinHop = 0.5;
params.foldsnum = 10;
params.tonorm = 1;

firstsecInd = 1+fsample;

% loop over all animals
for animal_i =1:length(animals_names)
    disp(animals_names{animal_i});
    datesList = animals_db{animal_i}.folder;

    animal_folder = fullfile(params_folder, 'per_animal_per_date',[animals_names{animal_i}]);
    if ~isfolder(animal_folder)
        mkdir(animal_folder);
    end

    % loop over all experiments per animal
    for ei = 1:length(datesList)
        disp(datesList{ei});
        currfolder = fullfile(datapath, animals_names{animal_i}, datesList{ei});
        datafile = fullfile(currfolder, 'data.mat');
        if ~isfile(datafile)
            continue;
        end
        % if resfile already exists then skip it
        
        date_folder = fullfile(animal_folder, [datesList{ei}]);
        if ~isfolder(date_folder)
            mkdir(date_folder);
        end

        resfile_traj = fullfile(date_folder, ['spca_trajectories_' animals_names{animal_i} '_' datesList{ei} '.mat']);
        resfile_acc = fullfile(date_folder, ['acc' animals_names{animal_i} '_' datesList{ei} '.mat']);
        resfile_stat = fullfile(date_folder, ['spca_stat' animals_names{animal_i} '_' datesList{ei} '.mat']);

        % 
   
        if isfile(resfile_acc) & isfile(resfile_traj) & isfile(resfile_stat)
            continue;
        end
    
        % resfile does not exist, we apply the analysis
        % load the data
        load(datafile, 'imagingData', 'BehaveData');

        % time
        t = (0:fsample*12-1)/fsample - tonetime;

        % drop the first second (to avoid the artificial effect in the
        % first few samples
        imagingData.samples = imagingData.samples(:, firstsecInd:fsample*12, :);
        t = t(firstsecInd:end);

        % select trials that have one of the labels we want to process
        labels2cluster = nan(size(imagingData.samples, 3), length(labels2plot));
        for l = 1:length(labels2plot)
            a = zeros(size(imagingData.samples, 3),1);
            b = zeros(size(imagingData.samples, 3),1);

            for i = 1:length(labels2plot{l}{1})
                if isfield(BehaveData, labels2plot{l}{1}(i))
                    a = a | BehaveData.(labels2plot{l}{1}{i}).indicatorPerTrial;
                end                
            end

            for i = 1:length(labels2plot{l}{2})
                if isfield(BehaveData, labels2plot{l}{2}(i))
                    b = b | BehaveData.(labels2plot{l}{2}{i}).indicatorPerTrial;
                end                
            end
            if(sum(a)==0 || sum(b)==0)
                labels2cluster(:, l) = nan(size(imagingData.samples, 3),1);
            else
                labels2cluster(:, l) = a + 2 * (b - (b & a));
            end
        end

        % select trials that are 1 for at least one of the labels
        % selTrials = find(sum(labels2cluster, 2));
        % labels2cluster = labels2cluster(selTrials, :);
        % imagingData.samples = imagingData.samples(:, :, selTrials);


        % reorganize the samples into a matrix of neurons over time*trials
        for k=1:size(imagingData.samples,1)
            alldataNT(:, k) = reshape(imagingData.samples(k,:,:), ...
                size(imagingData.samples,3)*size(imagingData.samples,2),1);
        end
        % remove the mean
        spcaTrajres.mu= mean(alldataNT);
        x_cent = bsxfun(@minus, alldataNT, spcaTrajres.mu);
        % normalize by std
        x_norm = bsxfun(@rdivide, x_cent, sqrt(sum(x_cent.^2)));

        % apply scpa
        [spcaTrajres.kernel, spcaTrajres.eigs] = spca(x_norm, [], params.K, inf, params.stop);
        % get the reconstracted signal and the projections
        % projections are the dimenionality reduced signal
        [srecon_m, sprojeff] = linrecon(alldataNT, spcaTrajres.mu, ...
            spcaTrajres.kernel, 1:params.K);% may be x_norm

        % compute reconstracted signal and the explained variance
        spca_stat.recon_error = sum(sum((srecon_m-alldataNT).^2));
        var_signal = sum(sum((alldataNT-mean(alldataNT(:))).^2));
        spca_stat.explained_var = 1 - spca_stat.recon_error/var_signal;

        % reorganize into 3dim tensores
        for l=1:size(srecon_m,2)
            spcaTrajres.recon(l,:,:) = reshape(srecon_m(:,l),size(imagingData.samples,2), ...
                size(imagingData.samples,3));
        end
        for l=1:size(sprojeff,2)
            spcaTrajres.projeff(l,:,:) = reshape(sprojeff(:,l), size(imagingData.samples,2), ...
                size(imagingData.samples,3));

        end

        % if toplot
        %     % spcacomps will be the first K SPCA components vs. time,
        %     % averaged per label 
        %     spcacomps = nan(params.K, size(spcaTrajres.projeff,2), length(labels2plot));
        %     for l = 1:length(labels2plot)
        %         if isfield(BehaveData, labels2plot{l})
        %             spcacomps(:, :, l) = mean(spcaTrajres.projeff(:,:,labels2cluster(:, l)==1),3);
        %         end
        %     end
        % 
        % 
        % 
        %     figure;
        %     tiledlayout('flow')
        %     for k = 1:params.K
        %         nexttile;
        %         for l = 1:length(labels2plot)                    
        %             plot(t, spcacomps(k, :, l), plotcolors(l));
        %             hold all;
        %         end
        %         axis tight
        %         ylabel(['PC' num2str(k)]);xlabel('time');
        % 
        %     end
        %     legend(labels2plot);
        %     nexttile;
        % 
        %     imagesc(abs(spcaTrajres.kernel(:,1:params.K))>median(spcaTrajres.kernel(:)));
        %     xlabel('PC');ylabel('Cells');
        % end



        % svm per time windows
        % get time windows
        %[winstSec, winendSec] = getFixedWinsFine(round(t(end)), params.slidingWinLen, params.slidingWinHop);
        winstSec = [t(1),0,2,4];
        winendSec = [-0.2,2,4,t(end)];
        X = spcaTrajres.projeff;
        % loop per label vs the rest
        for l = 1:length(labels2plot)
            % get the label of each trial
            Y = labels2cluster(:, l);
            % loop over each component
            for k = 1:params.K
                % svm 
                accres = sliding_svm(X(k, :, Y~=0), Y(Y~=0) - 1, winstSec, winendSec, t, params.foldsnum, params.tonorm);
                acc.mean(:, l, k) = accres.mean;
            end



            labels_names1 = [];
            for i = 1:length(labels2plot{l}{1})
                labels_names1 = [labels_names1 ' ' labels2plot{l}{1}{i}];
            end

            labels_names2 = [];
            for i = 1:length(labels2plot{l}{2})
                labels_names2 = [labels_names2 ' ' labels2plot{l}{2}{i}];
            end

            acc.labels{l} = [labels_names1 ' vs. ' labels_names2];
            Y = Y(Y>0);
            acc.trialsnum(l) = sum(Y);
            acc.chance(l) = sum(Y==1)/length(Y);
            acc.chance(l) = max(acc.chance(l), 1-acc.chance(l));
            acc.windmid = (winstSec + winendSec)/2;
        end
        % plot the accuracy minus chance level
        if toplot
            figure;
            tiledlayout('flow');
            winmid = (winstSec + winendSec)/2;
            for l = 1:length(labels2plot)
                nexttile;                
                imagesc(winmid, 1:params.K, squeeze(acc.mean(:, l, :))'-acc.chance(l), [-.5, .5]);
                xlabel('time');ylabel('SPC');title(acc.labels{l});colorbar;
            end
            nexttile; 
            imagesc(spcaTrajres.kernel(:,1:params.K));
            xlabel('PC');ylabel('Cells');title('selected cells');
            colormap jet
        end


        % save results
        save(resfile_traj, 'spcaTrajres');
        save(resfile_acc, 'acc')
        save(resfile_stat, 'spca_stat')
        clear alldataNT;
        clear spcaTrajres;

    end
end
end
