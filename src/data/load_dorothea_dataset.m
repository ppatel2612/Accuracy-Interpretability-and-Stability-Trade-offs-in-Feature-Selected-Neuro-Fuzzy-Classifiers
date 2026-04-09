% src/data/load_dorothea_dataset.m
function [X, y] = load_dorothea_dataset(folder)
    numFeatures = 100000;

    trainDataFile  = fullfile(folder, 'dorothea_train.data');
    trainLabelFile = fullfile(folder, 'dorothea_train.labels');
    validDataFile  = fullfile(folder, 'dorothea_valid.data');
    validLabelFile = fullfile(folder, 'dorothea_valid.labels');

    Xtr = parse_sparse_binary_file(trainDataFile, numFeatures);
    ytr = readmatrix(trainLabelFile, 'FileType', 'text');

    Xva = parse_sparse_binary_file(validDataFile, numFeatures);
    yva = readmatrix(validLabelFile, 'FileType', 'text');

    X = [Xtr; Xva];
    y = [ytr; yva];

    y = double(y == 1);
end

function X = parse_sparse_binary_file(filename, numFeatures)
    fid = fopen(filename, 'r');
    assert(fid ~= -1, 'CANNOT OPEN FILE: %s', filename);

    rows = [];
    cols = [];

    rowIdx = 0;
    while ~feof(fid)
        line = strtrim(fgetl(fid));
        rowIdx = rowIdx + 1;

        if isempty(line)
            continue;
        end

        idx = sscanf(line, '%d')';
        rows = [rows, repmat(rowIdx, 1, numel(idx))];
        cols = [cols, idx];
    end
    fclose(fid);

    vals = ones(1, numel(rows));
    X = sparse(rows, cols, vals, rowIdx, numFeatures);
end