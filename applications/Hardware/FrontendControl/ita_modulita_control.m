function varargout = ita_modulita_control(varargin)
%ITA_MODULITA_CONTROL - Send Settings to ModulITA Frontend
%  This function sends Midi Sysex Commands to the ModulITA frontend, also
%  known as Kuddelmuddel ITA (KMI) in Monkey Forest.
%
%  Syntax:
%      ita_modulita_control() - GUI
%      ita_modulita_control(ch_id, parameter, value)
%
%  Options:
%        'davalome' (1,xx)                              :      set output volume
%        'mode' ('norm','impref','ampref','lineref')    :      Predefined settings
%        'clock' ('hdsp',SamplingRate)                  :      hdsp sets soundcard to master clock
%                                                               if SamplingRate given, ModulITA is the master clock
%        'inputrange' (-40:10:60)                       :      input range for preamp select
%        'channel' (1..4, 'all')                        :      select the channel to modify
%        'input' ('xlr','gnd','ref','lemo')             :      select input type for preamp
%        'feed' ('off','pha','pol','p+p')               :      phantom/polarization voltage
%        'lemo' ('d14','s28','d44')                     :      polarization voltage type
%        'init' ('on')                                  :      Initialize ModulITA to good settings
%
%
%
%  If no parameters are specified ita_modulita_control() the gui
%  ita_modulita_control_gui will be automatically called
%
%   See also ita_modulita_control.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_modulita_control">doc ita_modulita_control</a>

% <ITA-Toolbox>
% This file is part of the application RoboAurelioModulITAControl for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  11-Sep-2009 - pdi

if nargin == 0
    ita_modulitacontrol_gui()
    return;
end
if nargout >= 1
    varargout{1} = [];
end

%% Get ITA Toolbox preferences
verboseMode = false; %ita_preferences('verboseMode');
thisFuncStr = [upper(mfilename) ':'];
persistent oldSettings %store the values that have been sent to modulita

%% Argument parsing
narginchk(0,10);
sArgs        = struct('mode',[], 'clock',[],'inputrange',[],'channel','all','input',[],'feed',[],'lemo',[],'admode',[],...
    'init',false,'davolume',[],'adground2earth',[],'daground2earth',[],'adcoupling',[],'refbus2preamp',[],'preampcoupling',[],...
    'preampoffset',[],'phantomxlr',false,'parameterrequest',false,'getSettings','false');
[sArgs] = ita_parse_arguments(sArgs,varargin);

%% init modulita
if isempty(oldSettings) && ~sArgs.init %probably first start of the session or clear all has been used
    %just resend the init commando
    oldSettings.ch(1).inputrange = 1;
    oldSettings.mode = 'norm';
    ita_modulita_control('init');
end

% get midi port and open midi output stream
out_device_id = ita_preferences('out_midi_DeviceID');
if isempty(out_device_id) || out_device_id == -1
    errordlg('No valid Midi output device specified. Call ita_preferences().', 'ita_modulita_control - Midi Error');
    return;
end

%% generate message
preamble = '00 20 40 00 00 07';
message_hex = {};

if sArgs.parameterrequest
    % %     %dsp tools
    % %     preamble = '00 20 40 00 00 0c 00';
    % %     message_hex = {'00 02 00 00 00 00 00'};
    
    preamble = '00 20 40 00 00 0c';
    message_hex = {'08 09 ff ff 00 00'};
    
end

%% INIT commando to be sent to ModulITA/KMI
if sArgs.init
    
    %% conversion to Swen's Documentation
    %      hex2dec('50')-64
    % dec2hex(87+64)
    
    %      message_hex{end+1} = '04 00 00 00'; %default setup
    sArgs.clock = 'hdsp';
    %
    
    %%     message_hex{end+1} = '04 02 07 0f'; % ????
    % %     message_hex{end+1} = '04 03 07 0F';
    % %     message_hex{end+1} = '04 04 07 0F';
    % %     message_hex{end+1} = '05 00 00 00';
    % %     message_hex{end+1} = '05 01 00 00';
    % %     message_hex{end+1} = '05 02 00 00';
    % %     message_hex{end+1} = '05 03 00 00';
    
    
    
    %AD INPUT Init
    message_hex{end+1} = '05 0c 00 00';
    message_hex{end+1} = '05 0d 00 00';
    message_hex{end+1} = '05 0e 00 00';
    message_hex{end+1} = '05 0f 00 00';
    
    %%AD attenuation init to -19dB
    message_hex{end+1} = '06 00 00 00'; %ad1
    message_hex{end+1} = '06 01 00 00'; %ad3
    
    %%AD impedance INIT
    message_hex{end+1} = '06 02 00 00'; %ad0/1
    message_hex{end+1} = '06 03 00 00'; %ad2/3
    
    %%preamp offset  %off/sta/dyn  /0a/0b/1a/1b
    sArgs.preampoffset   = 'dyn';
    sArgs.inputrange     = 0;
    sArgs.inputfeed      = 'off';
    % preamp coupling AC/DC
    sArgs.preampcoupling = 'ac';
    sArgs.adcoupling     = 'dc';
    
    %AD OUT - Rout - ROUTING - STAY AWAY !!!
    message_hex{end+1} = '08 07 00 01';
    message_hex{end+1} = '08 08 00 02';
    message_hex{end+1} = '08 09 00 00';
    message_hex{end+1} = '08 0a 00 03';
    
    sArgs.refbus2preamp = 0;
    sArgs.mode         = 'normal';
    sArgs.input        = 'xlr';
    sArgs.feed         = 'off';
    
    % % message_hex{end+1} = '08 0d 00 00'; %Bekezy starten
    
    %amp out - LOAD - A: 10 ohm/external
    message_hex{end+1} = '09 02 00 01'; %A
    message_hex{end+1} = '09 03 00 01'; %A
    
    %amp out - GND - Ground/shunt
    message_hex{end+1} = '09 04 00 00'; %A
    message_hex{end+1} = '09 05 00 00'; %A
    
    %amp volume relative to DA - dBrel
    message_hex{end+1} = '09 06 05 06'; %A
    
    %amp out - off/da1/da2
    message_hex{end+1} = '09 07 00 02'; %pdi
    
    % % %     message_hex{end+1} = '04 00 00 00'; %default setup - store
    % % %     message_hex{end+1} = '05 01 00 00'; %default setup - setup Number 1
    
    % message_hex{end+1} = '05 05 0f 0f'; %security mode - for menu
    % message_hex{end+1} = '05 06 0f 0f'; %security mode - for menu
    sArgs.davolume = 0;
    sArgs.channel = 'all';
    sArgs.inputrange = 0;
end

%% Phantom and XLR shortcut
if sArgs.phantomxlr
    sArgs.input = 'xlr';
    sArgs.feed = 'pha';
end

%% **************************************************** pdi

%% AD coupling
if sArgs.adcoupling
    switch lower(sArgs.channel)
        case {'1',1}
            ch_hex{1} = '08';
        case {'2',2}
            ch_hex{1} = '09';
        case {'3',3}
            ch_hex{1} = '0a';
        case {'4',4}
            ch_hex{1} = '0b';
        case {'all'}
            ch_hex = {'08','09','0a','0b'};
        otherwise
            error([thisFuncStr 'Channel setting unknown.'])
    end
    %     message_hex{end+1} = '05 08 00 01'; %AD-coupling 0 : dc 1 : ac ch:ad0
    switch lower(sArgs.adcoupling)
        case {'ac'}
            adda_hex = '01';
        case {'dc'}
            adda_hex = '00';
        otherwise
            error([thisFuncStr 'AD coupling mode unknown'])
    end
    for ch_idx = 1:length(ch_hex)
        message_hex{end+1} = ['05 ' ch_hex{ch_idx} ' 00 ' adda_hex]; %#ok<AGROW> %AD-coupling 0 : dc 1 : ac ch:ad0
    end
end

%% Preamp coupling
if sArgs.preampcoupling
    switch lower(sArgs.channel)
        case {'1',1}
            ch_hex{1} = '01';
        case {'2',2}
            ch_hex{1} = '02';
        case {'3',3}
            ch_hex{1} = '03';
        case {'4',4}
            ch_hex{1} = '04';
        case {'all'}
            ch_hex = {'01','02','03','04'};
        otherwise
            error([thisFuncStr 'Channel setting unknown.'])
    end
    switch lower(sArgs.preampcoupling)
        case {'ac'}
            adda_hex = '00';
        case {'dc'}
            adda_hex = '01';
        otherwise
            error([thisFuncStr 'Preamp coupling mode unknown'])
    end
    for ch_idx = 1:length(ch_hex)
        message_hex{end+1} = ['07 ' ch_hex{ch_idx} ' 00 ' adda_hex]; %#ok<AGROW> %AD-coupling 0 : dc 1 : ac ch:ad0
    end
end

%% Preamp offset
if ~isempty(sArgs.preampoffset)
    switch lower(sArgs.channel)
        case {'1',1}
            ch_hex{1} = '09';
        case {'2',2}
            ch_hex{1} = '0a';
        case {'3',3}
            ch_hex{1} = '0b';
        case {'4',4}
            ch_hex{1} = '0c';
        case {'all'}
            ch_hex = {'09','0a','0b','0c'};
        otherwise
            error([thisFuncStr 'Channel setting unknown.'])
    end
    switch lower(sArgs.preampoffset)
        case {'off',0}
            adda_hex = '00';
        case {'sta','static'}
            adda_hex = '01';
        case {'dyn','dynamic'}
            adda_hex = '02';
            
        otherwise
            error([thisFuncStr 'Preamp offset mode unknown'])
    end
    %     message_hex{end+1} = '06 09 00 02';
    %     message_hex{end+1} = '06 0a 00 02';
    %     message_hex{end+1} = '06 0b 00 02';
    %     message_hex{end+1} = '06 0c 00 02';
    for ch_idx = 1:length(ch_hex)
        message_hex{end+1} = ['06 ' ch_hex{ch_idx} ' 00 ' adda_hex]; %#ok<AGROW> %AD-coupling 0 : dc 1 : ac ch:ad0
    end
end

%% **************************************************** pdi
%% DA Volume in dBFS
if ~isempty(sArgs.davolume)
    sArgs.davolume = max(min(sArgs.davolume,0),-127);
    davol_hex = ita_angle2str(dec2hex(sArgs.davolume +127),2);
    message_hex{end+1} = ['04 01 0' davol_hex(1) '0' davol_hex(2)]; %da volume -127
    oldSettings.davolume = sArgs.davolume;
end
%% AD/DA ground to earth
if ~isempty(sArgs.adground2earth)
    message_hex{end+1} = ['0A 00 00 0' num2str(sArgs.adground2earth)];
end
if ~isempty(sArgs.daground2earth)
    message_hex{end+1} = ['0A 01 00 0' num2str(sArgs.daground2earth)];
end

%% **************************************************** pdi
%% clock origin HDSP
if sArgs.clock
    if isnumeric(sArgs.clock), sArgs.clock = num2str(sArgs.clock); end
    switch lower(sArgs.clock)
        case 'hdsp'
            %hdsp
            message_hex{end+1} = '07 0D 00 04';
        case {'32k','32000'}
            %32k - kmi is master
            message_hex{end+1} = '07 0D 00 00';
        case {'44k','44100'}
            %44k
            message_hex{end+1} = '07 0D 00 01';
        case {'48k','48000'}
            %48k
            message_hex{end+1} = '07 0D 00 02';
        case {'96k','96000'}
            %96k
            message_hex{end+1} = '07 0D 00 03';
        otherwise
            error([thisFuncStr 'clock setting unknown.'])
    end
end

%% **************************************************** pdi
%% mode - AD input from reference line
if sArgs.mode
    switch lower(sArgs.mode)
        case {'normal','norm'}
            oldSettings.mode = 'norm';
            message_hex{end+1} = '06 05 00 02';
            message_hex{end+1} = '06 06 00 02';
            message_hex{end+1} = '06 07 00 02';
            message_hex{end+1} = '06 08 00 00';
            message_hex{end+1} = '09 02 00 01';
            message_hex{end+1} = '09 03 00 01';
        case {'imp','impedance'}
            oldSettings.mode = 'imp';
            message_hex{end+1} = '05 0C 00 00';
            message_hex{end+1} = '05 0D 00 01';
            message_hex{end+1} = '05 0E 00 01';
            message_hex{end+1} = '05 0F 00 00';
            message_hex{end+1} = '06 02 00 01';
            message_hex{end+1} = '06 03 00 01';
            message_hex{end+1} = '06 04 00 00';
            message_hex{end+1} = '06 05 00 00';
            message_hex{end+1} = '06 06 00 00';
            message_hex{end+1} = '06 07 00 00';
            message_hex{end+1} = '08 07 00 02';
            message_hex{end+1} = '08 08 00 03';
            message_hex{end+1} = '08 09 00 02';
            message_hex{end+1} = '08 0A 00 03';
            message_hex{end+1} = '09 02 00 01';
            message_hex{end+1} = '09 03 00 01';
            message_hex{end+1} = '09 04 00 01';
            message_hex{end+1} = '09 05 00 01';
            
        case {'impref'}
            oldSettings.mode = 'impref';
            % % imp ref
            % F0 00 20 40 00 00 07 00  00 09 02 00 00 00 00 00  |   @            |
            % 10  00 09 03 00 00 00 00 F7
            message_hex{end+1} = '09 02 00 00';
            message_hex{end+1} = '09 03 00 00';
            
        case {'lineref'}
            oldSettings.mode = 'lineref';
            % F0 00 20 40 00 00 07 00  00 05 0C 00 01 00 00 00
            % 00 05 0D 00 00 00 00 00  00 05 0E 00 00 00 00 00
            % 00 05 0F 00 01 00 00 00  00 06 02 00 00 00 00 00
            % 00 06 03 00 00 00 00 00  00 06 04 00 03 00 00 00
            % 00 06 06 00 03 00 00 00  00 06 08 00 01 00 00 00
            % 00 08 07 00 01 00 00 00  00 08 08 00 00 00 00 00
            % 00 08 09 00 01 00 00 00  00 08 0A 00 00 00 00 00
            % 00 09 02 00 01 00 00 00  00 09 03 00 01 00 00 00
            % 00 09 04 00 00 00 00 00  00 09 05 00 00 00 00
            
            message_hex{end+1} = '05 0C 00 01';
            message_hex{end+1} = '05 0D 00 00';
            message_hex{end+1} = '05 0E 00 00';
            message_hex{end+1} = '05 0F 00 01';
            message_hex{end+1} = '06 02 00 00';
            message_hex{end+1} = '06 03 00 00';
            message_hex{end+1} = '06 04 00 03';
            message_hex{end+1} = '06 06 00 03';
            message_hex{end+1} = '06 08 00 01';
            message_hex{end+1} = '08 07 00 01';
            message_hex{end+1} = '08 08 00 00';
            message_hex{end+1} = '08 09 00 01';
            message_hex{end+1} = '08 0A 00 00';
            message_hex{end+1} = '09 02 00 01';
            message_hex{end+1} = '09 03 00 01';
            message_hex{end+1} = '09 04 00 00';
            message_hex{end+1} = '09 05 00 00';
            sArgs.input = 'ref';
            sArgs.channel = 'all';
            sArgs.refbus2preamp = '1a';
        case {'ampref'}
            oldSettings.mode = 'ampref';
            %% amp ref
            % F0 00 20 40 00 00 07 00  00 06 08 00 05 00 00 F7
            message_hex{end+1} = '06 08 00 05';
            
            sArgs.input = 'ref';
            sArgs.channel = 'all';
            
        otherwise
            error([thisFuncStr 'clock setting unknown.'])
    end
end

%% Input Range
if ~isempty(sArgs.inputrange)
    %     -40 -> 0
    %     60 -> 6
    % % %% Input Range
    % % %                                          ch    sens
    % % % ch: 09 0A 0B 0C in SysEx
    % % % ch: 0a 0b 1a 1b
    switch lower(sArgs.channel)
        case {'2','0b',2}
            ch_hex{1} = '09';
            ch_idx = 2;
        case {'4','1b',4}
            ch_idx = 4;
            ch_hex{1} = '0a';
        case {'1','1a',1}
            ch_idx = (1);
            ch_hex{1} = '0b';
        case {'3','0a',3}
            ch_idx = 3;
            ch_hex{1} = '0c';
        case {'all'}
            ch_idx = 1:4;
            ch_hex = {'09','0a','0b','0c'};
        otherwise
            error([thisFuncStr 'Channel unknown.'])
    end
    sArgs.inputrange = max(min(sArgs.inputrange,40),-60);
    range_hex = ['0' dec2hex(abs(sArgs.inputrange/10-4))];
    
    for ch_jdx = 1:length(ch_hex)
        message_hex{end+1} = ['07 ' ch_hex{ch_jdx} ' 00 ' range_hex]; %#ok<AGROW>
        oldSettings.ch(ch_idx(ch_jdx)).inputrange = sArgs.inputrange;
    end    % %
end

%% **************************************************** pdi
%% AD mode
if sArgs.admode
    switch lower(sArgs.admode)
        case {'normal','norm','2channel'}
            message_hex{end+1} = '05 0C 00 00';
            message_hex{end+1} = '05 0F 00 00';
            message_hex{end+1} = '08 08 00 02';
            message_hex{end+1} = '08 09 00 00';
            message_hex{end+1} = '08 0A 00 03';
            message_hex{end+1} = '08 0B 00 00';
            message_hex{end+1} = '08 0C 00 00';
            
            
        case {'2-range','2range','stacked'}
            message_hex{end+1} = '05 0c 00 01';
            message_hex{end+1} = '05 0F 00 01';
            message_hex{end+1} = '06 00 00 01';
            message_hex{end+1} = '06 01 00 01';
            message_hex{end+1} = '08 08 00 00';
            
            message_hex{end+1} = '08 09 00 01';
            message_hex{end+1} = '08 0A 00 00';
            message_hex{end+1} = '08 0B 00 01';
            message_hex{end+1} = '08 0C 00 01';
            
            
        case {'parmono','par.mono','parallel'}
            message_hex{end+1} = '06 00 00 00';
            message_hex{end+1} = '06 01 00 00';
            message_hex{end+1} = '08 0B 00 02';
            message_hex{end+1} = '08 0C 00 02';
            
        otherwise
            error([thisFuncStr 'ADmode setting unknown.'])
    end
end %pdi

%% **************************************************** pdi
%% Input selection
if ~isempty(sArgs.input)
    switch lower(sArgs.channel)
        case {'2','0a',2}
            ch_hex{1} = '04';
            ch_idx = 2;
        case {'4','0b',4}
            ch_hex{1} = '05';
            ch_idx = 4;
        case {'1','1a',1}
            ch_hex{1} = '06';
            ch_idx = 1;
        case {'3','1b',3}
            ch_hex{1} = '07';
            ch_idx = 3;
        case {'all'}
            ch_hex = {'04','05','06','07'};
            ch_idx = 1:4;
        otherwise
            error([thisFuncStr 'Channel setting unknown.'])
    end
    
    switch lower(sArgs.input)
        
        case {'gnd','off',0}
            input_hex = '00';
            sArgs.input = 'gnd';
        case {'lemo','lem'}
            input_hex = '01';
            sArgs.input = 'lemo';
        case {'xlr'}
            input_hex = '02';
            sArgs.input = 'xlr';
        case {'ref','reference'}
            sArgs.input = 'ref';
            input_hex = '03';
        otherwise
            error([thisFuncStr 'Input setting unknown.'])
    end
    
    % % %     message_hex{end+1} = '06 04 00 04'; %ad3 GND/Lem/XLR/REF
    for ch_jdx = 1:length(ch_hex)
        message_hex{end+1} = ['06 ' ch_hex{ch_jdx} ' 00 ' input_hex]; %#ok<AGROW>
        oldSettings.ch(ch_idx(ch_jdx)).inputselect = sArgs.input;
    end
end

%% **************************************************** pdi
%% phantom power mode
if ~isempty(sArgs.feed)
    % % %     %% phantom
    % % %     %xlr 48v ch1 on, lemo off lemo sup 14V
    % % %
    % % %      06 0F 00 02 on
    % % %      06 0F 00 00 off
    % % %      lemo power
    % % %      06 0F 00 01 on
    % % %      06 0F 00 00 off
    % % %      %lemo on, xlr on
    % % %      06 0F 00 03
    % % %
    % % %      %ch2
    % % %      06 0D 00 02
    % % %      %ch3
    % % %      07 00 00 02
    % % %      %ch 4
    % % %      06 0E 00 00
    switch lower(sArgs.channel)
        case {'1','0a',1} %3
            ch_hex = {'06 0f'};
            ch_idx = 1;
        case {'2','0b',2} %4
            ch_hex = {'06 0d'};
            ch_idx = 2;
        case {'3','0c',3} %1
            ch_hex = {'07 00'};
            ch_idx = 3;
        case {'4','0d',4} %2
            ch_hex = {'06 0e'};
            ch_idx = 4;
        case {'all'}
            ch_hex = {'06 0f','06 0d','07 00','06 0e'};
            ch_idx = 1:4;
        otherwise
            error([thisFuncStr 'Channel setting unknown.'])
    end
    switch lower(sArgs.feed)
        case {'off',0}
            feed_hex = '00';
        case {'pol','lemo'}
            feed_hex = '01';
        case {'pha','xlr'}
            feed_hex = '02';
        case {'p+p',1}
            feed_hex = '03';
        otherwise
            error([thisFuncStr 'Feed-Voltage/Power setting unknown.'])
    end
    for ch_jdx = 1:length(ch_hex)
        message_hex{end+1} = [ch_hex{ch_jdx} ' 00 ' feed_hex]; %#ok<AGROW>
        oldSettings.ch(ch_idx(ch_jdx)).inputfeed = sArgs.feed;
    end
end

%% **************************************************** pdi
%% lemo feed
% % % % xlr 48 off; lemo pol off; lemo supp 14; input select xlr; (coupling ac)?
if sArgs.lemo
    switch lower(sArgs.channel)
        case {'1','0a',1}
            ch_hex = {'07 07'};
        case {'2','0b',2}
            ch_hex = {'07 05'};
        case {'3','0c',3}
            ch_hex = {'07 08'};
        case {'4','0d',4}
            ch_hex = {'07 06'};
        case {'all'}
            ch_hex = {'07 07','07 05','07 08','07 06'};
        otherwise
            error([thisFuncStr 'Channel setting unknown.'])
    end
    switch lower(sArgs.lemo)
        case {'d14'}
            feed_hex = '02';
        case {'s28'}
            feed_hex = '01';
        case {'d44','normal',1}
            feed_hex = '00';
        otherwise
            error([thisFuncStr 'Feed-Voltage/Power setting unknown.'])
    end
    
    
    for ch_idx = 1:length(ch_hex)
        message_hex{end+1} = [ch_hex{ch_idx} ' 00 ' feed_hex]; %#ok<AGROW>
    end
    
end

%% refbus2preamp
if ~isempty(sArgs.refbus2preamp)
    switch lower(sArgs.refbus2preamp)
        case {0}
            refbus_hex = '00';
        case {'0a'}
            refbus_hex = '01';
        case {'0b'}
            refbus_hex = '02';
        case {'1a'}
            refbus_hex = '03';
        case {'1b'}
            refbus_hex = '04';
        case {'ampa'}
            refbus_hex = '05';
        case {'ampb'}
            refbus_hex = '06';
            
        otherwise
            error([thisFuncStr 'Refbus2Preamp setting unknown.'])
            
    end
    % off/0a/0b/1a/1b/ampA/ampB/
    message_hex{end+1} = ['06 08 00 ' refbus_hex]; %referenz_bus preamp off
end

%% **************************************************** pdi
%% generate and send final message
if ~sArgs.parameterrequest
    message_hex_complete = message_hex;
    packetsize = 100; %pdi: was 15 before
    for message_idx = 1:packetsize+1:length(message_hex_complete)
        message_hex = message_hex_complete( message_idx:min(length(message_hex_complete),message_idx+packetsize) );
        
        final_message = preamble;
        for idx = 1:length(message_hex)
            final_message = [final_message '00 00' message_hex{idx} '00 00']; %#ok<AGROW>
        end
        %delete spaces
        final_message = final_message(final_message ~= ' ');
        final_message_dec = [];
        for idx=1:2:length(final_message)
            if verboseMode %show message in blocks
                fprintf([final_message(idx:idx+1) ' ']);
                if ~mod(idx+3,16), fprintf('  '), end;
                if ~mod(idx+3,32), fprintf('\n'), end;
            end
            final_message_dec = [final_message_dec hex2dec(final_message(idx:idx+1))]; %#ok<AGROW>
        end
        
        %% send sysex
        sysex = [240 final_message_dec 247]; %pre- post- ampel
        ita_midi(sysex,ita_preferences('out_midi_DeviceID'));
        
    end
else %parameterrequest
    
%     final_message = preamble;
%     for idx = 1:length(message_hex)
%         final_message = [final_message '' message_hex{idx} '']; %#ok<AGROW>
%     end
%     %delete spaces
%     final_message = final_message(final_message ~= ' ');
%     final_message_dec = [];
%     if verboseMode
%         disp('******************************************************')
%         fprintf('F0 ')
%     end;
%     for idx=1:2:length(final_message)
%         if verboseMode %show message in blocks
%             fprintf([final_message(idx:idx+1) ' ']);
%             if ~mod(idx+3,16), fprintf('  '), end;
%             if ~mod(idx+3,32), fprintf('\n'), end;
%         end
%         final_message_dec = [final_message_dec hex2dec(final_message(idx:idx+1))]; %#ok<AGROW>
%     end
%     if verboseMode
%         fprintf('F7\n')
%         disp('******************************************************')
%     end;
%     
%     m__old__midi('write_sysex',final_message_dec,1);
end

if sArgs.getSettings
    varargout{1} = oldSettings;
elseif nargout
    varargout{1} = true; %run successful
end
%end function
end