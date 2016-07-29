function result = ita_read_ita(filename,varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


if nargin == 0
    result{1}.extension = '.ita';
    result{1}.comment = 'ITA audioObject (*.ita)';
    return
end

%% Read ITA file
input = load(filename,'-mat');

if isstruct(input)
    if isfield(input,'ITA_TOOLBOX_AUDIO_OBJECT')
        % actual version of a .ita file
        result = input.ITA_TOOLBOX_AUDIO_OBJECT;
    else
        % it must be some old version
        if isfield(input,'header')
            result = ita_import_old(input);
        elseif isfield(input,'ITA_TOOLBOX_AUDIO_STRUCT')
            result = ita_import_old(input.ITA_TOOLBOX_AUDIO_STRUCT);
        else
            error('ITA_READ:ReadItaFile','Oh Lord! I can not read this type of file. Are you sure this is a .ITA file?' );
        end
    end
elseif isa(input,'itaSuper')
    result = input;
else
    error('ITA_READ:ReadItaFile','Oh Lord! I can not read this type of file. Are you sure this is a .ITA file?' );
end

if isstruct(result)
    resultStruct = result;
    clear result;
    for iStruct = 1:numel(resultStruct)
        if isfield(resultStruct(iStruct),'classname')
            classname = resultStruct(iStruct).classname;
            if exist([classname '.m'],'file')
                tmpStruct = rmfield(resultStruct(iStruct),{'classname','classrevision'}); %#ok<NASGU>
                eval(['result(iStruct) = ' classname '(tmpStruct);']);
            else
                ita_verbose_info('I don''t know this class, returning the pure struct only',0);
            end
        else
            result(iStruct) = itaAudio(resultStruct(iStruct));
        end
    end
    
    result = reshape(result, size(resultStruct)); % retain dimensions of multi instance
end

for idx = 1:numel(result)
    if ~strcmpi(result(idx).fileName,filename)
        result(idx).fileName = filename;
    end
end
