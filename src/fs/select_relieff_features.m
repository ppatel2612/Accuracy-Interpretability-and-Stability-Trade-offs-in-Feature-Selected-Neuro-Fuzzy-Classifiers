% src/fs/select_relieff_features.m
function idx = select_relieff_features(Xtrain, ytrain, kFinal)
    [ranked, ~] = relieff(Xtrain, ytrain, 10);
    idx = ranked(1:min(kFinal, numel(ranked)));
end