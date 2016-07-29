function [redoFreq addFreq] = ita_audiometer_redoFreq(freqAlreadyDone)


% <ITA-Toolbox>
% This file is part of the application Audiometer for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%%
h.possibleFreq = [ 125 160 200 250 315 400 500 630 750 800 1000 1250 1500 1600 2000 2500 3000 3150 4000 5000 6000 6300 8000];
[~, ~,  idxFreqDone]= intersect(freqAlreadyDone, h.possibleFreq);


screenSize = get(0, 'ScreenSize');
figSize = [500 600];

% TODO: , 'WindowStyle ', 'modal'
h.f = figure('outerposition',  [(screenSize(3:4)-figSize)/2 figSize ], 'name', 'ita_audiometer_redo', 'toolbar', 'none', 'menubar', 'none',  'numberTitle', 'off', 'nextPlot', 'new');%, 'CloseRequestFcn', @CloseRequestFcn);

h.pa_freq  = uipanel( h.f, 'units', 'normalized', 'position', [0.55  0.09  0.4 0.9],'title', 'Add frequencies');
[h.cb_redoFreq, h.cb_addFreq] = deal(zeros(size(h.possibleFreq)));
helperCell = {'off' 'on'};
for iFreq = 1:numel(h.possibleFreq)
    linePos = 0.95 * (1 - (iFreq/numel(h.possibleFreq))) + 0.025;
    h.cb_addFreq(iFreq) =  uicontrol('style', 'checkbox', 'parent', h.pa_freq, 'units', 'normalized', 'position', [0.1  linePos 0.8  0.05], 'string', sprintf('%i Hz', h.possibleFreq(iFreq)), 'enable',helperCell{2-any(iFreq == idxFreqDone)});
end

h.pa_freq  = uipanel( h.f, 'units', 'normalized', 'position', [0.05  0.09  0.4 0.9],'title', 'Redo frequencies');
for iFreq = 1:numel(h.possibleFreq)
    linePos = 0.95 * (1 - (iFreq/numel(h.possibleFreq))) + 0.025;
    h.cb_redoFreq(iFreq) =  uicontrol('style', 'checkbox', 'parent', h.pa_freq, 'units', 'normalized', 'position', [0.1  linePos 0.8  0.05], 'string', sprintf('%i Hz', h.possibleFreq(iFreq)),  'enable', helperCell{1+any(iFreq == idxFreqDone)});
end

h.pb_cancel = uicontrol('style', 'pushbutton', 'parent', h.f, 'string', 'Cancel', 'units', 'normalized', 'position', [0.82 0.01 0.15 0.07], 'callback', @cancelCallback);
h.pb_start = uicontrol('style', 'pushbutton', 'parent', h.f, 'string', 'Start', 'units', 'normalized', 'position', [0.62 0.01 0.18 0.07], 'callback', @okayCallback);

h.addFreq = [];
h.redoFreq = [];

guidata(h.f, h)

uiwait()

h = guidata(h.f);
redoFreq = h.redoFreq;
addFreq = h.addFreq;
close(h.f)

end


function okayCallback(s, ~)
h = guidata(s);

h.addFreq = h.possibleFreq( cell2mat(get(h.cb_addFreq, 'value')) == 1);
h.redoFreq = h.possibleFreq( cell2mat(get(h.cb_redoFreq, 'value')) == 1);

guidata(h.f, h);
uiresume
end



function cancelCallback(~)
uiresume
end

