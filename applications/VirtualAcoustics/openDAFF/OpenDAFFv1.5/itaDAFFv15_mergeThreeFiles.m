%
%  File:    mergeThreeDaffFiels.m
%  Purpose: merge three daff files
%  Author:  Lukas Aspöck, las@akustik.rwth-aachen.de

targetFolder = 'TestFolder/';
OutputFolder = 'Output/'

if ~exist(OutputFolder) 
    mkdir(OutputFolder);
end

allFiles = dir([targetFolder '*.daff']);


filePath1 = [ targetFolder allFiles(3).name ];
filePath2 =  [ targetFolder allFiles(1).name ];
filePath3 = [ targetFolder allFiles(2).name  ];
newFileName = [ OutputFolder allFiles(3).name(1:24) '6ch_256.daff'; ]

aHRTF = DAFFv15('open',filePath1);
bHRTF = DAFFv15('open',filePath2);
cHRTF = DAFFv15('open',filePath3);

aProperties = DAFFv15('getProperties',aHRTF);
bProperties = DAFFv15('getProperties',bHRTF);
cProperties = DAFFv15('getProperties',cHRTF);

aMetadata = DAFFv15('getMetadata',aHRTF);

if (aProperties.numRecords ~= bProperties.numRecords || ...
    aProperties.filterLength ~= bProperties.filterLength   || ... 
    aProperties.samplerate ~= bProperties.samplerate || ...
    aProperties.numRecords ~= cProperties.numRecords || ...
    aProperties.filterLength ~= cProperties.filterLength   || ... 
    aProperties.samplerate ~= cProperties.samplerate)
        error('DAFF files do not have the same properties (number of records/filterlength/samplingrate) ');
end


numChannels = aProperties.numChannels + bProperties.numChannels + cProperties.numChannels;

% create new daff dataset
dataset = daff_create_dataset('alphares', aProperties.alphaResolution, ...
                              'betares', aProperties.betaResolution, ...
                              'alpharange', aProperties.alphaRange, ...
                              'betarange', aProperties.betaRange, ...
                              'channels', numChannels);

dataset.channelLabels = {'HRTF KK left' 'HRTF KK right', 'HA Front left' 'HA Front right' 'HA rear left' 'HA rear right'};                          
dataset.samplerate = 44100;
dataset.metadata = aMetadata;
dataset.metadata.desc = 'HRTF + HARTF IR DB (GN Resound HA) // arm-measurement 2015 FPA';
 

for i=1:dataset.numrecords
   alpha = dataset.records{i}.alpha; 
   beta = dataset.records{i}.beta;   
                
   aData = DAFFv15('getNearestNeighbourRecord',aHRTF,'data',alpha,beta);
   bData = DAFFv15('getNearestNeighbourRecord',bHRTF,'data',alpha,beta);
   cData = DAFFv15('getNearestNeighbourRecord',cHRTF,'data',alpha,beta);
   
   data = [ aData; bData; cData ];

   dataset.records{i}.data = data;
   
end 

%
%  Write the DAFF file
daffv15_write('filename', newFileName, ...
           'content', 'IR', ...
           'dataset', dataset, 'verbose');
