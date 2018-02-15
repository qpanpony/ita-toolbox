% THIS FILE WILL BE OVERWRITTEN BY CMAKE WITHOUT WARNING
%
% Code generator for the VA Matlab interface facade class
%
% Desc:     This script generates the code for the Matlab
%           facade class to the VAInterface MEXExtension.
%           It takes the class template code and inserts
%           all stubs for the functions in the VAConnector
%           interface. These are derived using the reflexion
%           mechanism ('enumerateFunctions')
%

va_base_dir = '..'; % VA folder with bin, lib, matlab, data etc.
va_script_dir = fullfile( va_base_dir, 'matlab' ); % Matlab scripts target directory
va_bin_dir = fullfile( va_base_dir, 'bin' );
va_lib_dir = fullfile( va_base_dir, 'lib' );

if exist( va_bin_dir, 'dir' ) ~= 7
    error( 'Deploy dir ''%s'' does not exist. Please build and install VAMatlab first.', va_bin_dir )
end

if exist( va_script_dir, 'dir' ) ~= 7
   mkdir( va_script_dir );
end

if exist( [ 'VAMatlab' '.' mexext ], 'file' )
    warning( 'VAMatlab already found at location "%s", are you sure to build itaVA against this executable? Will proceed now.', which( 'VAMatlab' ) )
else
    % Add to PATH temporarily and attempt to move lib to bin dir
    addpath( va_script_dir, va_bin_dir )

    [ s ] = movefile( fullfile( va_lib_dir, 'VAMatlab*' ), va_bin_dir );
    if ~s && ~exist( [ 'VAMatlab' '.' mexext ], 'file' )
        error( 'Could not locate VAMatlab executable. Please make sure that it can be found.' )
    end
end

% Parameters
templateFile = 'itaVA.m.proto';
outputFile = fullfile( va_script_dir, 'itaVA.m' );

fprintf( 'Generating code for itaVA Matlab class ''%s'' ...\n', outputFile );
code = fileread( templateFile );
stubCode = itaVA_generateStubs();

code = strrep( code, '###STUBCODE###', stubCode );

% Write the results
fid = fopen( outputFile, 'w' );
fprintf( fid, '%s', code );
fclose( fid );

fprintf( 'Matlab class ''%s'' successfully built\n', outputFile );


% Remove from MATLABPATH (otherwise naming conflicts may occur with
% ITA-Toolbox/applications/VirtualAcoustics/VA/* scripts)
rmpath( va_script_dir, va_bin_dir )
