%% Pull in FABIAN database from AKtools
% Resources
% http://dx.doi.org/10.14279/depositonce-5718.2
% http://www.ak.tu-berlin.de/menue/digitale_ressourcen/research_tools/aktools/
AKdependencies('FABIAN')

%% Configure
export_properties = struct();
export_properties.alphares = 5;
export_properties.alpharange = [0 360];
export_properties.betares = 5;
export_properties.betarange = [0 180];
export_properties.hatores = 5;
export_properties.hatorange = [-50 50];

%% Set up metadata
additional_metadata = daffv17_add_metadata( [], 'hato', 'BOOL', true );
additional_metadata = daffv17_add_metadata( additional_metadata, 'hato_res_deg', 'FLOAT', export_properties.hatores );
additional_metadata = daffv17_add_metadata( additional_metadata, 'hato_start_deg', 'FLOAT', export_properties.hatorange( 1 ) );
additional_metadata = daffv17_add_metadata( additional_metadata, 'hato_end_deg', 'FLOAT', export_properties.hatorange( 2 ) );
additional_metadata = daffv17_add_metadata( additional_metadata, 'AKtools_resource', 'STRING', 'http://www.ak.tu-berlin.de/menue/digitale_ressourcen/research_tools/aktools/' );
additional_metadata = daffv17_add_metadata( additional_metadata, 'FABIAN_resource', 'STRING', 'http://dx.doi.org/10.14279/depositonce-5718.2' );
additional_metadata = daffv17_add_metadata( additional_metadata, 'FABIAN_license', 'STRING', 'Creative Commons BY-NC-SA 4.0' );

%% Export
daffv17_convert_from_aktools( 'FABIAN_HATO_5x5x5_256_44100Hz.v17.ir.daff', export_properties, additional_metadata )
