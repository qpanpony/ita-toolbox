function result = ita_read_daff( filename, varargin )
%ITA_READ_DAFF - Read Open Directional Audio File Format
%   This function is based on the OpenDAFF DAFFv17 executable.
%
%   It returns an itaHRTF object containing the data from a *.daff impulse response file.
%
%   See also ita_read, ita_write, ita_write_daff.

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


%% Return type of data this function can read
if nargin == 0
    result{1}.extension = '.daff';
    result{1}.comment = 'Open Directional Audio File Format (*.daff)';
    return
end
    
if ~exist( filename, 'file' )
    error( 'ITA_READ_DAFF: File does not exist' )
end

try
    result = itaHRTF( 'daff', filename );
catch
    error( 'ITA_READ_DAFF: Something went wrong' )
end
    
end
