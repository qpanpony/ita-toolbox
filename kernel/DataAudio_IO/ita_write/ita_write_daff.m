function result = ita_write_daff( varargin )
%ITA_WRITE_DAFF - Write Open Direction Audio File Format to disk
%   This functions writes itaHRTF data to daff files
%
%   Call: ita_write_daff ( itaHRTF, filename, options )
%
%   Options: see write_daffv17 and @itaHRTF.writeDAFFFile for more details as arguments are passed on
%
%
%   See also ita_read, ita_read_daff, ita_write, itaHRTF.
%
%   Reference page in Help browser
%       <a href="matlab:doc ita_write">doc ita_write</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


if nargin == 0 % Return possible argument layout
    result{ 1 }.extension = '*.daff';
    result{ 1 }.comment = 'OpenDAFF Files (*.daff)';
    return
end

sArgs = struct( 'pos1_data', 'itaHRTF', 'pos2_filename', 'char', 'overwrite', false );
[ data, filename, sArgs, sOtherArgs ] = ita_parse_arguments( sArgs, varargin ); 

if exist( filename, 'file' ) && ~sArgs.overwrite % Error because file exists
    error( 'ITA_WRITE_DAFF:FILE_EXISTS', [ mfilename ': Careful, file already exists, use overwrite option to disable error' ] )
else % Everything ok, save

    ita_verbose_info( [ mfilename ': Careful, overwriting file if existing' ] );
    
    if ~isempty( sOtherArgs )
        data.writeDAFFFile( filename, sOtherArgs );
    else
        data.writeDAFFFile( filename );
    end
    
end

result = 1;
end

