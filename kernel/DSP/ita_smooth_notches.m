function varargout = ita_smooth_notches(varargin)
%ITA_SMOOTH_NOTCHES - Smooth Notches in Frequency domain
%  This function smoothes notches in a spectrum. Used e.g. for loudspeaker
%  equalization. Implementation of "compare and squeeze" after Swen Mueller
%  Dissertation (pg. 193/194).
%
%  Syntax:
%   audioObjOut = ita_smooth_notches(audioObjIn, options)
%
%   Options (default):
%           'bandwidth' (1/3)    : fractional octaves
%           'threshold' (3dB)    : variations of up to threshold will be
%                                  ignored and not smoothed.
%           'smoothType' ('LogFreqOctave1')
%                                : type of smoothing used to smooth curve.
%                                  Please see ita_smooth for more details.
%
%  Example:
%   audioObjOut = ita_smooth_notches(audioObjIn,12)
%
%  See also:
%   ita_smooth, ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_smooth_notches">doc ita_smooth_notches</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Author: Christian Haar -- Email: christian.haar@akustik.rwth-aachen.de
% Created:  13-Apr-2011



%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio', 'bandwidth', 1/3,'squeezeFactor',0.3,'threshold',3,'smoothType','LogFreqOctave1');
[input,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Smooth Notches
% sgolay = Savitzky-Golay filter. Only possible with Curve Fitting Toolbox.
% ita_smooth will catch this.
input_smooth = ita_smooth(input,sArgs.smoothType, sArgs.bandwidth, 'Abs+GDelay','sgolay',2);
ratio = input/input_smooth;

if sArgs.threshold  % next step is only necessary if threshold was not set to zero.
    ratio = abs(ratio.freq);
    vector = (ratio < 10^(-abs(sArgs.threshold)/20));
    vector(1,:) = vector(2,:); % avoid differences in DC
    diffVector = diff(vector,1,1);
    window = ones(size(vector));
    for idx = 1:input.nChannels
        start_idx = find(diffVector(:,idx) == 1);
        end_idx = find(diffVector(:,idx) == -1);
        
        for jdx = 1:min(numel(start_idx),numel(end_idx)) %use end to ignore case were smoothed signal is smaller at the end of the spectrum
            S = find(ratio(1:start_idx(jdx),idx) > 1,1,'last')+1;
            E = end_idx(jdx)+find(ratio(end_idx(jdx):end,idx) > 1,1,'first')-2;
            window(S:E,idx) = ratio(S:E,idx);
        end
    end
else
    ratio = abs(ratio);
    window = min(ratio.freqData, 1);
end

window = 10.^(-log10(window).*(1-sArgs.squeezeFactor));
%TODO: correctly treat the problem when window is infinite.
window(~isfinite(window)) = 1;

output = input;
output.freqData = window.*input.freqData;
% blend between original and abs smoothed version
% output.freqData  = (vector .* input.freqData + (1-vector) .* input_smooth.freqData);

%% Add history line
output = ita_metainfo_add_historyline(output,mfilename,varargin);

%% Set Output
varargout(1) = {output};

%end function
end