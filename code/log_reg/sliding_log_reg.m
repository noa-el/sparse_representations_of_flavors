function acc = sliding_log_reg(X, Y, winstSec, winendSec, t, foldsnum, tonorm)

% predict all trials using the models trained for naive/expert
for win_i = 1:length(winstSec)
    
    Xwin = X(:,t >= winstSec(win_i) & t <= winendSec(win_i),:);
    rawX=squeeze(mean(Xwin,2))';
    if tonorm
        Xnorm = (rawX - min(rawX(:)))/(max(rawX(:))-min(rawX(:)));
    else
        Xnorm=X;
    end
    if length(Xnorm) == numel(Xnorm)
        Xnorm=Xnorm(:);
    end
    
    
    
    
    ACC = LogReg(Xnorm, Y, foldsnum);
    acc.mean(win_i) = ACC.mean;
    acc.std(win_i) = ACC.std;
    acc.accv(:, win_i) = ACC.acc_v;
    
end
end