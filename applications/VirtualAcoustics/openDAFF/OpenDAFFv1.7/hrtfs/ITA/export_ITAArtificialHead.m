%
% OpenDAFF
%

% The ITA Artificial Head HRIR data set can be obtained from:
% http://www.akustik.rwth-aachen.de/cms/Technische-Akustik/Studium/~edgv/Lehrmaterialien/
%
% Requires the ITA Toolbox: http://git.rwth-aachen.de/ita/toolbox
%

addpath( '../..' ) % Find daffv17_write and daffv17_add_metadata function

metadata = [];
metadata = daffv17_add_metadata( metadata, 'Description', 'String', 'ITA Artificial Head' );
metadata = daffv17_add_metadata( metadata, 'Creation date', 'String', date );
metadata = daffv17_add_metadata( metadata, 'License', 'String', 'CC BY-NC 4.0' );
metadata = daffv17_add_metadata( metadata, 'CC License Deed', 'String', 'https://creativecommons.org/licenses/by-nc/4.0/' );
metadata = daffv17_add_metadata( metadata, 'Generation script', 'String', 'Opendaff-v1.7/matlab/hrtfs/ITAKunstkopfAcademic/export_ITAKunstkopfAcademic.m' );
metadata = daffv17_add_metadata( metadata, 'Web Resource (2016)', 'String', 'http://www.akustik.rwth-aachen.de/cms/Technische-Akustik/Studium/~edgv/Lehrmaterialien/' );

hrir_1x1 = ita_read( 'finishedHRTF_1deg.ita' );
hrir_1x1.writeDAFFFile( 'ITA_Artificial_Head_5x5_44kHz_532.v17.ir.daff', { 'metadata', metadata } );

hrir_5x5 = ita_read( 'finishedHRTF_5deg.ita' );
hrir_5x5.writeDAFFFile( 'ITA_Artificial_Head_5x5_44kHz_532.v17.ir.daff', { 'metadata', metadata } );

d = floor( mean( ita_start_IR( hrir_5x5 ) ) );
hrir_5x5_128 = ita_time_crop( hrir_5x5, [ 1 127 ] + d - 20, 'samples' );
hrir_5x5_128.writeDAFFFile( 'ITA_Artificial_Head_5x5_44kHz_128.v17.ir.daff', { 'metadata', metadata } );

hrir_5x5_256 = ita_time_crop( hrir_5x5, [ 1 256 ] + d - 40, 'samples' );
hrir_5x5_256.writeDAFFFile( 'ITA_Artificial_Head_5x5_44kHz_256.v17.ir.daff', { 'metadata', metadata } );
