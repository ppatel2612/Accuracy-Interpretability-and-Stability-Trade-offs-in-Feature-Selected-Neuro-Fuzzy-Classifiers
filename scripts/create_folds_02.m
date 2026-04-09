% scripts/02_create_folds.m
clear; clc;
startup;

procRoot = fullfile('data','processed');
foldRoot = fullfile('folds');
if ~exist(foldRoot,'dir'), mkdir(foldRoot); end

datasets = {'arcene','madelon','gisette','dorothea'};
K = 10;

for i = 1:numel(datasets)
    name = datasets{i};
    S = load(fullfile(procRoot, [name '.mat']), 'y');
    y = S.y;

    cv = cvpartition(y, 'KFold', K);

    folds = struct();
    for f = 1:K
        folds(f).trainIdx = training(cv, f);
        folds(f).testIdx  = test(cv, f);
    end

    save(fullfile(foldRoot, [name '_folds.mat']), 'folds');
    fprintf('%s FOLDS CREATED.\n', upper(name));
end