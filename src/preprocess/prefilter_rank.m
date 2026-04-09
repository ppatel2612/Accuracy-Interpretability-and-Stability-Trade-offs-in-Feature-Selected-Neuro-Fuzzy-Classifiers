% src/fs/prefilter_rank.m
function rankedIdx = prefilter_rank(Xtrain, ytrain)
    % SCORE FEATURES BY ABSOLUTE DIFFERENCE OF CLASS MEANS / STD
    class0 = (ytrain == 0);
    class1 = (ytrain == 1);

    mu0 = mean(Xtrain(class0,:), 1);
    mu1 = mean(Xtrain(class1,:), 1);
    sd  = std(Xtrain, 0, 1) + 1e-8;

    score = abs(mu1 - mu0) ./ sd;
    [~, rankedIdx] = sort(score, 'descend');
end