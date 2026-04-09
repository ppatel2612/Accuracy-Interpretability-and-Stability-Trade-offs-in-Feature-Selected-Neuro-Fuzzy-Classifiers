% scripts/03_run_experiments.m
clear; clc;
startup;

datasets = {'arcene','madelon','gisette','dorothea'};
procRoot = fullfile('data','processed');
foldRoot = fullfile('folds');
outRoot  = fullfile('results','fold_results');
if ~exist(outRoot,'dir'), mkdir(outRoot); end

epochs = 50;
clusterRadius = 0.5;
kFinal = 5;

for d = 1:numel(datasets)
    name = datasets{d};
    fprintf('\nRUNNING DATASET: %s\n', upper(name));

    S = load(fullfile(procRoot, [name '.mat']));
    F = load(fullfile(foldRoot, [name '_folds.mat']));

    X = S.X;
    y = S.y;
    folds = F.folds;

    switch name
        case 'dorothea'
            candidateK = 500;
        otherwise
            candidateK = 200;
    end

    allResults = struct();

    for f = 1:numel(folds)
        fprintf('  FOLD %d/%d\n', f, numel(folds));

        trIdx = folds(f).trainIdx;
        teIdx = folds(f).testIdx;

        Xtrain = X(trIdx,:);
        ytrain = y(trIdx);
        Xtest  = X(teIdx,:);
        ytest  = y(teIdx);

        prep = preprocess_fold_data(Xtrain, ytrain, Xtest, candidateK);

        % ---------------------------
        % 1) BASELINE ANFIS
        % ---------------------------
        idxBase = 1:min(kFinal, size(prep.Xtrain,2));
        modelBase = train_anfis_classifier(prep.Xtrain(:,idxBase), ytrain, epochs, clusterRadius);
        yScoreBase = predict_anfis_classifier(modelBase, prep.Xtest(:,idxBase));
        metBase = compute_metrics(ytest, yScoreBase);
        cmpBase = get_model_complexity(modelBase, prep.candidateIdx(idxBase));

        % ---------------------------
        % 2) RELIEFF -> ANFIS
        % ---------------------------
        idxRel = select_relieff_features(prep.Xtrain, ytrain, kFinal);
        modelRel = train_anfis_classifier(prep.Xtrain(:,idxRel), ytrain, epochs, clusterRadius);
        yScoreRel = predict_anfis_classifier(modelRel, prep.Xtest(:,idxRel));
        metRel = compute_metrics(ytest, yScoreRel);
        cmpRel = get_model_complexity(modelRel, prep.candidateIdx(idxRel));

        % ---------------------------
        % 3) LASSO -> ANFIS
        % ---------------------------
        idxLas = select_lasso_features(prep.Xtrain, ytrain, kFinal);
        modelLas = train_anfis_classifier(prep.Xtrain(:,idxLas), ytrain, epochs, clusterRadius);
        yScoreLas = predict_anfis_classifier(modelLas, prep.Xtest(:,idxLas));
        metLas = compute_metrics(ytest, yScoreLas);
        cmpLas = get_model_complexity(modelLas, prep.candidateIdx(idxLas));

        % SAVE
        allResults(f).baseline.metrics = metBase;
        allResults(f).baseline.complexity = cmpBase;
        allResults(f).baseline.features = prep.candidateIdx(idxBase);

        allResults(f).relieff.metrics = metRel;
        allResults(f).relieff.complexity = cmpRel;
        allResults(f).relieff.features = prep.candidateIdx(idxRel);

        allResults(f).lasso.metrics = metLas;
        allResults(f).lasso.complexity = cmpLas;
        allResults(f).lasso.features = prep.candidateIdx(idxLas);
    end

    save(fullfile(outRoot, [name '_results.mat']), 'allResults');
end