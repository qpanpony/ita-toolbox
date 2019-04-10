if ~exist( 'VAServer.exe', 'file' )
    VA_setup
end

[ basepath, basename, ext ]= fileparts( which( 'VAServer.exe') );
[ va_basepath, ~, ~ ]= fileparts( basepath );

conf_path = fullfile( va_basepath, 'conf', 'VACore.experimental.ini' );
va_args = [ 'localhost:12340 ' conf_path ]; 

os_call = [ which( 'VAServer.exe') ' ' va_args ' &' ];

return_to_dir = pwd;
cd( va_basepath );
[ status, cmdout ] = system( os_call );
cd( return_to_dir );
