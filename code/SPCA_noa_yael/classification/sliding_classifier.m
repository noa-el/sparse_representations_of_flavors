function acc = sliding_classifier(X, Y, winstSec, winendSec, t, foldsnum, tonorm, classification_flags, multi_flag)

% predict all trials using the models trained for naive/expert
for win_i = 1:length(winstSec)
    % take only time window data
    Xwin = X(:,t >= winstSec(win_i) & t <= winendSec(win_i),:);
    t_win = t(t >= winstSec(win_i) & t <= winendSec(win_i));
    % mean over secods
    if(classification_flags.mean_flag)
        mean_win = winstSec(win_i) + 0.5 : 0.5 : winendSec(win_i) - 0.5;
        Xwin_means = zeros(size(Xwin,1), length(mean_win), size(Xwin,3));
        for mean_win_i = 1:length(mean_win)
            Xwin_means(:,mean_win_i,:) = mean(Xwin(:,t_win >= mean_win(mean_win_i) - 0.5 & t_win <= mean_win(mean_win_i) +0.5,:) ,2);
        end
        Xwin = Xwin_means;
    end

    XwinMAT = zeros(size(Xwin,1)*size(Xwin,2), size(Xwin,3));
    for k=1:size(Xwin,3)
        XwinMAT(:, k) = reshape(Xwin(:,:,k),size(Xwin,1)*size(Xwin,2),1);
    end

    % if(classification_flags.meanflag)
    %     rawX=squeeze(mean(XwinMAT,1))';
    % else
    %     rawX=squeeze(XwinMAT);
    % end

    rawX=squeeze(XwinMAT);

    if tonorm
        Xnorm = (rawX - min(rawX(:)))/(max(rawX(:))-min(rawX(:)));
    else
        Xnorm=X;
    end
    if length(Xnorm) == numel(Xnorm)
        Xnorm=Xnorm(:);
    end

    if (classification_flags.log_reg_flag)
        ACC = LogReg(Xnorm, Y, foldsnum, classification_flags.l1_flag, multi_flag);
    else
        ACC = svmClassifyAndRand(Xnorm', Y, Y, foldsnum, '', true, false);
    end

    acc.mean(win_i) = ACC.mean;
    acc.std(win_i) = ACC.std;
    acc.accv(:, win_i) = ACC.acc_v;
    acc.empiric_chance(win_i) = ACC.empiric_chance;
end
end