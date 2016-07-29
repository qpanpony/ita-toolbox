%
%  File:    itaDAFF_mergeTwoFiles.m
%  Purpose: merge two daff files
%  Author:  Lukas Aspöck, las@akustik.rwth-aachen.de


filePath1 = 'FinalHRTFs/2015_ITA-KK_GnResound_Front_HARIR_2ch_1x5_256.daff';
filePath2 = 'FinalHRTFs/2015_ITA-KK_GnResound_Rear_HARIR_2ch_1x5_256.daff';
newFileName = 'FinalHRTFs/2015_ITA-KK_GnResound_HARIR_4ch_1x5_256.daff';

aHRTF = DAFFv15('open',filePath1);
bHRTF = DAFFv15('open',filePath2);

aProperties = DAFFv15('getProperties',aHRTF);
bProperties = DAFFv15('getProperties',bHRTF);

aMetadata = DAFFv15('getMetadata',aHRTF);

if (aProperties.numRecords ~= bProperties.numRecords || ...
    aProperties.filterLength ~= bProperties.filterLength   || ... 
    aProperties.samplerate ~= bProperties.samplerate )
        error('DAFF files do not have the same properties (number of records/filterlength/samplingrate) ');
end


numChannels = aProperties.numChannels + bProperties.numChannels;

% create new daff dataset
dataset = daffv15_create_dataset('alphares', aProperties.alphaResolution, ...
                              'betares', aProperties.betaResolution, ...
                              'alpharange', aProperties.alphaRange, ...
                              'betarange', aProperties.betaRange, ...
                              'channels', numChannels);

dataset.channelLabels = {'HA Front left' 'HA Front right' 'HA rear left' 'HA rear right'};                          
dataset.samplerate = 44100;
dataset.metadata = aMetadata;
dataset.metadata.desc = 'Hearing Aid related IR Database (GN Resound HA), Ch1: FrontLeft, Ch2: FrontRight; Ch3: RearLeft; Ch4: RearRight // arm-measurement 2015 FPA';
        

for i=1:dataset.numrecords
   alpha = dataset.records{i}.alpha; 
   beta = dataset.records{i}.beta;   
                
   aData = DAFFv15('getNearestNeighbourRecord',aHRTF,'data',alpha,beta);
   bData = DAFFv15('getNearestNeighbourRecord',bHRTF,'data',alpha,beta);
   
   data = [ aData; bData ];

   dataset.records{i}.data = data;
   
   % Optionally you can supply individual metadata for the records
%    dataset.records{i}.metadata.= filename;
end 

%
%  Write the DAFF file
daffv15_write('filename', newFileName, ...
           'content', 'IR', ...
           'dataset', dataset, 'verbose');
