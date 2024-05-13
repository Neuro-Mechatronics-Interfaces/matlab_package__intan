function [fig, ax, h] = createLineCopy(src, ~)
switch src.UserData.Type
    case 'Amplifier'
        name = sprintf('AMP-%d', src.UserData.Index);
        hTrigs = findobj(src.Parent.Parent.Children,'Tag','TriggerAxes');
        hTrigs.UserData.Index.Channel = src.UserData.Index;
        set(hTrigs.Title,'String',sprintf('E[Ch-%02d]',src.UserData.Index),'Color',src.Color);
        hTrigsLine = findobj(hTrigs.Children,'Type','line');
        hTrigsLine.Color = src.Color;
        hRecruitment = findobj(src.Parent.Parent.Children,'Tag','RecruitmentCurveAxes');
        set(hRecruitment.Title,'String',sprintf('Ch-%02d Recruitment | Frequency_%d',src.UserData.Index,hRecruitment.UserData.FrequencyIndexForCurve),'Color',src.Color);
        hRecruitmentLine = findobj(hRecruitment.Children,'Type','line');
        set(hRecruitmentLine,'MarkerFaceColor', src.Color);
    case 'Analog'
        name = sprintf('ANALOG-%d', src.UserData.Channel);
    case 'Digital'
        name = sprintf('DIG-%02d', log2(src.UserData.Mask)+1);
end
fig = figure('Name', sprintf('%s: Individual Data', name), ...
             'Color', 'w');
ax = axes(fig,'NextPlot','add','FontName','Tahoma','XColor','none');
title(ax, name, "FontName",'Tahoma','Color',src.Color);
h = line(ax, src.XData, src.YData-src.UserData.Offset, 'Color', src.Color, 'LineWidth', 1.5);
if ~isempty(src.Parent.UserData.Sync)
    plot(ax, diff(ax.YLim).*src.Parent.UserData.Sync./src.Parent.UserData.SyncMax+ax.YLim(1),'Color','k','LineStyle',':');
end


end