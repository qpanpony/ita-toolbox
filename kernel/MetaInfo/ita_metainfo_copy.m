function varargout = ita_metainfo_copy(varargin)
%ITA_METAINFO_COPY - Copy meta info to a new itaSuper
%  This function copies meta info from one itaSuper to another
%
%  Syntax:
%   audioObjOut = ita_metainfo_copy(itaSuperWithoutMetaDATA, itaSuperWithMetaDATA)
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_metainfo_copy">doc ita_metainfo_copy</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  27-Jul-2011 

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaSuper', 'pos2_data', 'itaSuper', 'excludeMetaInfos', '');
[input,metaData, sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Copy all meta data
metaFields = itaSuper.metaDataFields;
for idx = 1:numel(metaFields)
    if ~strcmpi(sArgs.excludeMetaInfos, metaFields{idx})
        input.(metaFields{idx}) = metaData.(metaFields{idx});
    end
end

%% Set Output
varargout(1) = {input}; 

%end function
end