% src/fs/select_lasso_features.m
function idx = select_lasso_features(Xtrain, ytrain, kFinal)
    [B, fitInfo] = lassoglm(Xtrain, ytrain, 'binomial', 'CV', 5);

    % USE 1-SE MODEL FOR STABILITY
    b = B(:, fitInfo.Index1SE);
    idx = find(b ~= 0);

    % FALLBACK IF NOTHING SELECTED
    if isempty(idx)
        idx = 1:min(kFinal, size(Xtrain,2));
        return;
    end

    % LIMIT TO kFinal BY ABSOLUTE COEFFICIENT SIZE
    [~, order] = sort(abs(b(idx)), 'descend');
    idx = idx(order);
    idx = idx(1:min(kFinal, numel(idx)));
end