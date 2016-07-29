function varargout = ita_roomacoustics_noisedetect(varargin)
%ITA_ROOMACOUSTICS_DETECTIONSNR - SNR, I_time and Tmax of a RIR
%
%  This function calculates the signal-to-noise ratio (SNR) of a
%   given room impulse response. It calculates the time when
%   the decay curve intersects the line of the background noise.
%   Additionally it gives the maximal reliable reverberation time that
%   can be calculated acoording to the SNR. Optionally the curve can be
%   windowed by using one of the following arguments
%
%  Syntax:
%       itaResult            = ita_roomacoustics_detectionSNR(IR, options)
%       [itaResult IR_win ]  = ita_roomacoustics_detectionSNR(IR, options)
%
%  select parameters to calculate (if no parameters are specified values from ita_roomacoustics_parameters() will be taken):
%   [...] = ita_roomacoustics_detectionSNR(IR, options, 'SNR', 'Intersection_Time', 'Max_Reliable_RTs')
%
%
%
%   Options (default):
%           'plot' ('off')   : It plots the original curve, its approximation and
%                              the intersection point in time domain.
%           'shift' ('off')  : It shifts the curve to find the peak of the
%                              RIR according to ISO 3382
%           'freqRange' (ita_preferences('freqRange')           : range of analyzed frequencies
%           'bandsPerOctave' (ita_preferences('bandsPerOctave') : bands per octave
%
%  Example:
%   audioObjOut = ita_roomacoustics_detectionSNR(IR,'shift','plot','window')
%
%  See also:
%   ita_toolbox_guidx, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics_detectionSNR">doc ita_roomacoustics_detectionSNR</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

% Author: Jonathan Oberreuter -- Email: jonathan.oberreuter@akustik.rwth-aachen.de
% Created:  27-May-2010


%% call gui
if ~nargin
    ita_roomacoustics_noisedetect_gui()
    return
end

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio','plot',false ,'shift',false , 'freqRange', ita_preferences('freqRange'), 'bandsPerOctave', ita_preferences('bandsPerOctave'), 'SNR', false, 'Intersection_Time', false, 'Max_Reliable_RTs', false);
[ir_raw,sArgs] = ita_parse_arguments(sArgs,varargin);


%% Selection of Parameters according to ita_roomacoustics_results
par2calc = [sArgs.SNR, sArgs.Intersection_Time, sArgs.Max_Reliable_RTs];

if ~any(par2calc)   % no specification form user => take values from ita_roomacoustics_parameter()
    par2calc = cell2mat(ita_roomacoustics_parameters('SNR', 'Intersection_Time', 'Max_Reliable_RTs'));
end

% if there is nothing to do, just return
% TODO: was wenn wir nur gefensterte audios haben wollen???
if ~any(par2calc) && (nargin == 1)
    varargout = {};
    return;
end

%% shifting 
if sArgs.shift
    ir_raw = ita_time_shift(ir_raw,'20dB'); %iso 3382 - 20dB before max peak
    ita_verbose_info('shifting impulse response',2)
end

%% Detect IR - noise - intersection
nChannels           = ir_raw.nChannels;
Deg                 = floor(ir_raw.fftDegree);  % if fftDegree is not integer.
nIntervals          = 2^(floor(Deg*8/17));      % number of intervals
nSamplesPerInterval = 2^Deg/nIntervals;         % Number of samples per interval

%%
timeData_raw    = 20*log10(abs(ir_raw.timeData)); %Energie curve; pdi speed reasons no itaAudios...
timeVector      = ir_raw.timeVector; %pdi:outside of for loop, speed reasons

empty_values = zeros(1,nChannels);

%these variables are now initialized instead of settings values in the for loop
SNR     = empty_values + NaN;
Tmax    = SNR;
Tdet    = repmat(double(ir_raw.trackLength)*0.9,1,nChannels); %this is already windowed

pos     = empty_values;
dif2    = empty_values;
valmin  = empty_values;

ScN     = empty_values;
valmax  = empty_values;

sr      = ir_raw.samplingRate;

X        = zeros(nChannels,nIntervals);


for iCh = 1:nChannels
    timeData   = timeData_raw(:,iCh);
    
    [maxInInterval idxMaxInInterval] =  max(reshape(timeData(1:nIntervals*nSamplesPerInterval), nSamplesPerInterval, nIntervals),[],1);
    idxMaxInInterval = idxMaxInInterval + (0:nIntervals -1)* nSamplesPerInterval;
    
    maxInInterval_smoothed       = maxInInterval;
    
    dynamicRange =  max(maxInInterval) - min(maxInInterval) ; %current maximal difference
    if isinf(dynamicRange)
        dynamicRange = 90;
    end
    
    for limit = 1:4 %SMOOTHING %pdi: was 5 before
        for j=2:nIntervals-1
            % Changing the points for smoothing.
            if abs(maxInInterval_smoothed(j)-maxInInterval_smoothed(j-1))<0.3*dynamicRange && abs(maxInInterval_smoothed(j+1)-maxInInterval_smoothed(j))<0.3*dynamicRange
                %changing 0.3*dynamicRange for a fixed value
                maxInInterval_smoothed(j)=(maxInInterval_smoothed(j-1)+maxInInterval_smoothed(j+1))/2; %Smoothing
            end
        end
        for j=2:nIntervals-1
            % the scopes
            ScN(iCh,j) = sr *(maxInInterval_smoothed(j)-maxInInterval_smoothed(j-1))/(idxMaxInInterval(j)-idxMaxInInterval(j-1));
        end
        ScN(iCh,1)  = ScN(iCh,2);
        ScN(iCh,nIntervals) = ScN(iCh,nIntervals-1);
    end
    
    
    %% Now working with smoothed points maxInInterval_smoothed
    valmin(iCh)=min(maxInInterval_smoothed(:));
    if valmin(iCh)==-Inf
        valmin(iCh)=max(maxInInterval_smoothed(:))-90; %90 can be another value.
    end
    dif2(iCh)=abs(valmin(iCh)-max(maxInInterval_smoothed(:))); %difference after Smoothing
    pos(iCh)=0;
    for j=3:nIntervals %1st Criteria: Difference and mean of slopes.
        if abs(maxInInterval_smoothed(j)-valmin(iCh))<0.4*dif2(iCh) && abs(mean(ScN(iCh,j-2:j)))<8 %Slope Criteria
            pos(iCh)=j; %position of detection acoording to intervals nIntervals
            break
        end
    end
    if pos(iCh)==0 %2nd criteria:
        for j=3:nIntervals
            if abs(maxInInterval_smoothed(j)-valmin(iCh))<0.03*dif2(iCh) %difference criteria
                pos(iCh)=j;
                %                 ita_verbose_info('there is almost no noise in this impulse response',1)
                limit=10; %just a trick. Here theres a windowed IR.
                break
            end
        end
    end
    X(iCh,:)    = timeVector(idxMaxInInterval); %time
    
    %% Checking for further Problems
    if pos(iCh) == 0 ||limit == 10 %
        %        disp('Is this an impulse responce?')
    else
        Tdet(iCh)   = X(iCh,pos(iCh));
        valmax(iCh) = max(maxInInterval_smoothed(1:pos(iCh))); %Be careful with the last part. Just to Tdet-sample
        valmin(iCh) = maxInInterval_smoothed(pos(iCh)); %Take the Level of intersection Point.
        SNR(iCh)    = valmax(iCh)-valmin(iCh);
        Tmax(iCh)   = 10*floor((SNR(iCh)-15)/10); %evaluation of reverberation time up to Tmax is possible
    end
    
    %% Plotting if this was defined at the beginning
    if sArgs.plot
        %% new
        
        figure
        plot(X(iCh,:),maxInInterval,'b')
        hold all
        plot(X(iCh,:),maxInInterval_smoothed(:),'or-')
        %          p1=[0 X(iCh,size(X(iCh,:),2))];
        %          p2=valmin(iCh)*[1 1];
        %          p3=Tdet(iCh)*[1 1];
        %          p4=[valmin(iCh)-20 valmin(iCh)+20];
        %          plot(p1,p2,'g','LineWidth',1.5)
        %          plot(p3,p4,'g','LineWidth',1.5)
        line([[0; X(iCh,end)] Tdet(iCh)*[1; 1]] ,[valmin(iCh)*[1 1]; [valmin(iCh)-20 valmin(iCh)+20]]','LineWidth',1.5, 'Color', 'g')
        title(sprintf('SNR: %2.2f dB, Intersection: %3.3f ms', SNR(iCh), 1000*Tdet(iCh)))
        hold off
        
    end
end

Tmax = min(Tmax,60);

%% Definition of Results
frequencystr = ita_ANSI_center_frequencies(sArgs.freqRange, sArgs.bandsPerOctave);

values = [SNR(:)'; Tdet(:)'; Tmax(:)']; % try with ()'
names  = {'Signal to Noise Ratio SNR (dB)','Intersection Time','Maximal T to be calculated ()'};
units  = {'','s',''};

snr    = itaResult(zeros(length(frequencystr),1),frequencystr,'freq');
snr.channelCoordinates = ir_raw.channelCoordinates.n(1);
snr    = repmat(snr,[1,3]);
values = values.';

for paridx=1:3
    snr(paridx).freq         = values(:,paridx);
    snr(paridx).comment      = [ir_raw.comment ' -> ' names{paridx}];
    snr(paridx).channelUnits = repmat(units(paridx),1,nChannels);
end

if any(par2calc)
    snr = snr(logical(par2calc));
else
    snr = itaResult(0);
end

%% output
if nargout == 1
    varargout(1) = {snr};
elseif nargout == 2
    data = repmat(ir_raw.ch(1),ir_raw.nChannels,1);
    Tend = min(Tdet+0.2,double(ir_raw.trackLength));
    for iCh = 1:ir_raw.nChannels
        if limit==10
            data(iCh) = ir_raw.ch(iCh);
        else
            data(iCh) = ita_time_window(ir_raw.ch(iCh),[Tdet(iCh) Tend(iCh)],'time');
        end
    end
    varargout{1} = snr;
    varargout{2} = merge(data);
    
end
end