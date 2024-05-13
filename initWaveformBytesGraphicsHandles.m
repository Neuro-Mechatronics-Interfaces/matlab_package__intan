function h = initWaveformBytesGraphicsHandles( numAmplifierChannels, numAnalogChannels, digInPresent, options)

arguments
    numAmplifierChannels (1,1) {mustBePositive, mustBeInRange(numAmplifierChannels, 0, 16)} = 16;
    numAnalogChannels (1,1) {mustBeInteger, mustBeInRange(numAnalogChannels, 0, 8)} = 1;
    digInPresent (1,1) logical = true;
    options.NumAmplitudes (1,1) {mustBePositive, mustBeInteger} = 8;
    options.NumFrequencies (1,1) {mustBePositive, mustBeInteger} = 3;
    options.NumTriggersSaved (1,1) {mustBePositive, mustBeInteger} = 10;
    options.SampleRate (1,1) {mustBePositive, mustBeInteger} = 20000;
    options.NumPointsToPlot (1,1) {mustBePositive, mustBeInteger} = 20096;
    options.NumBufferedChunks (1,1) {mustBePositive, mustBeInteger} = 5;
    options.HScaleBarFraction (1,1) {mustBeInRange(options.HScaleBarFraction, 0, 1)} = 0.0995;
    options.AmplifierBandOffset (1,1) {mustBeInRange(options.AmplifierBandOffset, 0, 500)} = 200;
    options.AnalogChannelOffset (1,1) = 24;
    options.DigitalChannels (1,:) = 1:2;
    options.ColorMapAmplifier (:,3) double {mustBeInRange(options.ColorMapAmplifier,0,1)} = jet(16);
    options.ColorMapAnalog (:,3) double {mustBeInRange(options.ColorMapAnalog,0,1)} = hsv(8);
    options.ColorMapDigital (:,3) double {mustBeInRange(options.ColorMapDigital,0,1)} = autumn(2);
    options.TriggerXLim (1,2) double {mustBeInteger} = [-40, 200]; % Samples
    options.TriggerBit (1,1) double {mustBeInteger, mustBeMember(options.TriggerBit, 0:15)} = 1;
    options.TriggerResponseEpoch (1,2) double {mustBeInteger, mustBePositive} = [60, 180];
end

if rem(options.NumPointsToPlot,128) > 0
    error("Number of points must be evenly divisible by frame count (128 samples).");
end

h = struct;
h.Figure = figure('Name', 'Intan Waveforms', 'Color', 'w');
switch getenv("COMPUTERNAME")
    case "MAX_LENOVO"
        h.Figure.Position = [350   100   650   650];
end

% % % Axes Layouts % % %
h.Layout = tiledlayout(h.Figure, 6, 3);
h.Layout.TileIndexing = "columnmajor";
h.AmplifierAxes = nexttile(h.Layout, 1, [3 + double(~digInPresent) 2]);
set(h.AmplifierAxes, 'NextPlot','add', 'Clipping', 'off', ...
    'XColor','none','YColor','none','XLim',[1, options.NumPointsToPlot]);
ylim(h.AmplifierAxes,[-options.AmplifierBandOffset/2, options.AmplifierBandOffset * (numAmplifierChannels+0.5)]);
h.AmplifierAxes.UserData = struct;
h.AmplifierAxes.UserData.N = numAmplifierChannels;
h.AmplifierAxes.UserData.Sync = nan(1,options.NumPointsToPlot);
h.AmplifierAxes.UserData.SyncMax = 2^(max(options.DigitalChannels)-1);

h.TriggerAxes = nexttile(h.Layout, 4 + double(~digInPresent), [1 2]);
set(h.TriggerAxes, 'NextPlot', 'add', 'XColor', 'none', 'YColor', 'none', 'XLim', options.TriggerXLim,'Tag','TriggerAxes');
[h.TriggerAxes, h.TriggerLine] = intan.resetTriggerAxes(h.TriggerAxes, ...
    1, ... % Defaults to first channel
    options.NumFrequencies, ...
    options.NumAmplitudes, ...
    numAmplifierChannels, ...
    diff(options.TriggerXLim) + 1, ...
    options.NumTriggersSaved);
h.TriggersVector = options.TriggerXLim(1):options.TriggerXLim(2);
h.TriggerValue = 2^options.TriggerBit;
h.TriggerMax = options.NumTriggersSaved;
h.TriggerResponseVector = options.TriggerResponseEpoch(1):options.TriggerResponseEpoch(2);

h.AnalogAxes = nexttile(h.Layout, 5 + double(~digInPresent), [1 2]);
set(h.AnalogAxes, 'NextPlot','add','XColor','none','YColor','none','XLim',[1, options.NumPointsToPlot]);
ylim(h.AnalogAxes, [-options.AnalogChannelOffset/2, options.AnalogChannelOffset * (numAnalogChannels + 0.5)]);
h.AnalogAxes.UserData = struct;
h.AnalogAxes.UserData.N = numAnalogChannels;
h.AnalogAxes.UserData.Sync = nan(1,options.NumPointsToPlot);
h.AnalogAxes.UserData.SyncMax = 2^(max(options.DigitalChannels)-1);

if digInPresent
    h.DigitalAxes = nexttile(h.Layout, 6, [1 2]);
    set(h.DigitalAxes, 'NextPlot','add','XColor','none','YColor','none','XLim',[1, options.NumPointsToPlot]);
    ylim(h.DigitalAxes, [-0.1, numel(options.DigitalChannels)+0.1]);
    h.DigitalAxes.UserData = struct;
    h.DigitalAxes.UserData.N = numel(options.DigitalChannels);
    h.DigitalAxes.UserData.Channel = options.DigitalChannels;
else
    h.DigitalAxes = [];
end

h.RecruitmentCurveAxes = nexttile(h.Layout, 13, [6, 1]);
set(h.RecruitmentCurveAxes, 'NextPlot', 'add','FontName','Tahoma','XLim',[-0.05, 1.05],'Tag','RecruitmentCurveAxes');
h.RecruitmentLine = line(h.RecruitmentCurveAxes, linspace(0,1,options.NumAmplitudes), nan(1,options.NumAmplitudes), ... 
    'Marker', 's', 'LineStyle', '-', 'MarkerFaceColor', 'b', 'Color', 'k');

% % % Common Info % % %
xData = 1:options.NumPointsToPlot;
yData = nan(1, options.NumPointsToPlot);

% % % Lines % % %
h.AmplifierLine = gobjects(numAmplifierChannels,1);
h.AnalogLine = gobjects(numAnalogChannels,1);
for ii = 1:numAmplifierChannels
    h.AmplifierLine(ii) = line(h.AmplifierAxes, xData, yData, ...
        'LineWidth', 1, 'Color', options.ColorMapAmplifier(ii,:), ...
        'UserData', struct('Type', 'Amplifier', 'Offset',options.AmplifierBandOffset*(ii-1),'Index',ii), ...
        'ButtonDownFcn', @intan.createLineCopy);
end
title(h.AmplifierAxes, 'Amplifier Channels', 'FontName','Tahoma','Color','k');
h.TriggerLine.Color = h.AmplifierLine(1).Color;
h.TriggerTitle = title(h.TriggerAxes,sprintf('E[Ch-%02d]',1),'FontName','Tahoma','Color',h.TriggerLine(1).Color);
h.RecruitmentCurveAxes.UserData.FrequencyIndexForCurve = 1;
h.RecruitmentTitle = title(h.RecruitmentCurveAxes, "Ch-01 Recruitment | Frequency_1", 'FontName','Tahoma','Color', h.TriggerLine(1).Color);


scaleBarX = [0, options.NumPointsToPlot*options.HScaleBarFraction] + -options.NumPointsToPlot*0.075;
scaleBarY = [-options.AmplifierBandOffset*1.5, -options.AmplifierBandOffset*0.5];
h.HScale = line(h.AmplifierAxes, scaleBarX, scaleBarY(1).*ones(1,2), 'Color', 'k', 'LineWidth', 1.25);
h.VScale = line(h.AmplifierAxes, scaleBarX(1).*ones(1,2), scaleBarY, 'Color', 'k', 'LineWidth', 1.25);
h.HScaleText = text(h.AmplifierAxes, mean(scaleBarX), scaleBarY(1)-0.05*diff(scaleBarY), ...
    sprintf("%dms", round(1000*options.NumPointsToPlot*options.HScaleBarFraction/options.SampleRate)), 'VerticalAlignment','top', 'FontName','Consolas','Color','k');
h.VScaleText = text(h.AmplifierAxes, scaleBarX(1)-options.NumPointsToPlot*0.01, mean(scaleBarY), ...
    sprintf("%d\\muV", round(options.AmplifierBandOffset)), 'FontName','Consolas','Color','k','HorizontalAlignment','center','Rotation',90,'VerticalAlignment','bottom');

for ii = 1:numAnalogChannels
    h.AnalogLine(ii) = line(h.AnalogAxes, xData, yData, ...
        'LineWidth', 1, 'Color', options.ColorMapAnalog(ii,:), ...
        'UserData', struct('Type', 'Analog', 'Offset', (ii-1)*options.AnalogChannelOffset, 'Index', numAmplifierChannels+ii, 'Channel', ii), ...
        'ButtonDownFcn', @intan.createLineCopy);
end
title(h.AnalogAxes, 'Analog Syncs', 'FontName','Tahoma','Color','k');
if digInPresent
    numDigChannels = h.DigitalAxes.UserData.N;
    h.DigitalLine = gobjects(numDigChannels,1);
    for ii = 1:numDigChannels
        h.DigitalLine(ii) = line(h.DigitalAxes, xData, yData, ...
            'LineWidth', 1, 'Color', options.ColorMapDigital(ii,:), ...
            'UserData', struct('Type', 'Digital', 'Offset',ii-1,'Mask',2^(options.DigitalChannels(ii)-1)), ...
            'ButtonDownFcn', @intan.createLineCopy);
    end
    title(h.DigitalAxes, 'Digital Syncs', 'FontName','Tahoma','Color','k');
else
    h.DigitalLine = [];
end

h.NumAmplifierChannels = numAmplifierChannels;
h.NumAnalogChannels = numAnalogChannels;
h.DigInPresent = digInPresent;
if h.DigInPresent
    h.NumDigitalChannels = numDigChannels;
else
    h.NumDigitalChannels = 0;
end
h.NumBlocksPerRead = options.NumPointsToPlot / 128;
h.UDP = udpport('LocalHost',"0.0.0.0");
h.UDP.UserData = struct;
h.UDP.UserData.TriggerAxes = h.TriggerAxes;
h.UDP.UserData.RecruitmentCurveAxes = h.RecruitmentCurveAxes;
h.UDP.configureCallback("terminator", @intan.handleIndexUpdatingCallback);
h.Figure.DeleteFcn = @handleUDPCleanup;
h.Figure.UserData.UDP = h.UDP;

    function handleUDPCleanup(src,~)
        delete(src.UserData.UDP);
    end
end