function varargout = ita_zpk2audio(varargin)
%ITA_ZPK2AUDIO - convert poles and zeroes to itaAudio
%  This function converts TODO HUHU Documentation
%
%  Syntax:
%   audioObjOut = ita_zpk2audio(audioObjIn, z, p, k)
%
%
%  Example:
%   audioObjOut = ita_zpk2audio(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_zpk2audio">doc ita_zpk2audio</a>

% <ITA-Toolbox>
% This file is part of the application PoleZeroProny for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal -- Email: pdi@akustik.rwth-aachen.de
% Created:  30-Aug-2010 


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudioFrequency', 'pos2_z', 'double','pos3_p', 'double','pos4_k', 'double' );
[input,z,p,k,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

input.freqData = freqz(poly(z)*k, poly(p), input.freqVector/input.samplingRate*pi*2);
input.channelNames{1} = 'reconstructed';



%% Set Output
varargout(1) = {input}; 

%end function
end