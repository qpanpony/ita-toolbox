function varargout = ita_check_compatibility(varargin)
%ITA_CHECK_COMPATIBILITY - Check compatibility of two audioObjects
%  This function checks for compatibility between 2 audioObjects,
%  respectively checks for number of channels, nBins or nSamples, and
%  SamplingRate. Select specific parameters to check by options, such as: 
%  'units', 'size', 'channels', 'samplingRate' or 'all'.
%
%  Syntax: itaAudio = ita_check_compatibility(itaAudio1,itaAudio2,options)
%  Options (default):
%   'units' (false) :           check units for compatibility
%   'size' (false) :            check size for compatibility
%   'channels' (false) :        check channels for compatibility
%   'samplingRate' (false) :    check samplingRate for compatibility
%   'all' (true) :              check everything for compatibility
%
%  Example: itaAudio = ita_check_compatibility(itaAudio1,itaAudio2,'size')
%
%   See also ita_metainfo_check, ita_multiply_spk.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_check_compatibility">doc ita_check_compatibility</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  05-Mar-2009


%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  % Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Get the name of the calling functions - use dbstack
callingFuncStr = dbstack;
if length(callingFuncStr) >= 1
    callingFuncStr = ['(' callingFuncStr(1).name '):'];
else
    callingFuncStr = '';
end

%% Initialization and Input Parsing
% narginchk(2,20);
sArgs        = struct('units',false,'size',false,'channels',false,'samplingRate',false,'all',true);
data1 = varargin{1};
data2 = varargin{2};
sArgs = ita_parse_arguments(sArgs,varargin(3:end));

%% check if user selected specific criteria to check
if any([sArgs.units sArgs.size sArgs.channels sArgs.samplingRate])
    sArgs.all = false; %do not check all, just check selected ones
end
%count, counter, a,b,c,d for error display purposes
count   = 0;
counter = [];
a = '';
b = '';
c = '';
d = '';

%% isCompatible will be set to false, if something happens
isCompatible = true;

%% Check units
if sArgs.units || sArgs.all
    for i = 1:data1.nChannels
        if ~strcmp(data1.channelUnits{i}, data2.channelUnits{i})
            if ~isequal(data1.channelUnits{i}, data2.channelUnits{i}) %pdi added
                % this is important to compare empty cells or '' and []
                isCompatible = false;
                count = 1;
                a = 'Units do not match.';
            end
        end
    end
end
counter = [counter count];           

%% check number of samples
if sArgs.size || sArgs.all
    if data1(1,1).nSamples ~= data2(1,1).nSamples
        isCompatible = false;
        count = 2;
        b = 'Number of samples do not match.';
    end
end
counter = [counter count];

%% check sampling rate
if sArgs.samplingRate || sArgs.all
    if data1(1,1).samplingRate ~= data2(1,1).samplingRate
        isCompatible = false;
        count = 3;
        c = 'Sampling rates do not match.';
    end 
end
counter = [counter count];

%% check number of channels
if sArgs.channels || sArgs.all
    if data1(1,1).nChannels ~= data2(1,1).nChannels
        isCompatible = false;
        count = 4;
        d = 'Channels do not match.';
    end
end
counter = [counter count];

%% Find output parameters
if nargout == 0 %User has not specified a variable
    if any(ismember(counter,1))
        error([upper(callingFuncStr) a ' ' b ' ' c ' ' d]);
    end
    if any(ismember(counter,2))
        fprintf(2,[upper(callingFuncStr) a ' ' b ' ' c ' ' d '\n']);
    end
    if any(ismember(counter,3))
        error([upper(callingFuncStr) a ' ' b ' ' c ' ' d]);
    end
    if any(ismember(counter,4))
        fprintf(2,[upper(callingFuncStr) a ' ' b ' ' c ' ' d '\n']);
    end
else
  
    varargout(1) = {isCompatible};
    if verboseMode % if verboseMode is set, then display all the errors, otherwise just output directly result
        if any(ismember(counter,1))
            disp([thisFuncStr ' Units do not match.']);
        end
        if any(ismember(counter,2))
            disp([thisFuncStr ' Number of samples do not match.']);
        end
        if any(ismember(counter,3))
            disp([thisFuncStr ' Sampling rates do not match.']);
        end
        if any(ismember(counter,4))
            disp([thisFuncStr ' Channels do not match.']);
        end  
    end
end

%end function
end