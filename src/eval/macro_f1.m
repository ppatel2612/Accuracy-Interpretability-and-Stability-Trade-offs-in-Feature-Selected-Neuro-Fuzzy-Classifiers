% src/eval/macro_f1.m
function f1 = macro_f1(ytrue, ypred)
    classes = [0 1];
    f1s = zeros(1, numel(classes));

    for i = 1:numel(classes)
        c = classes(i);

        tp = sum((ypred == c) & (ytrue == c));
        fp = sum((ypred == c) & (ytrue ~= c));
        fn = sum((ypred ~= c) & (ytrue == c));

        prec = tp / max(tp + fp, 1);
        rec  = tp / max(tp + fn, 1);

        if prec + rec == 0
            f1s(i) = 0;
        else
            f1s(i) = 2 * prec * rec / (prec + rec);
        end
    end

    f1 = mean(f1s);
end