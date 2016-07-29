function varargout = ita_mergeunvresults(resVecs, varargin)
%ITA_MERGEUNVRESULTS - Merges different parts of a frequency response
%  This function merges different parts of a frequency response which are
%  obtained from FE-Simulation using SoundSolve. Due to memory restrictions
%  it is sometimes not possible to simulate the whole desired frequency
%  range at once using SoundSolve. In this case the frequency range has to
%  be split and a simulation has to be run for each frequency band. The
%  obtained resultfiles in unv-format can be read using
%  ita_readunvresults.m in 'raw' format and then be concatenated using 
%  ita_mergeunvresults.m.
%  !!! This function does not check for overlap in the frequency range or
%  that the result-structs are ordered in the right frequency order.
%  The user has to make sure, that the cell 'ResVecs' contains the 'raw' 
%  format data in the right frequency
%  order.
%
%  Example: results1 contains frequencies 100:1:200
%           results2 contains frequencies 201:1:300
%           results3 contains frequencies 301:1:400
%           => resVecs = {results1, results2, results3}
%
%  Call: mergeRes = ita_readunvresults(resVecs)
%        mergeRes = ita_readunvresults(resVecs, format, SampleRate, nSamples, interpType)
%
%        Parameter description:
%        1) resVecs     = cell with result data for different frequency
%                         bands (in right order, without overlap)
%        2) format      = format for output of function
%                Values = 'raw' = DEFAULT
%                                 results are written for all frequencies in the unv-file
%                                 and returned in struct 'results' with members:
%                                 .data     = cell, each member contains
%                                             results for one node
%                                 .freq     = vector with all frequencies 
%                                             read from unv-file 
%                                 .type     = resType (see above) 
%                                 .origin   = unvFilename (see above)
%                                 .resnodes = resNodes (see above)
%                         'ita' = results are returned as a cell containing one 
%                                 ita audio struct for each nodenumber.
%                                 The interpolation in the frequency
%                                 domain requires additional inputs
%                                 'SampleRate' and 'nSamples'
%        3) SampleRate  = Sampling rate for conversion of data at freq. 
%                         in the unvfile to ita audio struct. Parameter is 
%                         ignored when format is set to 'raw'
%        4) nSamples    = Number of Samples for conversion of data at freq. 
%                         in the unvfile to ita audio struct. Number of 
%                         bins in the freq-domain = (nSamples+2)/2.
%                         Parameter is ignored when format is set to 'raw'
%        5) interpType  = string containing the interpolation type, such as
%                         'linear' (default) or 'spline'
%
%   See also ita_fft, ita_ifft, ita_ita_read, ita_ita_write, ita_metainfo_rm_channelsettings, ita_metainfo_add_picture, ita_impedance_parallel, ita_impedancecalculator.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_readunvresults">doc ita_readunvresults</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marc Aretz -- Email: mar@akustik.rwth-aachen.de
% Created: 06-Oct-2008 

%% Get ITA Toolbox preferences
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU>
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU>

%% Initialization
% Number of Input Arguments
narginchk(1,5);

% optional inputs:   resType, format, SampleRate, nSamples
[format, SampleRate, nSamples, interpType] = parseoptionalinput(length(varargin), varargin);

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back
nResVecs = length(resVecs);
nResNodes = length(resVecs{1}.resnodes);
switch resVecs{1}.type
    case 'P'
        nResComp = 1;
    case 'D2D'
        nResComp = 6;
    case {'D3D', 'RF'}
        nResComp = 3;
end

freq     = [];
for k = 1:nResNodes
    res{k} = [];
end

for k = 1:nResVecs
    freq = [ freq, resVecs{k}.freq ];
    for m = 1:nResNodes
        help = [];
        for n = 1:nResComp
                help = [help; resVecs{k}.data{m}(n,:)];
        end
        res{m} = [res{m}, help ];
    end
end

if strcmp(format,'ita')
    for k=1:length(res)
        results{k}                     = itaAudio();
        results{k}.Bits         = 64;
        results{k}.DateVector   = [ round(clock), 0 ];
        resutls{k}.signalType      = 'energy';
        results{k}.FileExt      = '.ita';
        results{k}.samplingRate = SampleRate;
        results{k}.nBins        = (nSamples+2)/2;
        results{k}.nSamples     = nSamples;
        results{k}.comment = sprintf('SoundSolve:\n Resultfile: %s\n Node %i\n', resVecs{1}.origin, resVecs{1}.resnodes(k) );
        
        switch resVecs{1}.type
            case 'P'
                results{k}.nChannels = 1;
                results{k}.channelNames = {'Pressure'};
                results{k}.channelUnits = {'Pa'};
            case 'D2D'
                results{k}.nChannels = 6;
                results{k}.channelNames = {'xDisplacement', 'yDisplacement', 'zDisplacement', 'xRotation', 'yRotation', 'zRotation'};
                results{k}.channelUnits = {'mtr', 'mtr', 'mtr', 'rad', 'rad', 'rad'};
            case 'D3D'
                results{k}.nChannels = 3;
                results{k}.channelNames = {'xDisplacement', 'yDisplacement', 'zDisplacement'};
                results{k}.channelUnits = {'mtr', 'mtr', 'mtr'};
            case 'RF'
                results{k}.nChannels = 3;
                results{k}.channelNames = {'xForce', 'yForce', 'zForce'};
                results{k}.channelUnits = {'N','N','N'};
        end

        
        newfVec = results{k}.freqVector;

        for m=1:size(res{k},1)
            results{k}.spk(m,:)       = interp_zeroextrap(freq, res{k}(m,:), newfVec, interpType);
        end
    end
    
elseif strcmp(format,'raw')
    results.data     = res; 
    results.freq     = freq;
    results.resnodes = resVecs{1}.resnodes;  
    results.type = resVecs{1}.type;
    results.origin = resVecs{1}.origin;
end

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    error('ita_readunvresults: No output argument specified.');    
else
    % Write Data
    varargout(1) = {results};
end

%end function
end

function [format, SampleRate, nSamples, interpType] = parseoptionalinput(options, varargin)
 
 formatAttr  = {'ita', 'raw'};
 interpAttr  = {'linear','spline','nearest'};

% Initialization of optional input parameter pairs
format     = 'raw';    % default
SampleRate = -1;       % default
nSamples   = -1;       % default
interpType = 'linear'; % default

varargin = varargin{:}; % extract cell array input from varargin
 
if options

    % arguments are in fixed parameter order
    if options == 1
        format = getString(varargin{1}, formatAttr);
    elseif options == 3 && ~isempty(varargin{2}) && ~isempty(varargin{3})
        format = getString(varargin{1}, formatAttr);
        if strcmp(format,'ita') 
            if isnumeric(varargin{2}) && isnumeric(varargin{3})
                SampleRate = varargin{2};
                nSamples = varargin{3};
            else
                error('ita_readunvresults: input arguments 3 and 4 must be numeric.')
            end
        else
            disp('ita_readunvresults: input arguments 3 and 4 are ignored for result format "raw".')
        end
    elseif options == 4 && ~isempty(varargin{2}) && ~isempty(varargin{3}) && ~isempty(varargin{4})
        format = getString(varargin{1}, formatAttr);
        if strcmp(format,'ita') 
            if isnumeric(varargin{2}) && isnumeric(varargin{3})
                SampleRate = varargin{2};
                nSamples = varargin{3};
            else
                error('ita_readunvresults: input arguments 3 and 4 must be numeric.')
            end
        else
            disp('ita_readunvresults: input arguments 3 and 4 are ignored for result format "raw".')
        end
        interpType = getString(varargin{4}, interpAttr);
    else
        error('ita_readunvresults: invalid number of input arguments.')
    end        
end
%end function
end

function [out] = getString(in, attributes)
if ischar(in)
    if ismember(in, attributes)
        out = in;
    else
        error('ITA_ROHRBERT:Oh Lord. Invalid input argument.')
    end
else
    error('ITA_ROHRBERT:Oh Lord. Input argument three must be of type char.')
end

%end function
end

% interpolate modelling data and set data to zero outside of modeling range
function [interpData] = interp_zeroextrap(freq, data, newFreq, modus)

if (size(data,1)==1) || (size(data,2)==1)
    % Make sure all vectors are row vectors
    freqHelp(1,:)    = freq;
    dataHelp(1,:)    = data;
    newFreqHelp(1,:) = newFreq;
    freq             = freqHelp;
    data             = dataHelp;
    newFreq          = newFreqHelp;
    
    lenF             = length(freq);
    lenNF            = length(newFreq);
    idxS             = 1;
    idxE             = lenNF;
    interpData       = zeros(1, lenNF);
    
    % Append zeros where impedance data is not available
    while newFreq(idxS) < min(freq)
        idxS = idxS+1;
    end
    while newFreq(idxE) > max(freq)
        idxE = idxE-1;
    end
    % TODO: what's the best way to interpolate data in the frequency
    % domain???
    interpData(idxS:idxE) = interp1(freq, data, newFreq(idxS:idxE), modus);
else
    error('FUNCTION:INTERP_ZEROEXTRAP: Invalid first input argument.');
end

%end function
end