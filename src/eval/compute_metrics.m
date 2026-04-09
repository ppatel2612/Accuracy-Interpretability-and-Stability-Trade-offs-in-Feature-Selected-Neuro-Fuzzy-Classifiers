% src/eval/compute_metrics.m
function metrics = compute_metrics(ytrue, yscore)
    ypred = double(yscore >= 0.5);

    metrics.accuracy = mean(ypred == ytrue);
    metrics.macroF1  = macro_f1(ytrue, ypred);

    try
        [~,~,~,auc] = perfcurve(ytrue, yscore, 1);
    catch
        auc = NaN;
    end
    metrics.auc = auc;
end