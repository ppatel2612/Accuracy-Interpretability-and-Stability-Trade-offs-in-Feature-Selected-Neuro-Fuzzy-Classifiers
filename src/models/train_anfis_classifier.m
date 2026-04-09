% src/models/train_anfis_classifier.m
function model = train_anfis_classifier(Xtrain, ytrain, epochs, clusterRadius)
    % HOLD OUT PART OF TRAINING FOR ANFIS VALIDATION
    cv = cvpartition(ytrain, 'HoldOut', 0.2);
    trIdx = training(cv);
    vaIdx = test(cv);

    Xtr = Xtrain(trIdx,:);
    ytr = ytrain(trIdx);
    Xva = Xtrain(vaIdx,:);
    yva = ytrain(vaIdx);

    trainData = [Xtr ytr];
    valData   = [Xva yva];

    initFIS = genfis2(Xtr, ytr, clusterRadius);

    opt = anfisOptions('InitialFIS', initFIS, ...
                       'EpochNumber', epochs, ...
                       'ValidationData', valData, ...
                       'DisplayANFISInformation', 0, ...
                       'DisplayErrorValues', 0, ...
                       'DisplayStepSize', 0, ...
                       'DisplayFinalResults', 0);

    fis = anfis(trainData, opt);

    model.fis = fis;
end