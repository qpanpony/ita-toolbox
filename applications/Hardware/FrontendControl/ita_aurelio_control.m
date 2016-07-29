function varargout = ita_aurelio_control(varargin)
%ITA_AURELIO_CONTROL - Send Settings to Aurelio 2014 Frontend
%  This function sends Midi Sysex Commands to the Aurelio High Precision
%  Frontend (Swen Mueller, Immetro, Rio de Janiero, Brazil).
%
%  Syntax: ita_aurelio_control(options)
%       'init' (false): set the frontend to last know values
%       'range' (0): inputRange as double, will round to nearest possible
%       'samplingRate' (ita_preferences), 32000, 44100 or 48000 multiplied by 1x, 2x, or 4x.
%       'coupling'
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_robocontrol">doc ita_robocontrol</a>

% <ITA-Toolbox>
% This file is part of the application RoboAurelioModulITAControl for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Pascal Dietrich - pdi@akustik.rwth-aachen.de

%% persistent
persistent oldSettings last_input last_AmpHighPower last_Amplifier last_AmpBridgeMode last_AmpLowImpedanceMode last_Amp26dBu last_AmpAC last_AmpMono
% force_init = false;
if isempty(last_input)
    %     force_init = true;
    last_input = 'xlr';
    last_AmpHighPower = false;
    last_Amplifier = true;
    last_AmpBridgeMode = false;
    last_AmpLowImpedanceMode = false;
    last_Amp26dBu = false;
    last_AmpAC = false;
    last_AmpMono = false;
    oldSettings.ch(1).inputrange = 6;
    oldSettings.ch(2).inputrange = 6;
    oldSettings.ch(1).inputfeed = 'none';
    oldSettings.ch(2).inputfeed = 'none';
    oldSettings.ch(1).inputselect = 'xlr';
    oldSettings.ch(2).inputselect = 'xlr';
    
    oldSettings.amp_gain = -20;
end

if nargin == 0
    ita_aureliocontrol_gui();
end

%% init
sArgs     = struct('channel',1:2,'groundLift',true,'inputCouplingAC',true,'feed',oldSettings.ch(1).inputfeed,'inputrange',[],...
    'input',last_input,'mode','norm','securityMode',false,'init',false,'samplingRate',ita_preferences('samplingRate'),'outputvolume',[],...
    'AmpHighPower',last_AmpHighPower,'AmpLowPower',false,'Amplifier',last_Amplifier,'NoAmplifier',false,'AmpBridgeMode',last_AmpBridgeMode,'AmpLowImpedanceMode',last_AmpLowImpedanceMode,...
    'Amp26dBu',last_Amp26dBu,'Amp06dBu',false , 'NoGroundLift', false, 'AmpAC', last_AmpAC, 'AmpMono', last_AmpMono, 'getSettings',false,'reset',false);

%% parse
[sArgs]   = ita_parse_arguments(sArgs,varargin);
ch_number = ita_angle2str( sArgs.channel - 1, 2); %zero indexing for channel numbering

if sArgs.getSettings
    varargout{1} = oldSettings;
    return;
end

if sArgs.reset
    clear all
    ita_aurelio_control('init');
    if nargout == 1
        varargout{1} = [];
    end
    return;
end

%% inverse parameters
if sArgs.Amp06dBu
    sArgs.Amp26dBu = false;
end
if sArgs.NoAmplifier
    sArgs.Amplifier = false;
end
if sArgs.AmpLowPower
    sArgs.AmpHighPower = false;
end
if sArgs.NoGroundLift
    sArgs.groundLift = false;
    %     sArgs.feed = 'none';
end

%% write back to persistents
last_input          = sArgs.input;
last_AmpHighPower   = sArgs.AmpHighPower;
last_Amplifier      = sArgs.Amplifier;
last_AmpBridgeMode  = sArgs.AmpBridgeMode;
last_AmpLowImpedanceMode = sArgs.AmpLowImpedanceMode;
last_Amp26dBu       = sArgs.Amp26dBu;
last_AmpAC          = sArgs.AmpAC;
last_AmpMono        = sArgs.AmpMono;

%% INIT device
if sArgs.init
    % go thru all stages
    clear
    ita_aurelio_control('input','XLR','inputrange',6,'feed',0 , 'samplingRate',ita_preferences('samplingRate'));
    return
end

%% range
if ~isempty( sArgs.inputrange )
    sArgs.inputrange = min( max(sArgs.inputrange,-34) , 56);
    par_number = '02';
    par_value  = round((- sArgs.inputrange + 56)/10); %round to nearest possible
    for idx = 1:numel(sArgs.channel)
        oldSettings.ch(sArgs.channel(idx)).inputrange = 56 - (par_value * 10);
    end
    if sArgs.securityMode
        par_value  = par_value + 40;
    end
    par_value = ita_angle2str(par_value,2);
    send_sysex(par_number, par_value, ch_number); %send to device
end

%% input select -- routing control -- HUHU old values needed
if ~isempty(sArgs.input)
    par_number = '01';
    switch lower(sArgs.mode)
        case 'norm' %normal mode
            Mode = '0000';
        case 'imp' %impedance measurement
            Mode = '0001';
            sArgs.feed = false;
            %             ChSwp = '1'; % pdi: oct 2012: for some reason
            %             this is not required anymore ???!!!
        case {'impref','iref'}
            Mode = '0010';
            sArgs.feed = false;
        case {'bncref','bref'}
            Mode = '0100';
            sArgs.input = 'gnd';
            sArgs.feed = false;
        case {'ampref','aref'}
            Mode = '0101';
            sArgs.input = 'gnd';
            sArgs.feed = false;
        case {'xlrref','xref','lineref'}
            Mode = '0011';
            sArgs.feed = false;
        case 'specialref'
            Mode = ['010' num2str(~ch_number) ];
            sArgs.input = 'gnd';
        otherwise
            error('argument not correct for ''input''')
    end
    
    if ~exist('ChSwp','var')
        ChSwp = '0'; %funny channel swapping for crazy people. take care, dude!
    else
        ita_verbose_info('Careful, channel swapping is activated.',0)
    end
    
    switch lower(sArgs.input)
        case 'xlr'
            IS = '11';
        case 'lemo'
            IS = '01';
            sArgs.feed = 'pol';
        case 'gnd'
            IS = '00';
        case 'bnc'
            IS = '10';
        otherwise
            error(['input select unknown: ' sArgs.input])
    end
    par_value = dec2hex( bin2dec( [IS ChSwp Mode ] ) );
    send_sysex(par_number, par_value, ch_number); %send to device
    
    for iCh = 1:numel(sArgs.channel)
        oldSettings.ch(sArgs.channel(iCh)).inputselect = lower(sArgs.input);
    end
end

%% coupling and feed control
if ~isempty( sArgs.feed )
    par_number = '00';
    Wait  = '0'; %wait for relays to switch later
    Lem28 = '0'; %switch 14 to 28Volts, Pin7 is then grounded
    Phan  = '0';
    Feed  = '0';
    ICP   = '0';
    Glift = num2str(sArgs.groundLift);
    AC    = num2str(sArgs.inputCouplingAC);
    
    switch lower(sArgs.feed)
        case 'pha'
            Phan = '1';
            AC   = '1'; %block DC from preamp inputs
        case 'pol'
            Feed = '1';
            AC   = '1'; %block DC from preamp inputs
        case {'icp','iepe'}
            ICP  = '1';
            Feed = '1';
            AC   = '1';
        case 'p+p'
            Phan = '1';
            Feed = '1';
            AC   = '1';
        case 'all'
            Phan = '1';
            Feed = '1';
            ICP  = '1';
            AC   = '1';
        case 'ccx'
            Phan = '0';
            Feed = '0';
            ICP  = '0';
            AC   = '0';
            Glift = '1';
        case {0 ,'none','off'}
            %
        otherwise
            error('feed wrong')
    end
    par_value  = dec2hex( bin2dec ( ['0' Wait Lem28 Phan Feed ICP Glift AC] ));
    send_sysex(par_number, par_value, ch_number); % send final sysex
    
    for iCh = 1:numel(sArgs.channel)
        oldSettings.ch(sArgs.channel(iCh)).inputfeed = lower(sArgs.feed);
    end
end

%% sampling rate
if sArgs.samplingRate
    par_number = '03';
    
    if isnatural(sArgs.samplingRate / 48000)
        modifier  = (sArgs.samplingRate / 48000);
        base_rate = 2;
    elseif isnatural(sArgs.samplingRate / 44100)
        modifier  = sArgs.samplingRate / 44100;
        base_rate = 1;
    elseif isnatural(sArgs.samplingRate / 32000)
        modifier  = sArgs.samplingRate / 32000;
        base_rate = 0;
    else
        error('sampling rate not supported.')
    end
    switch modifier
        case 1
            modifier = 0;
        case 2
            modifier = 1;
        case 4
            modifier = 2;
        otherwise
            error('sampling rate not supported.')
    end
    par_value  =  dec2hex(modifier*4 + base_rate);
    send_sysex(par_number, par_value, []); % send final sysex
    
    ita_preferences('samplingRate',sArgs.samplingRate); % also initializes playrec
end



%% analog output control - Parameter 05
HiPow   = num2str(sArgs.AmpHighPower);
AmpOn   = num2str(sArgs.Amplifier);
Bridge  = num2str(sArgs.AmpBridgeMode);
LoImp   = num2str(sArgs.AmpLowImpedanceMode);
dBu26   = num2str(sArgs.Amp26dBu);
AC      = num2str(sArgs.AmpAC);
mono    = num2str(sArgs.AmpMono);

par_number = '05';
par_value  = dec2hex(bin2dec(['0' HiPow AmpOn Bridge LoImp dBu26 AC mono])); % 0dB attenuation
send_sysex(par_number, par_value, ch_number); %send to device

if sArgs.Amp06dBu
    oldSettings.amp_gain = -20;
elseif sArgs.Amp26dBu
    oldSettings.amp_gain = 0;
end


%% output volume - Parameter 06
% if ~isempty( sArgs.outputvolume )
%     par_number = '06';
%     par_value  = '7F'; % 0dB attenuation
%     send_sysex(par_number, '0', []); %send to device
% end




end

%% **********************  send sysex  ************************************
function send_sysex(par_number, par_value, ch_number)
if ~isempty(ch_number) && numel(str2num(ch_number)) >= 2
    ch_number = '7F';
end
%build complete sysex
sys_hex = {};
sys_hex{numel(sys_hex)+1} = par_number; % hex
sys_hex{numel(sys_hex)+1} = par_value;  % hex
if ~isempty(ch_number)
    sys_hex{numel(sys_hex)+1} = ch_number;  % hex
end

for idx = 1:numel(sys_hex)
    sys_dec(idx) = hex2dec( sys_hex{idx} );
end

% generate checksum
checksum = sum(sys_dec);
checksum = bin2dec(num2str(mod(str2double(dec2bin(checksum)), 10000000)));
complete_sysex = [sys_dec checksum];

%send sysex
sysex = [hex2dec('F0') hex2dec('70') complete_sysex hex2dec('F7')]; %pre- post- ampel
ita_midi(sysex,ita_preferences('out_midi_DeviceID'));

end
