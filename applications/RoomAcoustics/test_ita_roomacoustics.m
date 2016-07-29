function test_ita_roomacoustics()
% test_ita_roomacoustics() runs ita_roomacoustics() to find any error within it.
% The function is called automatically by test_ita_all()
% author: mgu

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


fftSize      = 17;
nChannels    = 15;
samplingRate = 44100;

revTime     = 2;    % in sec
SNR         = 50;   % signal(peak) to noise ratio
shiftTime   = 0.1;


sollWerte = struct('T20', revTime, 'T30', revTime,'T40', revTime, 'C80', 10*log10(10^(6*80e-3/revTime) - 1 ), 'C50', 10*log10(10^(6*50e-3/revTime) - 1 ) );
einheit = struct('T20', 's', 'T30', 's', 'T40', 's', 'C80', 'dB', 'C50', 'dB' );
parCell = {'T30', 'T20', 'T30', 'T40', 'C50', 'C80'};

%%
% create data
dataMat = randn(2^fftSize,nChannels) .* repmat(10.^((0:2^fftSize-1)'/samplingRate * ( -60/ revTime ) / 20),1,nChannels) +  10^ (-SNR / 20) * randn(2^fftSize,nChannels) ;

RIR = itaAudio(dataMat, samplingRate, 'time');
RIR = ita_time_shift(RIR, shiftTime);
RIR.channelNames = ita_sprintf('TestSig Channel %i ', 1:nChannels);

% calc ra par
res = ita_roomacoustics(RIR, 'freqRange', [100 4000], 'bandsPerOctave', 1, parCell{:} );

% display results
fprintf('\n\n')
for iPar = 1:numel(parCell)
    
    [~ , idxMax ] = max(abs(mean(res.(parCell{iPar}).freqData,2) - sollWerte.(parCell{iPar})));
    
    if strcmp(einheit.(parCell{iPar}), 'dB')
        fprintf('par: %s , maxabw: %2.2f  %s ( %2.2f %s) \n' , parCell{iPar}, mean(res.(parCell{iPar}).freqData(idxMax,:),2), einheit.(parCell{iPar}), mean(res.(parCell{iPar}).freqData(idxMax,:),2) - sollWerte.(parCell{iPar}),einheit.(parCell{iPar}) )
    else
        fprintf('par: %s , maxabw: %2.2f %s  ( %2.2f %%)\n' , parCell{iPar}, mean(res.(parCell{iPar}).freqData(idxMax,:),2),einheit.(parCell{iPar}) , 100*(mean(res.(parCell{iPar}).freqData(idxMax,:),2) - sollWerte.(parCell{iPar})) / sollWerte.(parCell{iPar}) )
    end
end

%% check different methods

edcMethods = { 'cutWithCorrection'  'justCut' 'noCut' 'subtractNoise' 'subtractNoiseAndCutWithCorrection' 'unknownNoise' };

wbh = itaWaitbar(numel(edcMethods), 'testing noise compenstion methods', {'Method'});
allRes = itaResult(numel(edcMethods, 1));
for iMethod = 1: numel(edcMethods)
    wbh.inc
    tmpRA = ita_roomacoustics(RIR.ch(1), 'freqRange', [100 4000], 'bandsPerOctave', 1, 'edcMethod', edcMethods{iMethod}, 'T20');
    allRes(iMethod) = mean(tmpRA.T20);
end
wbh.showTotalTime
% plot
% allRes = allRes.merge;
% allRes.channelNames = ita_sprintf('method: %s T20', edcMethods);
% allRes.pf
% ylim([0.9  1.1] * revTime)
wbh.close


%% check if Huszty option works
% (huszty algorithm is not available in BSD version)

ita_roomacoustics(RIR.ch(1), 'broadbandAnalysis', 'T_Huszty');

end