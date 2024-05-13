function handleWaveformBytesCallback(src, ~)
%HANDLEWAVEFORMBYTESCALLBACK  Assign as callback to waveform client after using intan.initWaveformBytesGraphicsHandles to initialize GUI.
[data, t] = intan.readWaveformByteBlock(src,...
    src.UserData.NumAmplifierChannels,...
    src.UserData.NumAnalogChannels,...
    src.UserData.DigInPresent, ...
    'BlocksPerRead',src.UserData.NumBlocksPerRead);
if isempty(data)
    return;
end
[~,idx] = sort(t, 'ascend');
numAmplifierChannels = src.UserData.NumAmplifierChannels;
for ii = 1:numAmplifierChannels
    h = src.UserData.AmplifierLine(ii);
    h.YData = data(ii,idx) + h.UserData.Offset;
end
numAnalogChannels = src.UserData.NumAnalogChannels;
for ii = 1:numAnalogChannels
    h = src.UserData.AnalogLine(ii);
    h.YData = data(ii + numAmplifierChannels,idx) + h.UserData.Offset;
end
if src.UserData.DigInPresent
    digData = data(numAmplifierChannels+numAnalogChannels+1,:);
    src.UserData.AmplifierAxes.UserData.Sync = digData;
    src.UserData.AnalogAxes.UserData.Sync = digData;
    for ii = 1:src.UserData.NumDigitalChannels
        h = src.UserData.DigitalLine(ii);
        h.YData = bitand(digData(idx), h.UserData.Mask)./h.UserData.Mask + h.UserData.Offset;
    end
    triggerSync = find(bitand(digData,src.UserData.TriggerValue)==src.UserData.TriggerValue);
    if ~isempty(triggerSync)
        index = src.UserData.TriggerAxes.UserData.Index;
        risingSync = triggerSync([triggerSync(1)>1, diff(triggerSync) > 0]);
        for iTrigger = 1:numel(risingSync)
            vec = risingSync(iTrigger) + src.UserData.TriggersVector;
            if (any(vec < 1)) || (any(vec > size(data,2)))
                continue;
            end
            src.UserData.TriggerAxes.UserData.Samples{index.Frequency, index.Amplitude}(:,:,index.Trigger(index.Frequency,index.Amplitude)) = data(1:numAmplifierChannels,vec);
            src.UserData.TriggerAxes.UserData.Index.Trigger(index.Frequency,index.Amplitude) = rem(index.Trigger(index.Frequency,index.Amplitude), src.UserData.TriggerMax) + 1;
        end
        src.UserData.TriggerLine.YData = mean(src.UserData.TriggerAxes.UserData.Samples{index.Frequency, index.Amplitude}(index.Channel,:,:), 3); 
        yData = zeros(1,size(src.UserData.TriggerAxes.UserData.Samples,2));
        for ii = 1:size(src.UserData.TriggerAxes.UserData.Samples,2)
            yData(ii) = rms(src.UserData.TriggerAxes.UserData.Samples{src.UserData.RecruitmentCurveAxes.UserData.FrequencyIndexForCurve, ii}(index.Channel,src.UserData.TriggerResponseVector));
        end
        src.UserData.RecruitmentLine.YData = yData;
    end
end
end