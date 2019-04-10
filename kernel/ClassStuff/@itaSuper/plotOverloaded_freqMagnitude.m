function h = plotOverloaded_freqMagnitude(this)
% Fast plot routine in frequency domain
% ==> that is part of the overloaded magnitude plot function

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


xVec = this.freqVector;

% check for Pascal as unit and apply reference of 20µPa
for idx = 1:this.nChannels
    if isequal(this.channelUnits{idx},'Pa')
        this.channelUnits{idx} = '20u Pa';
        this.freqData(:,idx) = this.freqData(:,idx)./20e-6;
    end
end

xscale_idx = find(strcmpi(this.plotAxesProperties, 'xscale'));
if ~isempty(xscale_idx) && xscale_idx < length(this.plotAxesProperties) && strcmpi(this.plotAxesProperties{xscale_idx+1}, 'lin')
    plot_func = @plot;
else
    plot_func = @semilogx;
end

if this.allowDBPlot
    h = plot_func(xVec, calcLog(this));
    ylabel('Modulus in dB')
else
    h = plot_func(xVec, this.freqData);
    ylabel('Modulus')

end
% add here other ways to take the logarithm,
% depending on the unit of freqData

YData = get(h,'YData');
if iscell(YData)
    yMax = 0;
    yMin = 1000;
    for i=1:numel(YData)
        yMax = max(yMax,max(YData{i}));
        yMin = min(yMin,min(YData{i}));
    end
else
    yMax = max(max(YData));
    yMin = min(min(YData));
end
set(gca,'XLim', xVec([1 end]))
if yMin < yMax
    set(gca,'YLim', [yMin yMax]);
end
xlabel('Frequency in Hz')


% set the callback function for refreshing the axes
hZoom = zoom;
set(hZoom,'ActionPostCallback',@plot_makeNiceTicks);
set(hZoom,'Enable','on');
hPan = pan;
set(hPan,'ActionPostCallback',@plot_makeNiceTicks);
set(hPan,'Enable','on');
%     hSMR = selectmoveresize;
%     set(hSMR,'ActionPostCallback',@plot_makeNiceTicks);
%     set(hSMR,'Enable','on');

% and call this function se set the ticks imediately
plot_makeNiceTicks;

    function output = calcLog(this)
        output = 20*log10(abs(this.freqData));
    end
end
