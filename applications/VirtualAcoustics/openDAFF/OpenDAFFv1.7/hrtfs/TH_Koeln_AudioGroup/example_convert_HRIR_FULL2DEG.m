%
% OpenDAFF
%
% Example how to convert the Neumann KU100 HRIR dataset from TH Köln
% AudioGroup into DAFF.
%

%% Obtain from web resource

% miro class
miro_url = 'http://audiogroup.web.th-koeln.de/FILES/miro.m';
if exist( 'miro', 'class' ) == 0
    websave( 'miro.m', miro_url );
end

% Content
file_name = 'HRIR_FULL2DEG.mat';
web_resource_url = [ 'http://audiogroup.web.th-koeln.de/FILES/' file_name ];
if exist( file_name, 'file' ) == 0
    disp( [ 'Starting download from ' web_resource_url ] )
    file_path = websave( file_name, web_resource_url ); % Sometimes failing, better download manually
else
    file_path = file_name;
end
load( file_path ) % makes HRIR_FULL2DEG available in workspace


%% Convert

% ... very simple
daffv17_convert_from_miro( HRIR_FULL2DEG );

% ... with file name
daffv17_convert_from_miro( HRIR_FULL2DEG, 'HRIR_FULL2DEG.v17.ir.daff' );

% ... with extra metadata
additional_metadata = daffv17_add_metadata( [], 'Conversion date', 'String', date );
additional_metadata = daffv17_add_metadata( additional_metadata, 'Web resource', 'String', web_resource_url );
additional_metadata = daffv17_add_metadata( additional_metadata, 'License', 'String', 'CC BY-SA 3.0' );
additional_metadata = daffv17_add_metadata( additional_metadata, 'License URL', 'String', 'http://creativecommons.org/licenses/by-sa/3.0/legalcode' );
additional_metadata = daffv17_add_metadata( additional_metadata, 'CC license deed', 'String', 'https://creativecommons.org/licenses/by-sa/3.0/' );
daffv17_convert_from_miro( HRIR_FULL2DEG, 'HRIR_FULL2DEG_48kHz_web.v17.ir.daff', additional_metadata );

% ... with resampling to common 44.1 kHz
HRIR_FULL2DEG.resampleToFS = 44.1e3;
daffv17_convert_from_miro( HRIR_FULL2DEG, 'HRIR_FULL2DEG_44kHz_web.v17.ir.daff', additional_metadata );

% ... in complex frequency domain.
HRIR_FULL2DEG.resampleToFS = HRIR_FULL2DEG.fs; % reset fs
daffv17_convert_from_miro( HRIR_FULL2DEG, 'HRTF_FULL2DEG_48kHz_128taps_web.v17.dft.daff', additional_metadata, 'dft' );

% ... energetic.
daffv17_convert_from_miro( HRIR_FULL2DEG, 'HRTF_FULL2DEG_energetic_web.v17.ms.daff', additional_metadata, 'ms' );

