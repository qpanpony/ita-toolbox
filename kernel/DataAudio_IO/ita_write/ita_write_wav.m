function result = ita_write_wav(varargin)
%ITA_WRITE_ITA - Write audioObj to disk
%   This functions writes data to wav files
%
%   Call: ita_write_wav (itaAudio,filename, Options)
%
%   Options: nbits - Resolution in bits (8/16/24/32), 16 is default
%            overwrite - overwrite existing file without asking
%
%
%   See also ita_read, ita_audioplay, ita_make_header.
%
%   Reference page in Help browser
%       <a href="matlab:doc ita_write">doc ita_write</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


if nargin == 0 % Return possible argument layout
    result{1}.extension = '*.wav';
    result{1}.comment = 'WAVE Files (*.wav)';
    return;
end

sArgs = struct('pos1_data','itaAudio','pos2_filename','char','nbits',16,'overwrite',false);
[data, filename, sArgs] = ita_parse_arguments(sArgs,varargin); 

if max(max(abs(data.timeData))) > 1 && sArgs.nbits < 32
   data = ita_normalize_dat(data)*.99;
   ita_verbose_info('Normalizing the data for wav export.',1)
end

if exist(filename,'file') && ~sArgs.overwrite % Error because file exists
    error('ITA_WRITE_WAV:FILE_EXISTS',[mfilename ': Careful, file already exists, use overwrite option to disable error']);
else % Everything ok, save

    ita_verbose_info([mfilename ': Careful, overwriting existing file']);
    
    %versionswitch for backwards compability
    versionstr = version;
    if str2double(versionstr(1:3)) < 8.3 % mgu:unkown what is with 8.2, but this should work
        wavwrite(data.timeData,data.samplingRate,sArgs.nbits,filename);
    else
        audiowrite(filename,data.timeData,data.samplingRate,'BitsPerSample',sArgs.nbits);
    end
    
end

result = 1;
end

