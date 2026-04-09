% src/preprocess/preprocess_fold_data.m
function out = preprocess_fold_data(Xtrain, ytrain, Xtest, candidateK)
    % CONVERT SPARSE TO FULL ONLY AFTER REDUCING DIMENSION WHEN POSSIBLE

    % REMOVE ZERO-VARIANCE FEATURES FROM TRAINING SET
    if issparse(Xtrain)
        v = full(var(full(Xtrain), 0, 1));
    else
        v = var(Xtrain, 0, 1);
    end
    keepVar = (v > 0);

    Xtrain = Xtrain(:, keepVar);
    Xtest  = Xtest(:, keepVar);

    % GET PREFILTER RANK
    if issparse(Xtrain)
        XtrainDense = full(Xtrain);
        XtestDense  = full(Xtest);
    else
        XtrainDense = Xtrain;
        XtestDense  = Xtest;
    end

    ranked = prefilter_rank(XtrainDense, ytrain);
    candidateK = min(candidateK, numel(ranked));
    candIdx = ranked(1:candidateK);

    XtrainCand = XtrainDense(:, candIdx);
    XtestCand  = XtestDense(:, candIdx);

    % STANDARDIZE USING TRAINING FOLD ONLY
    mu = mean(XtrainCand, 1);
    sd = std(XtrainCand, 0, 1);
    sd(sd == 0) = 1;

    XtrainCand = (XtrainCand - mu) ./ sd;
    XtestCand  = (XtestCand - mu) ./ sd;

    out.Xtrain = XtrainCand;
    out.Xtest  = XtestCand;
    out.candidateIdx = find(keepVar);
    out.candidateIdx = out.candidateIdx(candIdx);
end