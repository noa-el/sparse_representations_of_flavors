function flavors_svm(datapath, resultspath, animals_names)

addpath(genpath('svm'));
animals_db = get_animals_list(datapath, animals_names);
fsample = 30;
params.slidingWinLen = 1;
params.slidingWinHop = 0.5;
params.foldsnum = 10;
params.tonorm = 1;
flavors = { 'quinines', 'sucroses', 'regulars', 'grains','fakes'};
pairs = nchoosek(1:length(flavors), 2);
for animal_i = 1:length(animals_names)
    disp(animals_names{animal_i});
    datesList = animals_db{animal_i}.folder;
    
    
    for ei = 1:length(datesList)
        disp(datesList{ei});
        currfolder = fullfile(datapath, animals_names{animal_i}, datesList{ei});
        datafile = fullfile(currfolder, 'data.mat');
        if ~isfile(datafile)
            continue;
        end
        resfile = fullfile(resultspath, ['svm_' animals_names{animal_i} '_' datesList{ei} '.mat']);
        if isfile(resfile)
            continue;
        end
        load(datafile, 'imagingData', 'BehaveData');
        t = (0:size(imagingData.samples, 2)-1)/fsample;
        
        [winstSec, winendSec] = getFixedWinsFine(round(t(end)), params.slidingWinLen, params.slidingWinHop);
        acc = cell(size(pairs, 1)+1, 1);
        for pair_i = 1:size(pairs, 1)
            [X, Y] = get_data(imagingData.samples, BehaveData, flavors{pairs(pair_i, 1)}, ...
                flavors{pairs(pair_i, 2)});
            if ~isempty(X) && ~isempty(Y)
                acc{pair_i} = sliding_svm(X, Y, winstSec, winendSec, t, params.foldsnum, params.tonorm);
                acc{pair_i}.labels = [flavors{pairs(pair_i, 1)} ' ' flavors{pairs(pair_i, 2)}];
                acc{pair_i}.trialsnum = length(Y);
                acc{pair_i}.chance = sum(Y==1)/length(Y);
                acc{pair_i}.chance = max(acc{pair_i}.chance, 1-acc{pair_i}.chance);
            end
            
        end
        
        % s/f
        if ~isfield(BehaveData, 'success')
            warning(['No success for ' animals_names{animal_i} ' ' datesList{ei}]);
            continue;
        end
        Y = BehaveData.success.indicatorPerTrial;
        X = imagingData.samples;
        acc{pair_i + 1} = sliding_svm(X, Y, winstSec, winendSec, t, params.foldsnum, params.tonorm);
        acc{pair_i + 1}.trialsnum = length(Y);
        acc{pair_i + 1}.labels = 'success failure';
        acc{pair_i + 1}.chance = sum(Y==1)/length(Y);
        acc{pair_i + 1}.chance = max(acc{pair_i + 1}.chance, 1-acc{pair_i + 1}.chance);
        
        
        save(resfile, 'acc');
    end
end

end
