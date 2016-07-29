function result = ita_write_ita(varargin)
%ITA_WRITE_ITA - Write audioObj to disk
%   This functions writes data Mtalab-files (.ita or .mat)
%
%   Call: ita_write_ita (itaAudio,filename, Options)
%
%   Options: append - append to existing file (as instance of multi instance)
%            overwrite - overwrite existing file without asking
%            export - save as struct rather than as class
%            export_fields - specify which fields should be exported
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


%% Init
thisFuncStr  = [upper(mfilename) ':'];

%% ToDo: Help!
if nargin == 0 % Return possible argument layout
    result{1}.extension = '*.ita';
    result{1}.comment = 'ITA audioObject (*.ita)';
    
    result{2}.extension = '*.mat';
    result{2}.comment = 'Matlab data file format (*.mat)';
    return;
end

% mpo, 26.4.13: export option changed to true, we do not want to save objects
sArgs = struct('pos1_data','itaSuper','pos2_filename','char','append',false,'overwrite',false,'export',true);
% Default fields for .mat export (only used if export is set to true);
[ITA_TOOLBOX_AUDIO_OBJECT, filename, sArgs] = ita_parse_arguments(sArgs,varargin);

if sArgs.append && exist(filename,'file') % Append
    try
        ITA_TOOLBOX_AUDIO_OBJECT = [load(filename,'-mat') ITA_TOOLBOX_AUDIO_OBJECT]; %#ok<NASGU>
    catch errmsg
        error([thisFuncStr 'WRONG_FORMAT'],'Append won''t work, file not compatible');
    end
    save(filename,'ITA_TOOLBOX_AUDIO_OBJECT');
elseif exist(filename,'file') && ~sArgs.overwrite % Error because file exists
    error([thisFuncStr 'FILE_EXISTS'],[mfilename ': Careful, file already exists, use overwrite option to disable error']);
else % Everything ok, save
    if ~sArgs.export % Save with class-definition
        save(filename,'ITA_TOOLBOX_AUDIO_OBJECT');
        ita_verbose_info([thisFuncStr  'File written successfully.'],2)
    else % Export mat-file without class definition
        for iStruct = 1:numel(ITA_TOOLBOX_AUDIO_OBJECT)
            resultStruct(iStruct)= saveobj(ITA_TOOLBOX_AUDIO_OBJECT(iStruct)); %#ok<AGROW>
        end
        resultStruct = reshape(resultStruct, size(ITA_TOOLBOX_AUDIO_OBJECT)); % retain dimensions of multi instance
        ITA_TOOLBOX_AUDIO_OBJECT = resultStruct; %#ok<NASGU>
        save(filename,'ITA_TOOLBOX_AUDIO_OBJECT');
        ita_verbose_info([thisFuncStr  'File written successfully.'],2)
    end
end

result = 1;
end
