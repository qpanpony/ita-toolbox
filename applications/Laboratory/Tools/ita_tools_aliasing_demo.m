function ita_tools_aliasing_demo
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% <ITA-Toolbox>
% This file is part of the application Tools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% data

data.freqRange = [10 450];
data.freqValue = data.freqRange(2)/2;
data.phaseValue = 0;

data.mainSineFreq = 100;
data.masterSamplingFrequency = 44100;
% use 50 waves to calculate the new frequency
data.calculateWaves = 50;
% only plot 5
data.plotWaves = 5;

data.stemPlot = 0;
data.interpolatedPlot = 0;

%% GUI

screenSize = get(0, 'ScreenSize');
screenSize(3) = 1920;
screenSize(4) = 1200;
figSize = screenSize(3:4)*0.9;

h.f = figure('outerposition',  [screenSize(3:4)*0.05  figSize ], 'name', 'ITA Aliasing Demo', 'toolbar', 'none', 'menubar', 'none',  'numberTitle', 'off', 'tag', 'ita_fsp', 'nextPlot', 'new');

h.ax_pos3d       = axes('Parent', h.f, 'outerposition', [-0.1 -0.05 1 1.1]);

% h.tx_resultInfo  = uicontrol('style', 'text', 'parent', h.f, 'units', 'normalized', 'position', [7 /20 1/20  1/5 1/30]);
% h.pb_exportGroup = uicontrol('style', 'pushbutton', 'parent', h.f, 'units', 'normalized', 'position', [7 2  2 1.1]/20, 'callback',@exportGroupPositions, 'string', 'export group');

% h.pb_exportResults = uicontrol('style', 'pushbutton', 'parent', h.f, 'units', 'normalized', 'position', [9.1 2.6  1.8 0.5]/20, 'callback',@exportSearchResult, 'string', 'export  all results');

h.freqSlider = uicontrol('style', 'slider', 'parent', h.f, 'units', 'normalized', 'position', [17 11  1.8 0.5]/20, 'callback',@freqSliderCallback);
h.freqEdit = uicontrol('style', 'edit', 'parent', h.f, 'units', 'normalized', 'position', [17 10.4  1.8 0.5]/20,'string',num2str(data.freqValue) , 'callback',@freqEditCallback);
h.hzText = uicontrol('style', 'text', 'parent', h.f, 'units', 'normalized', 'position', [18.45 10.5  0.3 0.3]/20,'string','Hz');
h.freqInfoText = uicontrol('style', 'text', 'parent', h.f, 'units', 'normalized', 'position', [17 11.5  1.8 0.3]/20,'string','Sampling Frequency');

set(h.freqSlider,'Interruptible','off');
set(h.freqSlider,'Min',data.freqRange(1));
set(h.freqSlider,'Max',data.freqRange(2));
set(h.freqSlider,'Value',data.freqValue);

h.phaseSlider = uicontrol('style', 'slider', 'parent', h.f, 'units', 'normalized', 'position', [17 9  1.8 0.5]/20, 'callback',@phaseSliderCallback);
h.phaseEdit = uicontrol('style', 'edit', 'parent', h.f, 'units', 'normalized', 'position', [17 8.4  1.8 0.5]/20,'string','0');
h.hzText = uicontrol('style', 'text', 'parent', h.f, 'units', 'normalized', 'position', [18.48 8.5  0.3 0.3]/20,'string','°');
h.phaseInfoText = uicontrol('style', 'text', 'parent', h.f, 'units', 'normalized', 'position', [17 9.5  1.8 0.3]/20,'string','Phase');

set(h.phaseSlider,'Interruptible','off');
set(h.phaseSlider,'Min',0);
set(h.phaseSlider,'Max',360);
set(h.phaseSlider,'Value',0);


h.interpolatedEdit = uicontrol('style', 'edit', 'parent', h.f, 'units', 'normalized', 'position', [17 7  1.8 0.5]/20,'string','');

h.interpolatedInfoText = uicontrol('style', 'text', 'parent', h.f, 'units', 'normalized', 'position', [17 7.5  1.8 0.3]/20,'string','Reconstructed Sine');
h.hzText = uicontrol('style', 'text', 'parent', h.f, 'units', 'normalized', 'position', [18.45 7.1  0.3 0.3]/20,'string','Hz');


h.samplingCheckbox = uicontrol('style', 'checkbox', 'parent', h.f, 'units', 'normalized', 'position', [17 13  1.8 0.5]/20,'string','Plot sampling points' , 'callback',@samplingCheckboxCallback);
h.reconstructedCheckbox = uicontrol('style', 'checkbox', 'parent', h.f, 'units', 'normalized', 'position',   [17 12.5  1.8 0.5]/20,'string','Plot reconstructed sine' , 'callback',@reconstructedCheckboxCallback);

data.plotSampling = 0;
data.plotReconstructed = 0;

guiData.handles = h;
guiData.data    = data;



guidata(h.f, guiData)


populateGUI(guiData)

end


function populateGUI(guiData)

    data = guiData.data;
    h = guiData.handles;

    % only plot the main sine here, the rest is done in "newPlot"
    masterSamplingFreq = data.masterSamplingFrequency;
    sineFreq = 100;
    sine = ita_generate('sine',1,sineFreq,masterSamplingFreq,15);

    calculateWaves = data.calculateWaves;
    plotWave = data.plotWaves;
    % plot only the first plotWaves waves
    sineTime = sine.timeData;
    % cut to 5 waves
    sineTime = sineTime(1:(calculateWaves/sineFreq*masterSamplingFreq));

    data.sinePlot = plot(h.ax_pos3d,sineTime,'LineWidth',4);
    hold all
    data.xAxis = 1:size(sineTime);
    
    xlim([0 (plotWave/sineFreq*masterSamplingFreq)])
    
    % set latex x-labels
    xLabel = 0:1/2:plotWave;
    xLabel = arrayfun(@num2str,xLabel,'Uniform',false);
    xLabel = strcat(xLabel,' $\lambda$');
    set(h.ax_pos3d,'Xtick',0:masterSamplingFreq/(2*sineFreq):plotWave*masterSamplingFreq/sineFreq, 'XTickLabel', '','XGrid','on')
    set(h.ax_pos3d,'YTickLabel',[]);
    for idxName = 1:numel(xLabel)
        text((idxName-1)*masterSamplingFreq/(2*sineFreq), -1.15, xLabel{idxName}, 'HorizontalAlignment', 'center', 'verticalAlignment', 'baseline','Fontsize',20,'interpreter', 'latex')
    end
    
    
    % format
    xlim([0 (plotWave/sineFreq*masterSamplingFreq)])
    ylim([-1.1 1.1])
    
    data.sineTime = sineTime;
    
    guiData.data = data;
    
    guiData = newPlot(guiData);
    guidata(h.f, guiData)

end


% this function is called whenever something changes
% first: the old plots are deleted
function guiData = newPlot(guiData)
    data = guiData.data;
    h = guiData.handles;
    % delete old plots
    if data.stemPlot ~= 0
        delete(data.stemPlot);
        data.stemPlot = 0;
    end
    
    if data.interpolatedPlot ~= 0
       delete(data.interpolatedPlot);
       data.interpolatedPlot = 0;
    end
    
    
    masterSamplingFreq = data.masterSamplingFrequency;
    calculateWaves = data.calculateWaves;
    plotWave = data.plotWaves;
    
    % get the values from the text edits
%     sineFreq = str2double(get(data.sineFreqEdit,'String'));
    sineFreq = data.mainSineFreq;
    samplingFreq = data.freqValue;
    
    % the sampling points
    samplingPoints = (0:(calculateWaves*samplingFreq/sineFreq)-1)*1/samplingFreq*masterSamplingFreq;
    % mod to avoid overflow (+1 to avoid 0)
    samplingPoints = mod(samplingPoints + data.phaseValue./360* masterSamplingFreq/sineFreq,length(data.sineTime))+1;
    sampledSine = zeros(size(data.sineTime));
    sampledSine(round(samplingPoints)) = data.sineTime(round(samplingPoints));
    % the positions of the sampling points
    x = round(samplingPoints);
    % and the values
    y = sampledSine(round(samplingPoints));

    if (data.plotSampling)
        % stem plot
        data.stemPlot = stem(x,y,'LineWidth',2,'Color',[0 0.5000 0]);
        % set(get(h,'Baseline'),'Visible','off')
    end

    if (data.plotReconstructed)
        % fit the sampling points to a new wave and plot if a fit is found
        [f,gof] = fit( x.', y, 'sin1');
        if (abs(gof.rsquare - 1)) < 0.1 % good fit
            x2 = data.xAxis;
            data.interpolatedPlot = plot(h.ax_pos3d,x2,f.a1*sin(f.b1*x2+f.c1),'Color','r');

            % calculate new frequency from interpolated values
            newFreq = f.b1*masterSamplingFreq./(2*pi);    
            set(h.interpolatedEdit,'String',num2str(round(newFreq)))
        else
            set(h.interpolatedEdit,'String','No fit')  
        end
    end
    
    guiData.data = data;
    
    
end


function freqSliderCallback(hObject, ~)
    guiData = guidata(hObject);
    
    % calculate the frequency from the value and the data.freqRange
    realValue = get(hObject,'Value');
    guiData.data.freqValue = round(realValue);
    set(guiData.handles.freqEdit,'string',num2str(guiData.data.freqValue));
    guiData = newPlot(guiData);
    
    guidata(hObject, guiData);
    

end

function freqEditCallback(hObject,~)
    guiData = guidata(hObject);
    
    % calculate the frequency from the value and the data.freqRange
    guiData.data.freqValue = str2double(get(hObject,'String'));
    set(guiData.handles.freqEdit,'string',num2str(guiData.data.freqValue));
    guiData = newPlot(guiData);
    
    guidata(hObject, guiData);
end


function phaseSliderCallback(hObject, ~)

    guiData = guidata(hObject);
    
    % calculate the frequency from the value and the data.freqRange
    realValue = get(hObject,'Value');
    guiData.data.phaseValue = round(realValue);
    set(guiData.handles.phaseEdit,'string',num2str(guiData.data.phaseValue));
    guiData = newPlot(guiData);
    
    guidata(hObject, guiData);

end

function samplingCheckboxCallback(hObject,~)
    guiData = guidata(hObject);
    
    % calculate the frequency from the value and the data.freqRange
    realValue = get(hObject,'Value');
    guiData.data.plotSampling = realValue;
    guiData = newPlot(guiData);
    
    guidata(hObject, guiData);
end

function reconstructedCheckboxCallback(hObject,~)
    guiData = guidata(hObject);
    
    % calculate the frequency from the value and the data.freqRange
    realValue = get(hObject,'Value');
    guiData.data.plotReconstructed = realValue;
    guiData = newPlot(guiData);
    
    if (realValue == 0)
       set(guiData.handles.interpolatedEdit,'String','')   
    end
    guidata(hObject, guiData);
end
