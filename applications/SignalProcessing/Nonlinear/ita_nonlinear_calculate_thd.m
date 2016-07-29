function varargout = ita_nonlinear_calculate_thd(varargin)
%ITA_NONLINEAR_CALCULATE_THD - Function calculates THD, THD+N, HD of a distorted signal
%  This function calculates the THD, HD, THD+N THD_F from a distorted
%  signal under knowledge of the used excitation signal. The input can either
%  be a distorted sine signal or a impulse response measured with a sweep
%  signal. In case of an impulse response, the output is an itaResult in 
%  the frequency domain, whereas in case of a sine signal, the output is a 
%  scalar rms value. 
%
%   THD   - Total Harmonic Distortion
%   HD    - Harmonic Distortion
%   THD+N - Total Harmonic Distortion + Noise
%   THD_F - Total Harmonic Distortion related only to the Fundamental
% 
%  Syntax:
%   audioObjOut = ita_nonlinear_calculate_thd(audioObjIn, options)
%
%   Options (default):
%           'degree' (5)                : degree of the highest harmonic to be considered
%           'excitation' (sweep)        : excitation signal type
%           'excitationFrequency' ([])  : frequency of the exciting sine signal
%           'sweeprate' ([])            : this can either be the sweeprate
%                                         or in the sweep used as excitation
%
%  Example:
%   [THD, HD, THDN, THDF] = ita_nonlinear_calculate_thd(audioObjIn, 'excitation', 'sweep', 'degree', 5)
%
%  See also:
%   ita_loudspeakertools_maxSPL, ita_nonlinear_extract_harmonics
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_nonlinear_calculate_thd">doc ita_nonlinear_calculate_thd</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@rwth-aachen.de
% Created:  06-Jan-2015 


%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio', 'excitation', 'sweep','degree',5,'excitationFrequency',[],'sweeprate',[]);
[audioObjIn,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Extract the harmonics
switch sArgs.excitation
    case 'sweep'
        if ~isempty(sArgs.sweeprate)
            audioObjHarm = ita_nonlinear_extract_harmonics(audioObjIn,sArgs.sweeprate,'degree',sArgs.degree);
        else
            ita_verbose_info('You need to give me the sweeprate or the complete sweep signal from your measurement.',0);
            return;
        end
        audioObjIn = ita_nonlinear_shift_frequency_vector(audioObjIn, 'left');
        harmonics(sArgs.degree,1) = itaAudio();
        for idx= 1:audioObjHarm.nChannels
            harmonics(idx) = audioObjHarm.ch(idx);
        end
        HD(sArgs.degree-1,1) = itaAudio(); 
        
        
        THD = sqrt((sum((harmonics(2:end))^2)))/sqrt(sum((harmonics(1:end))^2));
        %THDN (+noise)
        THDN = sqrt((sum((harmonics(2:end))^2)))/sqrt((audioObjIn)^2);
        %THD_F (only fundamental wave as reference)
        THD_F = sqrt((sum((harmonics(2:end))^2)))/sqrt((harmonics(1))^2);
        for idx = 2:sArgs.degree; 
            HD(idx-1) = sqrt((harmonics(idx))^2)/sqrt(sum((audioObjIn)^2));
        end
        
        % convert to itaResult
        HD = HD.merge;
        HD = itaResult(HD.freqData,HD.freqVector,'freq');
        for idx = 2:HD.nChannels+1
            HD.channelNames(idx-1) = {['HD_{' num2str(idx) '}']};
        end
        THD.channelNames = {'THD'};
        THDN.channelNames = {'THD + Noise'};
        THD_F.channelNames = {'THD related to fundamental'};
        THD = itaResult(THD.freqData,THD.freqVector,'freq');
        THDN = itaResult(THDN.freqData,THD.freqVector,'freq');
        THD_F = itaResult(THD_F.freqData,THD_F.freqVector,'freq');
        
        
    case 'sine'
        if strcmp(sArgs.excitation, 'sine') && isempty(sArgs.excitationFrequency)
            ita_verbose_info('You need to give me the Frequency of the sine signal!',0);
            return;
        end
        harmonics = zeros(sArgs.degree,1);
        for idxHarm = 1:sArgs.degree
            % check if above freq range
            if idxHarm*sArgs.excitationFrequency < audioObjIn.samplingRate/2
                harmonics(idxHarm) = audioObjIn.freq2value(idxHarm*sArgs.excitationFrequency);
            end
        end
        HD = zeros(sArgs.degree-1,1);
        audioObjIn = audioObjIn.rms;
        
        THD = sqrt((sum(abs(harmonics(2:end)).^2)))/sqrt(sum(abs(harmonics(1:end)).^2));
        %THDN (+noise)
        THDN = sqrt((sum(abs(harmonics(2:end)).^2)))/abs(audioObjIn);
        %THD_F (only fundamental wave as reference)
        THD_F = sqrt((sum(abs(harmonics(2:end)).^2)))/abs(harmonics(1));
        for idx = 2:sArgs.degree; 
            HD(idx-1) = abs(harmonics(idx))./sqrt(sum(abs(audioObjIn).^2));
        end
        
    otherwise
        ita_verbose_info([sArgs.excitation 'is not a valid excitation signal!'],0);
        return;
end

%% Set Output
varargout{1} = THD;
varargout{2} = HD;
varargout{3} = THDN;
varargout{4} = THD_F;


end