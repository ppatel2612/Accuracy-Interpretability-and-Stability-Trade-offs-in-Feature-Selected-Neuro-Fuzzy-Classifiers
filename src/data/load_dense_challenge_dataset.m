% src/data/load_dense_challenge_dataset.m
function [X, y] = load_dense_challenge_dataset(folder, name)
    trainDataFile  = fullfile(folder, [name '_train.data']);
    trainLabelFile = fullfile(folder, [name '_train.labels']);
    validDataFile  = fullfile(folder, [name '_valid.data']);
    validLabelFile = fullfile(folder, [name '_valid.labels']);

    Xtr = readmatrix(trainDataFile, 'FileType', 'text');
    ytr = readmatrix(trainLabelFile, 'FileType', 'text');

    Xva = readmatrix(validDataFile, 'FileType', 'text');
    yva = readmatrix(validLabelFile, 'FileType', 'text');

    X = [Xtr; Xva];
    y = [ytr; yva];

    % CONVERT LABELS FROM {-1,+1} TO {0,1}
    y = double(y == 1);
end