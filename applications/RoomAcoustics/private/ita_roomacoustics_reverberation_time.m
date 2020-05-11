function varargout = ita_roomacoustics_reverberation_time(varargin)
%ITA_ROOMACOUSTICS_REVERBERATION_TIME - Reverberation Time of an RIR
%
%  This function calculates the reverberation time of a given room impulse
%  response according to ISO 3382. Since this funtion needs the energy
%  decay curve of the impulse response, different options for this curve can be
%  chosen.
%
%  Syntax:
%  Call: Parameters = ita_roomacoustics_reverberation_time(itaAudio, options)
%
%
%   Options (default):
%           'freqRange'
%           'bandsPerOctave'
%           'intersectionTime'
%           'shift'     (false)          : It shifts the IR according to ISO 3382
%
%  Example:
%   audioObjOut = ita_roomacoustics_reverberation_time(IR,'shift')
%
%   See also ita_roomacoustics, ita_roomacoustics_EDC, ita_roomacoustics_EDCnew,
% ita_roomacoustics_reverberation_timeNew.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics_reverberation_time">doc ita_roomacoustics_reverberation_time</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created: 12-Jan-2009



%% Initialization
narginchk(1,24);
sArgs      = struct('pos1_ir','itaAudio','shift', true,'calcEdc',true, 'freqRange', ita_preferences('freqRange'), 'bandsPerOctave', ita_preferences('bandsperoctave'), 'intersectionTime', 'itaResult', 'lateRevEstimation', 'itaResult', 'noiseRMS',  'itaResult', 'edcMethod', 'cutWithCorrection', 'plot', false, 'EDT', false, 'LDT', false,  'T10', false, 'T15', false, 'T20', false, 'T25', false, 'T30', false, 'T40', false,  'T50', false, 'T60', false );
[ir,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Calculation of decay curve - SCHROEDER backwards time integration
if sArgs.calcEdc
    if sArgs.shift
        ir  = ita_time_shift(ir,'20dB'); %iso 3382 - 20dB before max peak
    end
    edc = ita_roomacoustics_EDC(ir, 'method', sArgs.edcMethod, 'intersectionTime', sArgs.intersectionTime, 'lateRevEstimation', sArgs.lateRevEstimation, 'noiseRMS', sArgs.noiseRMS);
    
else
    edc = ir;
    % TODO: check if cannelUnits are Pa^2
end


parNameCell =               {'EDT'  'LDT' 'T10'  'T15'  'T20'  'T25'  'T30'  'T40'  'T50'  'T60'};
parameters = struct('high', {   0    -25   -5     -5     -5     -5     -5     -5     -5     -5 }, ...
                    'low',  { -10    -35  -15    -20    -25    -30    -35    -45    -55    -65 }, ...
                    'name',  parNameCell     );


par2calc = [ sArgs.EDT  sArgs.LDT sArgs.T10 sArgs.T15 sArgs.T20 sArgs.T25 sArgs.T30 sArgs.T40 sArgs.T50 sArgs.T60 ].';

if ~any(par2calc) % if no input parameter => selection of Parameters according to ita_roomacoustics_parameters()
    par2calc    = cell2mat(ita_roomacoustics_parameters(parNameCell{:}));
end

nParameters2calc =  sum(par2calc);
par2calcIdx      =  find(par2calc);


if ~nParameters2calc  % nothing to do
    varargout = {};
    ita_verbose_info('nothing to do',1)
    return
end

%% get ANSI freqs
freqvec                             = ita_ANSI_center_frequencies(sArgs.freqRange, sArgs.bandsPerOctave, ir.samplingRate);
revTimesDummy                       = itaResult(zeros(numel(freqvec),ir.nChannels),freqvec,'freq');
revTimesDummy.channelCoordinates    = repmat(ir.channelCoordinates.n(1),[ir.nChannels 1]);
revTimesDummy.channelUnits          = repmat({'s'},1,ir.nChannels);
revTimesDummy.channelUserData       = ir.channelUserData;
revTimesDummy.allowDBPlot           = false;


%% Linear Regression - part of rir - over all channels
raw_edc_all     = (10./log(10))*log(edc.timeData);  % faster than log10()
timeVector      = edc.timeVector;
revTimesData    = nan(nParameters2calc,edc.nChannels);

for iCh = 1:edc.nChannels
    
    % revmove tailing nans to speed up following searches
    idxFirstNan = find(isnan(raw_edc_all(:,iCh)), 1, 'first');
    if ~isempty(idxFirstNan)
        raw_edc = raw_edc_all(1:idxFirstNan-1,iCh);
    else
        raw_edc = raw_edc_all(:,iCh);
    end
    
    clear firstSample5dB
    
    for iPar = length(par2calcIdx):-1:1
        
        % search for limits for regession
        if parameters(par2calcIdx(iPar)).high == -5
            if exist('firstSample5dB', 'var')           % avoid multiple calculation of same -5 dB index
                firstSample  = firstSample5dB;
            else
                firstSample   = find(raw_edc <= -5  ,1,'first'); % look for -5  dB sample
                firstSample5dB = firstSample;
            end
        elseif parameters(par2calcIdx(iPar)).high == 0
            firstSample = 1;
        else
            firstSample   = find(raw_edc <= parameters(par2calcIdx(iPar)).high ,1,'first'); % look for -xx dB sample
        end
        
        lastSample    = find(raw_edc <= parameters(par2calcIdx(iPar)).low ,1,'first'); % look for -5-TX dB sample
        
        % calculate regession
        if ~isempty(lastSample)
            dec_func_dB_eval    = raw_edc(firstSample:lastSample);                  % select a part of a curve
            time_vector         = timeVector(firstSample:lastSample);               % corresponding  time vector
            X                   = [ones(lastSample-firstSample+1,1) time_vector];   % matrix for 1 and t.
            coeff               = X\dec_func_dB_eval;                               % calculate regression
            
            revTimesData(iPar,iCh) = -60./coeff(2);                  % coeff(2) is b in "a*1+b*t"
            
            if sArgs.plot
                endPlotIdx = min(length(raw_edc), 2*lastSample);
                plot(timeVector(1:endPlotIdx),   raw_edc(1:endPlotIdx), 'linewidth', 2)
                hold all
                plot(timeVector(firstSample:lastSample), coeff(1)+coeff(2)*timeVector(firstSample:lastSample), 'linewidth', 2)
                hold off
                xlim(timeVector([1 endPlotIdx]))
                fprintf('  t1: %2.2f  deltaT: %2.2f \n', firstSample/ir.samplingRate, (lastSample-firstSample)/ir.samplingRate)
            end
            
        else
            revTimesData(iPar,iCh) = NaN;
            ita_verbose_info(sprintf('too low SNR for %s (channel %i: %s)', parameters(par2calcIdx(iPar)).name,iCh, edc.channelNames{iCh} ),1)
        end
        
    end
end

% fill itaResult
for iPar = 1:length(par2calcIdx)
    outputStruct.(parameters(par2calcIdx(iPar)).name)          = revTimesDummy;
    outputStruct.(parameters(par2calcIdx(iPar)).name).freqData = revTimesData(iPar,:).';
    outputStruct.(parameters(par2calcIdx(iPar)).name).comment  = [ ir.comment ' -> ' parameters(par2calcIdx(iPar)).name];
end

%% Find output parameters
varargout(1) = {outputStruct};

if nargout >= 2
    varargout{2} = edc;
end
if nargout >= 3
    varargout{3} = timeVector([firstSample lastSample]);
end
%end function
end