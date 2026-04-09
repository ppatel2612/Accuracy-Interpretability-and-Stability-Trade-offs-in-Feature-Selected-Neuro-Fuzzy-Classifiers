% src/models/predict_anfis_classifier.m
function yScore = predict_anfis_classifier(model, Xtest)
    yScore = evalfis(model.fis, Xtest);
end