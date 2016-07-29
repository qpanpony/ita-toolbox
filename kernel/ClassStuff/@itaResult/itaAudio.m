function audioObj = itaAudio(varargin)
%ITAAUDIO Summary of this function goes here
%   Detailed explanation goes here

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

if nargin
    if ~isa(varargin{1},'itaResult')
        error('itaResult.itaAudio:wrong input argument');
    end
    % does the typecast from itaResult to itaAudio
    % (including interpolation)
    ita_verbose_info('WARNING: Are you sure you know what you are doing? Converting a itaResult in itaAudio!',0); 
    audioObj  = ita_result2audio(varargin{:});
else
    error('itaResult.itaAudio:I need an input argument');
end

end

