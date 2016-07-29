function  varargout = ita_audiometer_chooseCalibration_GUI(varargin)
%ITA_AUDIOMETER_CHOOSECALIBRATION_GUI - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_audiometer_chooseCalibration_GUI(audioObjIn, options)
%
%
%  Example:
%   audioObjOut = ita_audiometer_chooseCalibration_GUI(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_audiometer_chooseCalibration_GUI">doc ita_audiometer_chooseCalibration_GUI</a>

% <ITA-Toolbox>
% This file is part of the application Audiometer for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  11-Feb-2013 


%% load all calib data 

if nargin
    calibData = varargin{1};
    idxStartCalib = varargin{2};
    nCalibs = numel(calibData);
else
    calibFileName = fullfile(fileparts(which(mfilename)), 'calibData.mat');
    if exist(calibFileName, 'file')   % keep old calib information
        calibData = load(calibFileName);
        calibData = calibData.calibDataStruct;
    else
        error('no calib file found')
    end
    
    nCalibs = numel(calibData);
    idxStartCalib = nCalibs;
end 
listBoxCell = cell(nCalibs,1);

for iCalib = 1:nCalibs
    listBoxCell{iCalib} = sprintf('%s %s (%s)',calibData(iCalib).dateOfCalibration,calibData(iCalib).userName, calibData(iCalib).comment   );
end

%%

h.f       = figure('position', [100 66 1300 500],'name', 'Choose calibration', 'toolbar', 'none', 'menubar', 'none',  'numberTitle', 'off', 'nextPlot', 'new',  'CloseRequestFcn', @closeRegFcn);
h.axes    = axes('Parent', h.f, 'outerposition', [6 0 14 20]/ 20);
h.lb_calib = uicontrol('style', 'listbox',    'parent', h.f, 'units', 'normalized', 'position', [1  3 6 16] / 20, 'Callback', @updatePlot,   'string', listBoxCell, 'value', idxStartCalib);
h.pb_okay  = uicontrol('style', 'pushbutton', 'parent', h.f, 'units', 'normalized', 'position', [4 0.5 3 2] / 20, 'Callback', @okayCallback, 'string', 'okay');

% write guiData
gData.h = h;
gData.calibData = calibData;
gData.idxCalib = [];
guidata(h.f, gData)


updatePlot(h.lb_calib, [])


% wait for okay button
uiwait()

% set output and close 
gData = guidata(h.f);
varargout{1} =gData.calibData;
varargout{2} =gData.idxCalib;
delete(h.f)

%end function
end


function updatePlot(s, ~)
gData = guidata(s);

currChoice = get(s, 'value');
% bar(gData.h.axes,  gData.calibData(currChoice).freqVector, gData.calibData(currChoice).dBFS_for_RETSPL+127)
% set(gData.h.axes, 'xscale', 'log')
% set(gData.h.axes, 'YTickLabel',  get(gData.h.axes, 'yTick')-127)

semilogx(gData.h.axes,  gData.calibData(currChoice).freqVector, gData.calibData(currChoice).dBFS_for_RETSPL, 'o-','linewidth', 2)
ylabel(gData.h.axes, 'dbFS to produce RETSPL')
grid(gData.h.axes, 'on')
legend(gData.h.axes, {'left', 'right'})
end


function okayCallback(s,~)
gData = guidata(s);
gData.idxCalib  = get(gData.h.lb_calib, 'value');
guidata(gData.h.f, gData);
uiresume()

end

function closeRegFcn(~,~)
uiresume()
end