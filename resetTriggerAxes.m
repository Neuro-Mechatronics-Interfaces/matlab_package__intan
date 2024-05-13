function [ax, hLine] = resetTriggerAxes(ax, selectedChannel, numFrequencies, numAmplitudes, numChannels, numSnippetSamples, numTriggersSaved)

delete(ax.Children);

ax.UserData.Index = struct('Amplitude', 1, 'Frequency', 1, 'Trigger', ones(numFrequencies,numAmplitudes), 'Channel', selectedChannel);
ax.UserData.Samples = cell(numFrequencies, numAmplitudes);
for ii = 1:numFrequencies
    for ik = 1:numAmplitudes
        ax.UserData.Samples{ii, ik} = zeros(numChannels, numSnippetSamples, numTriggersSaved);
    end
end
xData = linspace(ax.XLim(1),ax.XLim(2),numSnippetSamples);
hLine = line(ax,xData,zeros(1,numSnippetSamples), ...
    'Color', 'k', 'LineWidth', 2);

end