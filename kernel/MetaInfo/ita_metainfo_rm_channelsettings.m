function varargout = ita_metainfo_rm_channelsettings(varargin)
%ITA_HEADER_RM_CHANNELSETTINGS - Delete all channel settings
%  This function is used to delete all channels settings. Useful for
%  filter files, since the units and channel names are not wanted in the
%  result after multiplication sometimes.
%
%  Syntax:
%   header = ita_header_rm_channelsettings(audioObj)
%   header = ita_header_rm_channelsettings(header)
%
%  Options: 
%       (...,'units') - delete unit information only
%       (...,'names') - delete name information only
%
%   See also ita_fft, ita_ifft, ita_ita_read, ita_ita_write.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_header_rm_channelsettings">doc ita_header_rm_channelsettings</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  26-Sep-2008 


%% Initialization
% Number of Input Arguments
narginchk(1,2);
% Find Audio Data
if isa(varargin{1},'itaSuper')
    as = varargin{1};
else
    error('ita_header_rm_channelsettings:Oh Lord. Not a itaAudio object.')
end

delete_names = 1; %delete both in standard case
delete_units = 1;
if nargin == 2 && ischar(varargin{2})
    deleteStr = lower(varargin{2});
    switch deleteStr
        case {'names'}
            delete_units = 0;
        case {'units'}
            delete_names = 0;
        case {'all'}
        otherwise
            error('Oh Lord. I do not know what to do!')
    end
end

%% delete the info
for idx = 1:as.nChannels
    if delete_names, as.channelNames{idx} = ''; end
    if delete_units, as.channelUnits{idx} = ''; end
end

%% Find output parameters
if nargout
    % Write Data
    varargout(1) = {as}; 
end

%end function
end