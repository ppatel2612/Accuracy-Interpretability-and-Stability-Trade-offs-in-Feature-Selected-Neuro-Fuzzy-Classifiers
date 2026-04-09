% scripts/04_summarize_results.m
clear; clc;
startup;

datasets = {'arcene','madelon','gisette','dorothea'};
methods = {'baseline','relieff','lasso'};

inRoot = fullfile('results','fold_results');
tabRoot = fullfile('results','summary_tables');
plotRoot = fullfile('results','plots');

if ~exist(tabRoot,'dir'), mkdir(tabRoot); end
if ~exist(plotRoot,'dir'), mkdir(plotRoot); end

for d = 1:numel(datasets)
    name = datasets{d};
    S = load(fullfile(inRoot, [name '_results.mat']));
    R = S.allResults;

    resultsTable = table();
    complexityTable = table();
    stabilityTable = table();

    for m = 1:numel(methods)
        method = methods{m};

        acc = zeros(numel(R),1);
        f1  = zeros(numel(R),1);
        auc = zeros(numel(R),1);
        nf  = zeros(numel(R),1);
        nr  = zeros(numel(R),1);
        nmf = zeros(numel(R),1);
        featSets = cell(numel(R),1);

        for f = 1:numel(R)
            acc(f) = R(f).(method).metrics.accuracy;
            f1(f)  = R(f).(method).metrics.macroF1;
            auc(f) = R(f).(method).metrics.auc;
            nf(f)  = R(f).(method).complexity.numSelectedFeatures;
            nr(f)  = R(f).(method).complexity.numRules;
            nmf(f) = R(f).(method).complexity.numMFs;
            featSets{f} = R(f).(method).features;
        end

        stab = mean_pairwise_jaccard(featSets);

        resultsTable = [resultsTable; table( ...
            string(method), ...
            mean(acc), std(acc), ...
            mean(f1), std(f1), ...
            mean(auc), std(auc), ...
            'VariableNames', {'Method','AccMean','AccStd','F1Mean','F1Std','AUCMean','AUCStd'})];

        complexityTable = [complexityTable; table( ...
            string(method), ...
            mean(nf), mean(nr), mean(nmf), std(nr), ...
            'VariableNames', {'Method','MeanFeatures','MeanRules','MeanMFs','RuleStd'})];

        stabilityTable = [stabilityTable; table( ...
            string(method), stab, ...
            'VariableNames', {'Method','MeanJaccard'})];
    end

    writetable(resultsTable, fullfile(tabRoot, [name '_results_table.csv']));
    writetable(complexityTable, fullfile(tabRoot, [name '_complexity_table.csv']));
    writetable(stabilityTable, fullfile(tabRoot, [name '_stability_table.csv']));
end

function s = mean_pairwise_jaccard(featSets)
    vals = [];
    for i = 1:numel(featSets)
        for j = i+1:numel(featSets)
            A = featSets{i};
            B = featSets{j};
            vals(end+1) = numel(intersect(A,B)) / numel(union(A,B));
        end
    end
    s = mean(vals);
end