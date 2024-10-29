function acc = LogReg(data, labels, foldsnum, l1_flag, multi_flag)
    if (size(data,1) > 1 & size(data,2) > 1)
        data = data';
    end
    % Normalize data
    dataNorm = zscore(data);

    if length(labels)<=foldsnum
        foldsnum = length(labels);
    end

    % Initialize arrays to store accuracies
    accuracies = zeros(foldsnum, 1);
    train_accuracies = zeros(foldsnum, 1);


    % Perform cross-validation
    cv = cvpartition(labels, 'KFold', foldsnum, 'Stratify', true);
    for fold = 1:foldsnum
        dataTrain = dataNorm(cv.training(fold), :);
        labelsTrain = labels(cv.training(fold));
        dataTest = dataNorm(cv.test(fold), :);
        labelsTest = labels(cv.test(fold));

        if multi_flag
            % Fit multinomial logistic regression model
            B = mnrfit(dataTrain, labelsTrain, 'model', 'nominal', 'link', 'logit');

            % Predict probabilities
            pihat = mnrval(B, dataTest);
            [~, predictions] = max(pihat, [], 2);

        else

            % Train logistic regression model for binary
            if l1_flag
                mdl = lassoglm(dataTrain,labelsTrain,'binomial','NumLambda',25,'CV',10);
            else
                % mdl = fitglm(dataTrain, labelsTrain, 'Distribution','normal', 'Link','identity')
                mdl = fitglm(dataTrain, labelsTrain, 'Distribution', 'binomial', 'Link', 'logit');
            end
    
    
            % Make predictions on test set
            % train_predictions = predict(mdl, dataTrain);
            % train_predictions = round(train_predictions);
            predictions = predict(mdl, dataTest);
            predictions = round(predictions);
        end 
        % Calculate accuracy for this fold
        % train_correctPredictions = sum(train_predictions == labelsTrain);
        % train_totalPredictions = length(labelsTrain);
        % train_accuracies(fold) = train_correctPredictions / train_totalPredictions;


        correctPredictions = sum(predictions == labelsTest);
        totalPredictions = length(labelsTest);
        accuracies(fold) = correctPredictions / totalPredictions;
        chance(fold) = sum(labelsTest)/length(labelsTest);
        chance(fold) = max(chance(fold),1-chance(fold));
    end

    % Calculate mean and standard deviation of accuracy across folds
    acc.mean = mean(accuracies);
    acc.std = std(accuracies);
    acc.acc_v = accuracies;
    acc.empiric_chance = mean(chance);
end
