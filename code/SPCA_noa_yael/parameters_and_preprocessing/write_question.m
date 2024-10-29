function q = write_question(labels2plot, l)
    % create the name of the question
    q = [];
    for j = 1:length(labels2plot{l})
        labels_names = [];
        for i = 1:length(labels2plot{l}{j})
            labels_names = [labels_names ' ' labels2plot{l}{j}{i}];
        end
        if j==1
            q = labels_names;
        else
            q = [q ' vs ' labels_names];
        end
    end
    
end


