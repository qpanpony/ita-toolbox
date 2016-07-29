function varargout = ita_readunvresults(unvFilename, resNodes, varargin)
%ITA_READUNVRESULTS - Read unv-resultfile written with SoundSolve FE-Solver
%  This function reads unv-resultfiles and returns the results
%  for distinct nodes of the FE-Mesh as a freequency response
%
%  For details on the unv-Format and especially the see AnalysisData Dataset see:
%  http://www.akustik.rwth-aachen.de/pub/Dokumentation/SDRCHelp/LANG/German/unv_ug/UNV_2414.htm
%  
%  Call: results = ita_readunvresults(unvFilename, resNodes)
%        results = ita_readunvresults(unvFilename, resNodes, resType)
%        results = ita_readunvresults(unvFilename, resNodes, resType, format, SampleRate, nSamples, interpType)
%
%        Parameter description:
%        1) unvFilename = Filepath and Filename of unv-file that shall be read
%        2) resNodes    = (1xX) double array containing the X node numbers, of
%                         which the results shall be returned
%        3) resType     = specifies type of result data
%                Values = 'P'   = DEFAULT 
%                                 Pressure (px,py,pz), 
%                         'D2D' = Thin Shell Displacement and Rotation (dx,dy,dz,rotx,roty,rotz), 
%                         'D3D' = 3D Structure Displacement (dx,dy,dz), 
%                         'RF'  = Reaction Force on fixed structure boundaries (Fx,Fy,Fz)
%        4) format      = format for output of function
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
%                                 ita audio struct for each nodenumber
%                                 specified in resNodes.
%                                 The interpolation in the frequency
%                                 domain requires additional inputs
%                                 'SampleRate' and 'nSamples'
%        5) SampleRate  = Sampling rate for conversion of data at freq. 
%                         in the unvfile to ita audio struct. Parameter is 
%                         ignored when format is set to 'raw'
%        6) nSamples    = Number of Samples for conversion of data at freq. 
%                         in the unvfile to ita audio struct. Number of 
%                         bins in the freq-domain = (nSamples+2)/2.
%                         Parameter is ignored when format is set to 'raw'
%        7) interpType  = string containing the interpolation type, such as
%                         'linear' (default) or 'spline'
%
%   See also ita_mergeunvresults, ita_metainfo_add_picture.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_readunvresults">doc ita_readunvresults</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marc Aretz -- Email: mar@akustik.rwth-aachen.de
% Created: 06-Oct-2008 

%% Initialization
% Number of Input Arguments
narginchk(2,7);

% open unv Filename
[fileID, message] = fopen (unvFilename,'r');
if (fileID == -1)
    error(['Oh Lord. Could not open file, message: ', message]);
end

% optional inputs:   resType, format, SampleRate, nSamples
[resType, format, SampleRate, nSamples, interpType] = parseoptionalinput(length(varargin), varargin);

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back
res   = [];
fVec   = [];
fStep  = 0;
nFreq = 0;
goal = 'freq';
nodeNo = -1;
line = 0;

step = 'STEP_START';
while (~feof(fileID))
    tLine = fgetl( fileID );
    line = line+1;
    switch ( step )
        case 'STEP_IGNOREDATA'
            if strcmp(tLine,'    -1')
                step = 'STEP_START';
                % end of file and goal=='freq' ?
                if feof(fileID) && strcmp(goal,'freq')
                    goal = 'read';
                    switch resType
                        case 'P'
                            for k = 1:length(resNodes)
                                res{k} = zeros(1, nFreq);
                            end
                        case 'D2D'
                            for k = 1:length(resNodes)
                                res{k} = zeros(6, nFreq);
                            end
                        case {'D3D','RF'}
                            for k = 1:length(resNodes)
                                res{k} = zeros(3, nFreq);
                            end
                    end
                    fVec   = zeros(1,nFreq);
                    frewind(fileID);
                end
            else
                step = 'STEP_IGNOREDATA';
            end
        case 'STEP_START'
            if  strcmp(tLine,'    -1')
                step = 'STEP_READBLOCKID';
            else
                error('ita_readunvresults:Oh Lord. New dataset must start with dataset delimiter "    -1".')
            end
        case 'STEP_READBLOCKID'
            if strcmp(tLine, '  2414')
                step = 'STEP_READANALYSISDATA';
                subStep = 'READ_DATASET_LABEL';
            else
                disp(['ita_readunvresults: Ignoring unhandled Dataset %i.', sscanf(tLine, '%i')]);
                step = 'STEP_IGNOREDATA';
            end
        case 'STEP_READANALYSISDATA'
            switch (subStep)
                case 'READ_DATASET_LABEL'
                    subStep = 'READ_DATASET_NAME';
                case 'READ_DATASET_NAME'
                    subStep = 'READ_DATASET_LOCATION';
                case 'READ_DATASET_LOCATION'
                    if (sscanf(tLine, '%i') == 1)
                        subStep = 'READ_IDLine1';
                    else
                        error('ita_readunvresults:Oh Lord. Specified dataset location (%i) not supported.', datasetLocation)
                    end
                case 'READ_IDLine1'
                    subStep = 'READ_IDLine2';
                case 'READ_IDLine2'
                    subStep = 'READ_IDLine3';
                case 'READ_IDLine3'
                    subStep = 'READ_IDLine4';
                case 'READ_IDLine4'
                    subStep = 'READ_IDLine5';
                case 'READ_IDLine5'
                    subStep = 'READ_DATATYPE';
                case 'READ_DATATYPE'
                    typeVec = (sscanf(tLine, '%i %i %i %i %i %i')).';
                    if     isequal(typeVec,[0,5,1,301,5,1]) && strcmp(resType,'P')
                        subStep = 'READ_SPECIFICINT1';
                    elseif isequal(typeVec,[0,5,3,  8,5,6]) && strcmp(resType,'D2D')
                        subStep = 'READ_SPECIFICINT1';
                    elseif isequal(typeVec,[0,5,2,  8,5,3]) && strcmp(resType,'D3D')
                        subStep = 'READ_SPECIFICINT1';
                    elseif isequal(typeVec,[0,5,2,  9,5,3]) && strcmp(resType,'RF')
                        subStep = 'READ_SPECIFICINT1';
                    else
                        step = 'STEP_IGNOREDATA';
                    end
                case 'READ_SPECIFICINT1'
                    subStep = 'READ_SPECIFICINT2';
                case 'READ_SPECIFICINT2'
                    subStep = 'READ_SPECIFICREAL1';
                case 'READ_SPECIFICREAL1'
                    if strcmp(goal,'freq')
                        nFreq = nFreq+1;
                        step = 'STEP_IGNOREDATA';
                    else % strcmp(goal, 'read')
                        specificReal1 = sscanf(tLine, '%f %f %f %f %f %f');
                        fStep = fStep+1;
                        fVec(1,fStep)  = specificReal1(2);
                        subStep  = 'READ_SPECIFICREAL2';
                    end
                case 'READ_SPECIFICREAL2'
                    subStep = 'READ_NODENUMBER';
                case 'READ_NODENUMBER'
                    if strcmp(tLine,'    -1')
                        step = 'STEP_START';
                    else
                        nodeNo = sscanf(tLine, '%i');
                        resIdx = find(nodeNo == resNodes);
                        if isempty(resIdx)
                            subStep = 'SKIP_NODEDATA';
                        else
                            subStep ='READ_NODEDATA';
                        end
                    end
                case 'SKIP_NODEDATA'
                    switch resType
                        case {'P','D3D','RF'}
                            subStep = 'READ_NODENUMBER';
                        case 'D2D'
                            subStep = 'SKIP_NODEDATA2';
                    end
                case 'SKIP_NODEDATA2'
                    subStep = 'READ_NODENUMBER';
                case 'READ_NODEDATA'
                    switch resType
                        case 'P'
                            subStep = 'READ_NODENUMBER';
                            p = sscanf(tLine, '%f %f');
                            res{resIdx}(1,fStep) = p(1)+j*p(2);
                        case 'D2D'
                            subStep = 'READ_NODEDATA2';
                            d = sscanf(tLine, '%f %f %f %f %f %f');
                            res{resIdx}(1,fStep) = d(1)+j*d(2);
                            res{resIdx}(2,fStep) = d(3)+j*d(4);
                            res{resIdx}(3,fStep) = d(5)+j*d(6);
                        case 'D3D'
                            subStep = 'READ_NODENUMBER';
                            d = sscanf(tLine, '%f %f %f %f %f %f');
                            res{resIdx}(1,fStep) = d(1)+j*d(2);
                            res{resIdx}(2,fStep) = d(3)+j*d(4);
                            res{resIdx}(3,fStep) = d(5)+j*d(6);
                        case 'RF'
                            subStep = 'READ_NODENUMBER';
                            F = sscanf(tLine, '%f %f %f %f %f %f');
                            res{resIdx}(1,fStep) = F(1)+j*F(2);
                            res{resIdx}(2,fStep) = F(3)+j*F(4);
                            res{resIdx}(3,fStep) = F(5)+j*F(6);
                    end
                case 'READ_NODEDATA2'
                    subStep = 'READ_NODENUMBER';
                    rot = sscanf(tLine, '%f %f %f %f %f %f');
                    res{resIdx}(4,fStep) = rot(1)+j*rot(2);
                    res{resIdx}(5,fStep) = rot(3)+j*rot(4);
                    res{resIdx}(6,fStep) = rot(5)+j*rot(6);
                otherwise
                    error('ita_readunvresults: Unknown Type for switch case statement: %s', subStep);
            end
        otherwise
            error('ita_readunvresults: Unknown Type for switch case statement: %s', step);
    end
end

fclose(fileID);

if strcmp(format,'ita')
    header.Bits = 64;
    header.channelNames = {};
    header.channelUnits = {};
    header.nChannels = 0;
    header.comment = [];
    header.DateVector = [ round(clock), 0 ];
    header.Dyn = 100;
    header.signalType = 0;
    header.FileExt = '.ita';
    header.Filename = 'newfile';
    header.Filepath = '';
    header.History = {'ita_readunvresults(filename)'};
    header.OnTopdB = 0;
    header.samplingRate = SampleRate;
    header.Volt0dB = 1;
    header.nBins = (nSamples+2)/2;
    header.nSamples = nSamples;
    
    bin_dist = header.samplingRate/(2 * (header.nBins - 1)); % get distance between bins
    newfVec  = (0:nBins-1) .* bin_dist; % in Hz

    %% Add history line
    header = ita_metainfo_add_historyline(header,'ita_readunvresults','ARGUMENTS');

    switch resType
        case 'P'
            header.nChannels = 1;
            header.channelNames = {'Pressure'};
            header.channelUnits = {'Pa'};
        case 'D2D'
            header.nChannels = 6;
            header.channelNames = {'xDisplacement', 'yDisplacement', 'zDisplacement', 'xRotation', 'yRotation', 'zRotation'};
            header.channelUnits = {'mtr', 'mtr', 'mtr', 'rad', 'rad', 'rad'};
        case 'D3D'
            header.nChannels = 3;
            header.channelNames = {'xDisplacement', 'yDisplacement', 'zDisplacement'};
            header.channelUnits = {'mtr', 'mtr', 'mtr'};
        case 'RF'
            header.nChannels = 3;
            header.channelNames = {'xForce', 'yForce', 'zForce'};
            header.channelUnits = {'N','N','N'};
    end
    
    for k=1:length(res)
            results{k}.header         = header;
            results{k}.comment = sprintf('SoundSolve:\n Resultfile: %s\n Node %i\n', unvFilename, resNodes(k));
        for m=1:size(res{k},1)            
            results{k}.spk(m,:)       = interp_zeroextrap(fVec, res{k}(m,:), newfVec, interpType);
        end
    end
    
elseif strcmp(format,'raw')
    results.data     = res; 
    results.freq     = fVec;
    results.resnodes = resNodes;
    results.type = resType;
    results.origin = unvFilename;
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

function [resType, format, SampleRate, nSamples, interpType] = parseoptionalinput(options, varargin)
 
 resTypeAttr = {'P', 'D2D', 'D3D', 'RF'};
 formatAttr  = {'ita', 'raw'};
 interpAttr  = {'linear','spline','nearest'};

% Initialization of optional input parameter pairs
resType    = 'P';      % default
format     = 'raw';    % default
SampleRate = -1;       % default
nSamples   = -1;       % default
interpType = 'linear'; % default

varargin = varargin{:}; % extract cell array input from varargin
 
if options

    % arguments are in fixed parameter order
    if     options == 1
        resType = getString(varargin{1}, resTypeAttr);
    elseif options == 2 && ~isempty(varargin{2})
        resType = getString(varargin{1}, resTypeAttr);
        format = getString(varargin{2}, formatAttr);
    elseif options == 4 && ~isempty(varargin{3}) && ~isempty(varargin{4})
        resType = getString(varargin{1}, resTypeAttr);
        format = getString(varargin{2}, formatAttr);
        if strcmp(format,'ita') 
            if isnumeric(varargin{3}) && isnumeric(varargin{4})
                SampleRate = varargin{3};
                nSamples = varargin{4};
            else
                error('ita_readunvresults: input arguments 5 and 6 must be numeric.')
            end
        else
            disp('ita_readunvresults: input arguments 5 and 6 are ignored for result format "raw".')
        end
    elseif options == 5 && ~isempty(varargin{3}) && ~isempty(varargin{4}) && ~isempty(varargin{5})
        resType = getString(varargin{1}, resTypeAttr);
        format = getString(varargin{2}, formatAttr);
        if strcmp(format,'ita') 
            if isnumeric(varargin{3}) && isnumeric(varargin{4})
                SampleRate = varargin{3};
                nSamples = varargin{4};
            else
                error('ita_readunvresults: input arguments 5 and 6 must be numeric.')
            end
        else
            disp('ita_readunvresults: input arguments 5 and 6 are ignored for result format "raw".')
        end
        interpType = getString(varargin{5}, interpAttr);
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
    interpData(idxS:idxE) = interp1(freq, data, newFreq(idxS:idxE), modus);
else
    error('FUNCTION:INTERP_ZEROEXTRAP: Invalid first input argument.');
end

%end function
end