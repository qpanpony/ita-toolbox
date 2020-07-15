%% General

% initialize GeoPropSim
geoPropSim = itaGeoPropagation();

% load directivity
% directivity_id = geoPropSim.load_directivity( 'Genelec8020_2016_1x1.v17.ir.daff', 'Genelec8020' );

%% run simulation

geoPropSim.load_paths('ppa_example_paths.json');

% extract paths that lead to error
%geoPropSim.pps = geoPropSim.pps(84);
testPath1 = geoPropSim.pps;

geoPropSim.pps = geoPropSim.pps( 12 );

pps1TF = itaAudio();
pps1TF.freqData = geoPropSim.run;


geoPropSim.load_paths('ppa_example_paths_2.json');

% extract paths that lead to error
%geoPropSim.pps = geoPropSim.pps(184);
testPath2 = geoPropSim.pps;

pps2TF = itaAudio();
pps2TF.freqData = geoPropSim.run;

