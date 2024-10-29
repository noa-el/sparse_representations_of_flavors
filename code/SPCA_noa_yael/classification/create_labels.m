function  labels2cluster = create_labels(labels, imagingData, BehaveData, multi_flag_vec)
    % select trials that have one of the labels we want to process
    labels2cluster = nan(size(imagingData.samples, 3), length(labels));
    for l = 1:length(labels)
        a = zeros(size(imagingData.samples, 3),1);
        b = zeros(size(imagingData.samples, 3),1);
        c = zeros(size(imagingData.samples, 3),1);
        multi_flag = multi_flag_vec(l);
        for i = 1:length(labels{l}{1})
            if isfield(BehaveData, labels{l}{1}(i))
                a = a | BehaveData.(labels{l}{1}{i}).indicatorPerTrial;
            end                
        end
    
        for i = 1:length(labels{l}{2})
            if isfield(BehaveData, labels{l}{2}(i))
                b = b | BehaveData.(labels{l}{2}{i}).indicatorPerTrial;
            end                
        end
        
        if multi_flag
            for i = 1:length(labels{l}{3})
                if isfield(BehaveData, labels{l}{3}(i))
                    c = c | BehaveData.(labels{l}{3}{i}).indicatorPerTrial;
                end 
            end 
        end
        if multi_flag
            if(sum(a)==0 || sum(b)==0 || sum(c)==0)
                labels2cluster(:, l) = nan(size(imagingData.samples, 3),1);
            else
                labels2cluster(:, l) = 2 * a + 3 * (b - (b & a)) + 4 *(c - (c & (a|b)));
            end
        else
            if(sum(a)==0 || sum(b)==0)
                labels2cluster(:, l) = nan(size(imagingData.samples, 3),1);
            else
                labels2cluster(:, l) = a + 2 * (b - (b & a));
            end
        end
    end
end
