function handleIndexUpdatingCallback(src,~)
msg = readline(src);
data = jsondecode(msg);
if isfield(data,'Frequency')
    src.UserData.TriggerAxes.UserData.Index.Frequency = data.Frequency;
end
if isfield(data, 'Amplitude')
    src.UserData.TriggerAxes.UserData.Index.Amplitude = data.Amplitude;
end
if isfield(data, 'FrequencyToPlot')
    src.UserData.RecruitmentCurveAxes.UserData.FrequencyIndexForCurve = data.FrequencyToPlot;
end
end