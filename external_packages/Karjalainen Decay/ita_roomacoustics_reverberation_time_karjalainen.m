function varargout = ita_roomacoustics_karjalainen(varargin)
%ITA_ROOMACOUSTICS_NOISEDETECT_KARJALAINEN - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_roomacoustics_noisedetect_karjalainen(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_roomacoustics_noisedetect_karjalainen(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_roomacoustics_noisedetect_karjalainen">doc ita_roomacoustics_noisedetect_karjalainen</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  04-Jul-2011 




%% Initialization and Input Parsing
sArgs           = struct('pos1_data','itaAudio', 'exp', 0.4, 'plot', false, 'bandsPerOctave', ita_preferences('bandsPerOctave'), 'freqRange', ita_preferences('freqRange'));
[input ,sArgs]  = ita_parse_arguments(sArgs,varargin);

%%

input = ita_time_shift(input, '10dB');

[inputFilter freqVec]  = ita_fractional_octavebands(input, 'bandsPerOctave', sArgs.bandsPerOctave, 'freqRange', sArgs.freqRange);


v = zeros(inputFilter.nChannels,3);
dbVal = 10*log10((inputFilter.timeData).^2);
for iCh = 1: inputFilter.nChannels
    [v(iCh,:) norm] = karjalainen_decay2_fit([dbVal(:,iCh)- max(dbVal(:,iCh)), input.timeVector ], sArgs.exp ,[],1);
end

% T60         = -log(1e-3)/v(2);
% sigAmp      = 20*log10(v(1));
% noiseAmp    = 20*log10(v(3));
% 
% fprintf('  T:     %2.2f s\n  sig:   %2.2f dB\n  noise: %2.2f dB\n', T60 , sigAmp , noiseAmp)



result = itaResult(input);
result.freqVector = freqVec;
result.freqData = -log(1e-3)./v(:,2) * -1 ; % warum da negitives tau raus kommt weiﬂ ich wohl nicht so genau

%% plot 
if sArgs.plot
    z = 20*log10(decay_model(v,input.timeVector,1));
    edc = ita_roomacoustics_EDC(input);
    figure;
    plot(input.timeVector, [20*log10(abs(edc.timeData)) , z])
    legend({'edc' 'model output'})
    grid on
    title(sprintf('T: %2.2f s -- sig: %2.2f dB  --  noise: %2.2f dB', T60 , sigAmp , noiseAmp))
end
%%
% sample use of the ita warning/ informing function
% ita_verbose_info('Testwarning',0); 


%% Add history line
% input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {result}; 

%end function
end