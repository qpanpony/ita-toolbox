function varargout = ita_filter_bandpass(varargin)
%ITA_FILTER_BANDPASS - Calculate bandfiltered Signal
%  Banpass for a signal
%
%  Syntax:
%   audioObjOut = ita_filter_bandpass(audioObjIn, options)
%
%   Options (default):
%           'zerophase' (true) : use zerophase band filters. non-causal!
%           'order'(10): order of filter cut off
%           'upper' 0: upper bandpasscursor 
%           'lower' 0: lower bandpasscursor
%           'type'  'butter': Butterwothfilter als default
% 
% 
%  See also:
%   ita_mpb_filter
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_fractional_octavebands">doc ita_fractional_octavebands</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  05-May-2011

sArgs = struct( 'pos1_data','itaAudio',...
                'zerophase', 'true' ,...
                'order',10, ...
                'upper', 0, ...
                'lower', 0);


if nargin==0
    sArgs.varname = 'outputVariableName';
    sArgs = ita_parse_arguments_gui(sArgs,'title','Bandpass filter');
else
    [sArgs] = ita_parse_arguments(sArgs,varargin);
end

FilterVector = [sArgs.lower sArgs.upper]; % creats FilterVector from the upper and lower filterfrequency
input = sArgs.data;


%% Call mpb filter
input = ita_mpb_filter(input, FilterVector ,'order',sArgs.order,'zerophase',sArgs.zerophase);

if nargin == 0
   % setin base
   ita_setinbase(sArgs.varname,input);
end

%% Set Output
varargout(1) = {input};

%end function
end