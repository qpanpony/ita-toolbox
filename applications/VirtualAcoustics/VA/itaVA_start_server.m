if ~exist( 'VAServer.exe', 'file' )
    itaVA_setup
end

[ basepath, basename, ext ]= fileparts( which( 'VAServer.exe') );
[ va_basepath, ~, ~ ]= fileparts( basepath );

conf_path1 = fullfile( 'conf', 'VACore.ini' );
conf_path2 = fullfile( pwd, 'MyVACore.ini' ); % also absolute path possible
va_args = [ 'localhost:12340 ' conf_path1 ]; 

os_call = [ which( 'VAServer.exe') ' ' va_args ' &' ];

return_to_dir = pwd;
cd( va_basepath );
[ status, cmdout ] = system( os_call );
cd( return_to_dir );

% After connect, also add the folder with your data like this
% va.add