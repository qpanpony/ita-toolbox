function ita_realtime_dsp(varargin)
%ITA_REALTIME_DSP - Realtime signal processing from sound device
%
%  Syntax:
%   ita_realtime_dsp(Options)
%
%   Options: 
%       funfunction - handle to function that handles signalprocessing
%       funarguments - additional arguments for the fun function (first one will always be the recorded itaAudio)
%       blocksize - more means more lag but less cracks
%       inputchannels -
%       outputchannels - 
%       buffersize - 
%       asiobuffersize - 
%
%  Example:
%   see: demo_ita_realtime_dsp
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_pressure_gradient_to_velocity">doc ita_pressure_gradient_to_velocity</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  22-Jun-2010 


sArgs = struct('funfunction', @ita_normalize_dat, 'funarguments',cell(1), 'blocksize',2^12 , 'inputchannels', 1, 'outputchannels', 1 , 'buffersize', 2, 'asiobuffersize', 256 );
sArgs = ita_parse_arguments(sArgs,varargin);


%% Advanced Settings - ToDo: into parser
segment_size = sArgs.blocksize; 
in_channels = sArgs.inputchannels;
out_channels = sArgs.outputchannels;
nonblockingbuffersize = sArgs.buffersize;
asiobuffersize = sArgs.asiobuffersize; 
abort = false;
sampling_rate = ita_preferences('samplingRate');

ita_verbose_info(['Lag: ' num2str(segment_size/sampling_rate/60,2) ' min'],1)

%Generate some empty audio, needed later
empty = ita_generate('emptydat',sampling_rate,log2(segment_size));
empty = empty.ch(ones(numel(in_channels),1));
input = empty;
output = empty;
overlap = empty;

% Generate Cancel Button
%CancelButton = stoploop({'Stop DSP'});

% Absolutely no display as it is too slow
verboseMode = ita_preferences('verboseMode');
ita_preferences('verboseMode',-1); 

while 1 %~CancelButton.Stop()
    % Record audio
    input = ita_portaudio(output, 'InputChannels',in_channels,'OutputChannels', out_channels ,'block',false,'reset',false,'cancelbutton',0,'nonblockingbuffersize',nonblockingbuffersize,'AsioBufferSize',asiobuffersize);
    input = ita_metainfo_rm_historyline(input,'all');
    
    if input.nSamples > 3 % First runs are empty until buffer is full
        funargs = [{input} sArgs.funarguments(:)];
        output =  sArgs.funfunction(funargs{:}); 
            
        %% Overlap-Add
        if output.nSamples > segment_size;
            overlap.timeData(overlap.nSamples+1:output.nSamples,:) = 0;
            output = output + overlap;
            overlap = output;
            overlap.timeData(1:segment_size,:) = [];
            output.timeData(segment_size+1:end,:) = [];
        end
    end
end


% Reset verboseMode
ita_preferences('verboseMode',verboseMode);


end