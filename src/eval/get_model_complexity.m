% src/eval/get_model_complexity.m
function c = get_model_complexity(model, selectedFeatures)
    fis = model.fis;

    c.numSelectedFeatures = numel(selectedFeatures);

    try
        c.numRules = numel(fis.Rules);
    catch
        try
            c.numRules = numel(fis.rule);
        catch
            c.numRules = NaN;
        end
    end

    try
        c.numMFs = 0;
        for i = 1:numel(fis.Inputs)
            c.numMFs = c.numMFs + numel(fis.Inputs(i).MembershipFunctions);
        end
    catch
        c.numMFs = NaN;
    end
end