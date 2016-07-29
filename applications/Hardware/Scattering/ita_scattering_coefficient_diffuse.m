function varargout = ita_scattering_coefficient_diffuse(varargin)
%ITA_SCATTERING_COEFFICIENT_DIFFUSE - random-incidence scattering coefficient
% This function calculate the scattering coefficient from the reverberation
% times calculated in four different conditions:
%
%                Test sample         |   Turning table
% - RT1     |        NO              |      NO
% - RT2     |        YES             |      NO
% - RT3     |        NO              |      YES
% - RT4     |        YES             |      YES
%
%  atm_mat is a matrix that contains information about the atmospheric
%  condition during each of the four measurements. It must be structured as
%  follow:
%
%  atm_mat = [T1  T2  T3  T4;
%             RH1 RH2 RH3 RH4]
%
%  where T stands for temperature (in degree Celsius) and RH stands for
%  relative humidity in percent
%
%  RT contains the performed measurements and is structured like this:
%
%  RT = [mean([RT1_p1, RT1_p2]);
%        mean([RT2_p1, RT2_p2]);
%        mean([RT3_p1, RT3_p2]);
%        mean([RT4_p1, RT4_p2])];
%
%  where RTX_pY is the reverberation time evaluated at position Y
%
%
%  Syntax:
%   s = ita_scattering_coefficient_diffuse(RT,atm_vec)
%
%   Options (default):
%           'plot' (false)         : plot all results
%           'alphaMode' ('Eyring') : Eyring or Sabine for alpha
%           'scaleFactor' (5)      : small-scale factor
%           'sampleArea' (pi*0.4^2): surface area of sample
%           'RT_std' (itaResult()) : std dev of RT
%           'S_room' (9.05)        : surface area of empty room
%           'V_room' (1.67)        : volume of empty room
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_scattering_coefficient_diffuse">doc ita_scattering_coefficient_diffuse</a>

% <ITA-Toolbox>
% This file is part of the application Scattering for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  21-Jul-2010

%% Get Function String
thisFuncStr  = [upper(mfilename) ':']; %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_RT','itaResult', 'pos2_atm_mat','double','plot',false,'alphaMode','Eyring','sampleArea',pi*(0.4^2),'scaleFactor',5,'RT_std',itaResult(),'S_room',9.05,'V_room',1.67);
[RT,atm_mat,sArgs] = ita_parse_arguments(sArgs,varargin);

channelNames = {'no sample; no rotation','with sample; no rotation',...
    'no sample; with rotation','with sample; with roation'};
if numel(RT) > 1
    RT = merge(RT);
end
if RT.nChannels ~= 4
    error([thisFuncStr '4 reverberation times are required for this parameter']);
end
RT.comment = 'Reverberation Time';
RT.channelNames = channelNames;

%% Frequencies
scale_factor = sArgs.scaleFactor;
% Frequencies under analysis
f = RT(1).freqVector;
f0 = f./scale_factor;

%% Constants
c = cell(4,1);
m = cell(4,1);
for i = 1:4
    [c{i},m{i}] = ita_constants({'c','m'},'T',atm_mat(1,i),'phi',atm_mat(2,i)/100,'f',f);
end

S_baseplate = pi*(0.43^2);  % Area of the baseplate in square meters
S_sample    = sArgs.sampleArea; % Area of the test sample in square meters
S_room      = sArgs.S_room;
V_room      = sArgs.V_room;

%% Calculate the virtual absorption coefficient in each of the four cases
% empty - no rotation
alpha(1) = ita_sabine('c',double(c{1}),'v',V_room,'s',S_room,'m',double(m{1}),'t60',RT.ch(1),'mode',sArgs.alphaMode);
% with sample - no rotation
alpha(2) = ita_sabine('c',double(c{2}),'v',V_room,'s',S_room,'m',double(m{2}),'t60',RT.ch(2),'mode',sArgs.alphaMode);
% empty - with rotation
alpha(3) = ita_sabine('c',double(c{3}),'v',V_room,'s',S_room,'m',double(m{3}),'t60',RT.ch(3),'mode',sArgs.alphaMode);
% with sample - with rotation
alpha(4) = ita_sabine('c',double(c{4}),'v',V_room,'s',S_room,'m',double(m{4}),'t60',RT.ch(4),'mode',sArgs.alphaMode);

RT.freqVector = f0;
RT.channelNames = channelNames;

alpha = merge(alpha);
alpha.freqVector = f0;
alpha.comment = ['Absorption Coefficient (according to ' sArgs.alphaMode ')'];
alpha.channelNames = channelNames;
A_empty = itaValue(S_room,'m^2') * alpha.ch(1);
A_empty.comment = ['Equivalent Absorption Area (according to ' sArgs.alphaMode ')'];

%% Calculations
% calculate the random incidence absorption coefficient alpha_s
alpha_s = S_room/S_sample * (alpha.ch(2) - alpha.ch(1)) + alpha.ch(1);

% calculate the specular absorption coefficient alpha_spec
alpha_spec = S_room/S_sample * (alpha.ch(4) - alpha.ch(3)) + alpha.ch(3);

% Calculate the scattering coefficient of the sample
s = 1 - (1 - alpha_spec)/(1 - alpha_s);
s.freq = max(s.freq,0);

% Calculate the scattering coefficient of the base plate
s_baseplate = S_room/S_baseplate * (alpha.ch(3) - alpha.ch(1));
s_baseplate.freq = max(s_baseplate.freq,0);

%% Meta Infos
s_baseplate.channelNames = {'scattering coefficient of the base plate'};
s_baseplate.comment = 'Scattering Coefficient';
s.comment = 'Scattering Coefficient';
s.channelNames = {'scattering coefficient of the sample'};

%% determine accuracy with error propagation
if ~isempty(sArgs.RT_std)
    stdRT  = merge(sArgs.RT_std);
    stdRT.freqVector = f0;
    
    K = itaValue(24.*log(10).*V_room./mean(cellfun(@double,c))./S_sample,'s');
    stdS1 = sum((merge([(1-s) (1-s) 0*s+1 0*s+1])*stdRT/RT^2)^2);
    
    r0 = 0*s; % zero ...
    r1 = 1 + r0; % and one dummy coefficients
    r13 = r1;
    r24 = r1;
    r24.freq = max(0,1 - alpha_spec.freq);
    
    % error propagation with correlation
    stdS2 = (s-1)*(r13*stdRT.ch(1)*stdRT.ch(3)/(RT.ch(1)*RT.ch(3))^2 + r24*stdRT.ch(2)*stdRT.ch(4)/(RT.ch(2)*RT.ch(4))^2);
    
    stdS = K/(1-alpha_s)*sqrt(stdS1 + 2*stdS2);
    stdS.channelNames = {'Standard deviation of the scattering coefficient'};
else
    stdRT = itaResult();
    stdS = itaResult();
end

%% Add history line
s = ita_metainfo_add_historyline(s,mfilename,varargin);

%% Set Output
varargout(1) = {s};
if nargout > 1
    varargout(2) = {s_baseplate};
    if nargout > 2
        varargout(3) = {alpha};
        if nargout > 3
            varargout(4) = {RT};
            if nargout > 4
                varargout(5) = {stdRT};
                if nargout > 5
                    varargout(6) = {stdS};
                end
            end
        end
    end
end

%% do plotting
if sArgs.plot
    % Max ISO limits
    ISO_limits_354 = ita_ISO_limits_absorption(V_room*(scale_factor^3),'freqVector',f0)/scale_factor^2;
    ISO_limits_17497 = ita_ISO_limits_scattering(V_room,'freqVector',f0);
    alpha_s_max = ISO_limits_17497(1);
    A_empty_ISO = merge(ISO_limits_354,ISO_limits_17497(2));
    s_baseplate_ISO = ISO_limits_17497(3);
    
    % reverberation times
    ita_plot_freq(RT,'ylim',[0 3]);
    ylabel('Reverberation Time [s]');
    
    % absorption coefficient of the sample alpha
    ita_plot_freq(merge(alpha_s,alpha_s_max),'ylim',[0 1.05]);
    
    % maximum alowable absorption area of the emtpy room
    ita_plot_freq(merge(A_empty,A_empty_ISO),'ylim',[0 max(1.05,ceil(max(A_empty_ISO.freq)))]);
    ylabel('Absorption Area [m^2]');
    
    % maximum allowable scattering coefficient of the baseplate
    ita_plot_freq(merge(s_baseplate,s_baseplate_ISO),'ylim',[0 0.5]);
    title('Scattering Coefficient - Base Plate');
    ylabel('Random Incidence Scattering Coefficient [-]');
    
    % scattering coefficient of the sample
    ita_plot_freq(s,'ylim',[0 1.05]);
    title('Scattering Coefficient - Sample');
    ylabel('Random Incidence Scattering Coefficient [-]');
    
end

%end function
end