function varargout = ita_robocontrol(varargin)
%ITA_ROBOCONTROL - Send Settings to ITA Robo Frontend
%  This function sends Midi Sysex Commands to the ITA Robo Frontend using
%  PortMidi. The parameters are strings according to the labels on the
%  front.
%
%  Syntax: ita_robocontrol(InputRange,Mode,OutputRange)
%
%  InputRange can be '+40dB','+20dB','0dB','-20dB','-40dB'
%
%  Mode can be 'Norm','Imp','10Ohm','LineRef','AmpRef'
%
%  OutputRange can be '20dBu' or '0dBu'
%
%  If no parameters are specified ita_robocontrol() the gui
%  ita_robocontrolcenter_gui will be automatically called
%
%   See also ita_fft, ita_ifft, ita_ita_read, ita_ita_write, ita_metainfo_rm_channelsettings, ita_metainfo_add_picture, ita_impedance_parallel, ita_plot_surface, ita_deal_units, ita_impedance2apparementmass, ita_measurement_setup, ita_measurement_run, ita_RS232_ITAlian_init, ita_measurement_polar, ita_parse_arguments, ita_vibro_vivo, ita_getFrequencyBins.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_robocontrol">doc ita_robocontrol</a>

% <ITA-Toolbox>
% This file is part of the application RoboAurelioModulITAControl for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created: 06-Jan-2009
% Edited:  17-jun-2009 - pdi - output bool (run successful or not)

%% TODO % Device ID for Midi and close midi port when gui closes

%% Track old settings
persistent oldInputRange
persistent oldMode
persistent oldOutputRange
persistent status_mmidi_open;
if isempty(status_mmidi_open)
    status_mmidi_open = false;
end

%% Initialization
% number of input arguments
narginchk(0,3);

if nargin == 0
    [a,b,c] = ita_robocontrol('getsettings');
    %     status_ok = ita_robocontrol(a,b,c);
    if ~isempty(a) %   status_ok
        ita_robocontrolcenter_gui();
        return; %pdi, just close it down?
    else
        h = errordlg('Sorry, could not reach your device with PortMidi correctly.', 'ita_robocontrol', 'modal');
        uiwait(h);
        return;
    end
elseif nargin == 1
    if strcmpi(varargin{1},'getSettings')
        if ~isempty(oldInputRange)
            varargout={oldInputRange, oldMode, oldOutputRange};
        else
            try 
                ita_robocontrol('0','norm','0');
                [varargout{1}, varargout{2}, varargout{3}] = ita_robocontrol('getSettings');
            catch %#ok<CTCH>
                ita_verbose_info('Robo is not initialized!',0);
                varargout={[],[],[]};
            end
        end
        return
    end
elseif nargin == 3
    
    
elseif nargin ~= 3
        error('ITA_ROBOCONTROL:Oh Lord please see syntax!')
end

if nargout == 1
    varargout{1} = false; %standard: function did not work properly
end

if nargin
    
    if ischar(varargin{1}) || isnumeric(varargin{1}) %huhu isnumeric will not work in that way
        InputRange = varargin{1};
    else
        error('ITA_ROBOCONTROL:Oh Lord please see syntax for input range!')
    end
    
    if ischar(varargin{2}) || isnumeric(varargin{2})
        Mode = varargin{2};
    else
        error('ITA_ROBOCONTROL:Oh Lord please see syntax for input range!')
    end
    
    if ischar(varargin{3}) || isnumeric(varargin{3})
        OutputRange = varargin{3};
    else
        error('ITA_ROBOCONTROL:Oh Lord please see syntax for input range!')
    end
end


%% build up sysex command
sysex = [105 0 0]; %standard values
if isnumeric(InputRange)
    InputRange = num2str(InputRange);
end
switch lower(InputRange)
    case {'+40db','40db','40'}
        InputRange = 40;
        sysex = sysex + [0 0 15];
    case {'+20db','20db','20'}
        InputRange = 20;
        sysex = sysex + [0 2 13];
    case {0, '+0db', '0db', '0'}
        InputRange = 0;
        sysex = sysex + [0 4 11];
    case {'-20db','-20'}
        InputRange = -20;
        sysex = sysex + [0 6 9];
    case {'-40db','-40'}
        InputRange = -40;
        sysex = sysex + [0 8 7];
    otherwise
        error('ITA_ROBOCONTROL:Input Range unknown!')
end

switch lower(Mode)
    case {'norm',0}
        Mode = 'norm';
        sysex = sysex + [0 0 7*16];
    case {'imp'}
        Mode = 'imp';
        sysex = sysex + [0 16 6*16];
    case {'10ohm','10ohms','10ohmcal'}
        Mode = '10ohm';
        sysex = sysex + [0 2*16 5*16];
    case {'lineref'}
        Mode = 'lineref';
        sysex = sysex + [0 3*16 4*16];
    case {'ampref'}
        Mode = 'ampref';
        sysex = sysex + [0 4*16 3*16];
    otherwise
        error('ITA_ROBOCONTROL:Mode Range unknown!')
end

switch lower(OutputRange(OutputRange  ~= ' ' ))
    case {'+20dbu','+20db','20dbu','20db','20',20}
        OutputRange = 20;
        sysex = sysex + [0 0 0];
    case { 0, '+0dbu', '+0db', '0dbu', '0db', '0'}
        OutputRange = 0;
        sysex = sysex + [0 1 -1];
    case 'test'
        sysex = [105 5 122];
    otherwise
        error('ITA_ROBOCONTROL:Output Range unknown!')
end

%% send sysex
sysex = [240 sysex 247]; %pre- post- ampel
ita_midi(sysex,ita_preferences('out_midi_DeviceID'));

%% Store old values
oldInputRange = InputRange;
oldMode = Mode;
oldOutputRange = OutputRange;


varargout{1} = true; %run successful

%end function
end