function varargout = ita_sabine(varargin)
%ITA_SABINE - calculate reverberation time with Eyring's or Sabine's
%formula
% Calculate reverberation time or average absorption coefficient and
% reverberation distance in a room according to the formula of Eyring or
% Sabine.
%
%  Call: [T_rev, r_h] = ita_sabine('c',344,'v',0,'m',0,'s',0,'alpha',0)
%       Options (default):
%       c (ita_constants('c'))          - speed of sound in air in m/s
%       v ([])                          - room volume in m^3
%       s ([])                          - wall surface in m^2
%       alpha ([])                      - average absorption coefficient (Can be an vector too)
%       t60 ([])                        - reverberation time
%       m (0)                           - air attenuation constant
%       mode ('Eyring')                 - use Eyring or Sabine
%
%   See also ita_roomacoustics, ita_roomacoustics_reverberation_time, ita_roomacoustics_reverberation_time_hirata, ita_roomacoustics_energy_parameters,
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_sabine">doc ita_sabine</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  02-Feb-2009

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs = struct('c',ita_constants('c'),'v',[],'s',[],'alpha',[],'t60',[],'m',0,'mode','Eyring');
sArgs = ita_parse_arguments(sArgs,varargin);

%% Check input
c = double(sArgs.c);
v = double(sArgs.v);
s = double(sArgs.s);
m = double(sArgs.m);
alpha = sArgs.alpha;
t60 = sArgs.t60;

ita_result = isa(t60,'itaSuper') || isa(alpha,'itaSuper');

if isa(t60,'itaSuper')
    tmpresult = t60;
    t60 = t60.freqData;
end
if isa(alpha,'itaSuper')
    tmpresult = alpha;
    alpha = alpha.freqData;
end

%ToDo - rsc - check units and make sure user knows what he is doing

if isempty(v) || isempty(s)
    error([thisFuncStr ' Sorry, I really need room volume ''V'' and surface ''S''']);
end

if isempty(t60) && isempty(alpha)
    error([thisFuncStr ' Sorry, I need either the reverberation time or the medium absorption coefficient']);
elseif ~isempty(t60) && ~isempty(alpha)
    error([thisFuncStr ' You already seem to know everything. How can I help you?']);
end

%% Calculation of sabine's formula
if isempty(t60)
    alpha(alpha < 0) = 0;
    alpha(alpha > 1) = 1;
    if strcmpi(sArgs.mode,'sabine')
        A = s.*alpha;
    else
        A = -bsxfun(@times,s,log(1-alpha));
    end
    T = (24.*v.*log(10)./c)./bsxfun(@plus,4.*m(:).*v,A); % Vgl. Kuttruff, Room Acoustics, Gl. 4.10 S. 101
    result = T;
    t60 = T;
elseif isempty(alpha)

    idxInvalidRevTime = (t60<0) | isinf(t60);
    if any(idxInvalidRevTime)
        t60(idxInvalidRevTime) = 0;
        ita_verbose_info('setting invalid reverberation time to zero!', 0)
    end
    
    A = v.*bsxfun(@minus,24*log(10)./(c.*t60),4.*m(:));
    % A = 24*log(10).*v./(c.*t60);
    if strcmpi(sArgs.mode,'sabine')
        alpha_m = A./s;
    else
        alpha_m = 1-exp(-A./s);
    end
    result = alpha_m;
end

r_h = 0.1.*(v./pi./t60).^(1/2);

if nargout == 0
    disp([thisFuncStr ' For a room of volume ' int2str(v) ' m^3 with surface of ' int2str(s) ' m^2 :']);
    disp(['T_60: ' num2str(t60,3) ' s']);
    disp(['alpha: ' num2str(alpha,3) ' ']);
    disp(['Reverberation radius: ' num2str(r_h,3) ' m']);
end

if ita_result
    tmpresult.freqData = result;
    tmp_r_h = tmpresult;
    tmp_r_h.data = r_h;
    r_h = tmp_r_h;
    result = tmpresult;
    result.channelNames(:) = {'Absorption coefficient'};
    result.comment = 'Absorption coefficient';
    result.channelUnits(:) = {'1'};
    r_h.channelNames(:) = {'Critical distance'};
    r_h.comment = 'Critical distance';
    r_h.channelUnits(:) = {'m'};
    r_h = ita_metainfo_add_historyline(r_h,mfilename,varargin);
    result = ita_metainfo_add_historyline(result,mfilename,varargin);
else
    result = itaValue(result,'1');
    r_h = itaValue(r_h,'m');
end

%% Find output parameters
if nargout > 0
    varargout(1) = {result};
end
if nargout > 1
    varargout(2) = {r_h};
end
    
end