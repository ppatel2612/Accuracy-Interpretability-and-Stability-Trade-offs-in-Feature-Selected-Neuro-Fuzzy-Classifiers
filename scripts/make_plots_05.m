% scripts/05_make_plots.m
clear; clc;
startup;

datasets = {'arcene','madelon','gisette','dorothea'};

summaryRoot = fullfile('results','summary_tables');
foldRoot    = fullfile('results','fold_results');
plotRoot    = fullfile('results','plots');

if ~exist(plotRoot, 'dir')
    mkdir(plotRoot);
end

for d = 1:numel(datasets)
    datasetName = datasets{d};
    fprintf('\nGENERATING PLOTS FOR %s...\n', upper(datasetName));

    resultsFile    = fullfile(summaryRoot, [datasetName '_results_table.csv']);
    complexityFile = fullfile(summaryRoot, [datasetName '_complexity_table.csv']);
    stabilityFile  = fullfile(summaryRoot, [datasetName '_stability_table.csv']);
    foldFile       = fullfile(foldRoot,    [datasetName '_results.mat']);

    if ~isfile(resultsFile)
        warning('MISSING FILE: %s', resultsFile);
        continue;
    end
    if ~isfile(complexityFile)
        warning('MISSING FILE: %s', complexityFile);
        continue;
    end
    if ~isfile(stabilityFile)
        warning('MISSING FILE: %s', stabilityFile);
        continue;
    end
    if ~isfile(foldFile)
        warning('MISSING FILE: %s', foldFile);
        continue;
    end

    Tperf = readtable(resultsFile);
    Tcomp = readtable(complexityFile);
    Tstab = readtable(stabilityFile);

    S = load(foldFile);
    allResults = S.allResults;

    datasetPlotDir = fullfile(plotRoot, datasetName);
    if ~exist(datasetPlotDir, 'dir')
        mkdir(datasetPlotDir);
    end

    % NORMALIZE METHOD NAMES FOR CONSISTENT LABELS
    perfMethods = normalize_method_labels(Tperf.Method);
    compMethods = normalize_method_labels(Tcomp.Method);
    stabMethods = normalize_method_labels(Tstab.Method);

    % REORDER TABLES TO MATCH A STANDARD ORDER
    desiredOrder = ["baseline","relieff","lasso"];
    Tperf = reorder_table_by_method(Tperf, perfMethods, desiredOrder);
    Tcomp = reorder_table_by_method(Tcomp, compMethods, desiredOrder);
    Tstab = reorder_table_by_method(Tstab, stabMethods, desiredOrder);

    methodLabels = pretty_method_labels(string(Tperf.Method));

    % ---------------------------------------------------------
    % 1) TRADEOFF PLOT: ACCURACY VS SELECTED FEATURES
    % ---------------------------------------------------------
    f = figure('Visible','off');
    errorbar(Tcomp.MeanFeatures, Tperf.AccMean, Tperf.AccStd, 'o', 'LineWidth', 1.5, 'MarkerSize', 8);
    grid on;
    xlabel('Mean # Selected Features');
    ylabel('Mean Accuracy');
    title(sprintf('%s: Accuracy vs Selected Features', upper(datasetName)));
    add_point_labels(Tcomp.MeanFeatures, Tperf.AccMean, methodLabels);
    saveas(f, fullfile(datasetPlotDir, [datasetName '_acc_vs_features.png']));
    close(f);

    % ---------------------------------------------------------
    % 2) TRADEOFF PLOT: ACCURACY VS RULES
    % ---------------------------------------------------------
    f = figure('Visible','off');
    errorbar(Tcomp.MeanRules, Tperf.AccMean, Tperf.AccStd, 'o', 'LineWidth', 1.5, 'MarkerSize', 8);
    grid on;
    xlabel('Mean # Rules');
    ylabel('Mean Accuracy');
    title(sprintf('%s: Accuracy vs Rules', upper(datasetName)));
    add_point_labels(Tcomp.MeanRules, Tperf.AccMean, methodLabels);
    saveas(f, fullfile(datasetPlotDir, [datasetName '_acc_vs_rules.png']));
    close(f);

    % ---------------------------------------------------------
    % 3) TRADEOFF PLOT: MACRO-F1 VS FEATURES
    % ---------------------------------------------------------
    f = figure('Visible','off');
    errorbar(Tcomp.MeanFeatures, Tperf.F1Mean, Tperf.F1Std, 'o', 'LineWidth', 1.5, 'MarkerSize', 8);
    grid on;
    xlabel('Mean # Selected Features');
    ylabel('Mean Macro-F1');
    title(sprintf('%s: Macro-F1 vs Selected Features', upper(datasetName)));
    add_point_labels(Tcomp.MeanFeatures, Tperf.F1Mean, methodLabels);
    saveas(f, fullfile(datasetPlotDir, [datasetName '_f1_vs_features.png']));
    close(f);

    % ---------------------------------------------------------
    % 4) TRADEOFF PLOT: AUC VS RULES
    % ---------------------------------------------------------
    f = figure('Visible','off');
    errorbar(Tcomp.MeanRules, Tperf.AUCMean, Tperf.AUCStd, 'o', 'LineWidth', 1.5, 'MarkerSize', 8);
    grid on;
    xlabel('Mean # Rules');
    ylabel('Mean AUC');
    title(sprintf('%s: AUC vs Rules', upper(datasetName)));
    add_point_labels(Tcomp.MeanRules, Tperf.AUCMean, methodLabels);
    saveas(f, fullfile(datasetPlotDir, [datasetName '_auc_vs_rules.png']));
    close(f);

    % ---------------------------------------------------------
    % 5) PERFORMANCE BAR CHART
    % ---------------------------------------------------------
    perfMatrix = [Tperf.AccMean, Tperf.F1Mean, Tperf.AUCMean];

    f = figure('Visible','off');
    b = bar(perfMatrix, 'grouped');
    grid on;
    ylim([0 1]);
    set(gca, 'XTickLabel', methodLabels);
    xlabel('Method');
    ylabel('Score');
    title(sprintf('%s: Performance Comparison', upper(datasetName)));
    legend({'Accuracy','Macro-F1','AUC'}, 'Location', 'best');
    saveas(f, fullfile(datasetPlotDir, [datasetName '_performance_bar.png']));
    close(f);

    % ---------------------------------------------------------
    % 6) COMPLEXITY BAR CHART
    % ---------------------------------------------------------
    compMatrix = [Tcomp.MeanFeatures, Tcomp.MeanRules, Tcomp.MeanMFs];

    f = figure('Visible','off');
    bar(compMatrix, 'grouped');
    grid on;
    set(gca, 'XTickLabel', methodLabels);
    xlabel('Method');
    ylabel('Mean Count');
    title(sprintf('%s: Complexity Comparison', upper(datasetName)));
    legend({'#Features','#Rules','#MFs'}, 'Location', 'best');
    saveas(f, fullfile(datasetPlotDir, [datasetName '_complexity_bar.png']));
    close(f);

    % ---------------------------------------------------------
    % 7) STABILITY BAR CHART (MEAN JACCARD)
    % ---------------------------------------------------------
    f = figure('Visible','off');
    bar(Tstab.MeanJaccard);
    grid on;
    ylim([0 1]);
    set(gca, 'XTickLabel', pretty_method_labels(string(Tstab.Method)));
    xlabel('Method');
    ylabel('Mean Pairwise Jaccard Overlap');
    title(sprintf('%s: Feature Stability', upper(datasetName)));
    saveas(f, fullfile(datasetPlotDir, [datasetName '_stability_bar.png']));
    close(f);

    % ---------------------------------------------------------
    % 8) RULE COUNT VARIABILITY BAR CHART
    % ---------------------------------------------------------
    f = figure('Visible','off');
    bar(Tcomp.RuleStd);
    grid on;
    set(gca, 'XTickLabel', methodLabels);
    xlabel('Method');
    ylabel('Std. Dev. of Rule Count');
    title(sprintf('%s: Rule Count Variability', upper(datasetName)));
    saveas(f, fullfile(datasetPlotDir, [datasetName '_rule_variability_bar.png']));
    close(f);

    % ---------------------------------------------------------
    % 9) OPTIONAL: FOLD-LEVEL BOXPLOTS FOR ACCURACY / F1 / AUC
    % ---------------------------------------------------------
    [accData, f1Data, aucData, labels] = extract_fold_metric_matrices(allResults);

    f = figure('Visible','off');
    boxplot(accData, labels);
    grid on;
    ylabel('Accuracy');
    title(sprintf('%s: Fold-Level Accuracy Distribution', upper(datasetName)));
    saveas(f, fullfile(datasetPlotDir, [datasetName '_accuracy_boxplot.png']));
    close(f);

    f = figure('Visible','off');
    boxplot(f1Data, labels);
    grid on;
    ylabel('Macro-F1');
    title(sprintf('%s: Fold-Level Macro-F1 Distribution', upper(datasetName)));
    saveas(f, fullfile(datasetPlotDir, [datasetName '_f1_boxplot.png']));
    close(f);

    f = figure('Visible','off');
    boxplot(aucData, labels);
    grid on;
    ylabel('AUC');
    title(sprintf('%s: Fold-Level AUC Distribution', upper(datasetName)));
    saveas(f, fullfile(datasetPlotDir, [datasetName '_auc_boxplot.png']));
    close(f);

    fprintf('DONE: %s\n', upper(datasetName));
end

fprintf('\nALL PLOTS GENERATED.\n');

% ============================================================
% LOCAL FUNCTIONS
% ============================================================

function labels = normalize_method_labels(methodCol)
    raw = lower(strtrim(string(methodCol)));
    labels = strings(size(raw));

    for i = 1:numel(raw)
        s = raw(i);

        if contains(s, "baseline")
            labels(i) = "baseline";

        elseif contains(s, "relieff") || contains(s, "relief")
            labels(i) = "relieff";

        elseif contains(s, "lasso")
            labels(i) = "lasso";

        else
            labels(i) = s;
        end
    end
end
function Tout = reorder_table_by_method(Tin, methodLabels, desiredOrder)
    idx = zeros(numel(desiredOrder),1);

    for i = 1:numel(desiredOrder)
        match = find(methodLabels == desiredOrder(i), 1);
        if isempty(match)
            error('METHOD "%s" NOT FOUND IN TABLE.', desiredOrder(i));
        end
        idx(i) = match;
    end

    Tout = Tin(idx,:);
end

function labels = pretty_method_labels(methodCol)
    normLabels = normalize_method_labels(methodCol);
    labels = strings(size(normLabels));

    for i = 1:numel(normLabels)
        switch normLabels(i)
            case "baseline"
                labels(i) = "Baseline ANFIS";
            case "relieff"
                labels(i) = "ReliefF->ANFIS";
            case "lasso"
                labels(i) = "LASSO->ANFIS";
            otherwise
                labels(i) = string(methodCol(i));
        end
    end
end

function add_point_labels(x, y, labels)
    for i = 1:numel(labels)
        text(x(i), y(i), ['  ' char(labels(i))], ...
            'FontSize', 9, ...
            'VerticalAlignment', 'bottom', ...
            'Interpreter', 'none');
    end
end

function [accData, f1Data, aucData, labels] = extract_fold_metric_matrices(allResults)
    n = numel(allResults);

    accData = zeros(n,3);
    f1Data  = zeros(n,3);
    aucData = zeros(n,3);

    for i = 1:n
        accData(i,1) = allResults(i).baseline.metrics.accuracy;
        accData(i,2) = allResults(i).relieff.metrics.accuracy;
        accData(i,3) = allResults(i).lasso.metrics.accuracy;

        f1Data(i,1) = allResults(i).baseline.metrics.macroF1;
        f1Data(i,2) = allResults(i).relieff.metrics.macroF1;
        f1Data(i,3) = allResults(i).lasso.metrics.macroF1;

        aucData(i,1) = allResults(i).baseline.metrics.auc;
        aucData(i,2) = allResults(i).relieff.metrics.auc;
        aucData(i,3) = allResults(i).lasso.metrics.auc;
    end

    labels = {'Baseline ANFIS','ReliefF->ANFIS','LASSO->ANFIS'};
end