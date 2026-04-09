% scripts/01_prepare_datasets.m
clear; clc;
startup;

rawRoot = fullfile('data', 'raw');
procRoot = fullfile('data', 'processed');
if ~exist(procRoot, 'dir'), mkdir(procRoot); end

datasets = {'arcene','madelon','gisette','dorothea'};

for i = 1:numel(datasets)
    name = datasets{i};
    folder = fullfile(rawRoot, name);

    fprintf('\nPREPARING %s...\n', upper(name));

    switch name
        case {'arcene','madelon','gisette'}
            [X, y] = load_dense_challenge_dataset(folder, name);
        case 'dorothea'
            [X, y] = load_dorothea_dataset(folder);
    end

    save(fullfile(procRoot, [name '.mat']), 'X', 'y', '-v7.3');
    fprintf('%s SAVED.\n', upper(name));
end