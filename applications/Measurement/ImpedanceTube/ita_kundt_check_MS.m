% ITA_KUNDT_CHECK_MS - script

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

if false %exist('Kundt_Measurement_Setup','var')
    disp('Teste aktuelle Kundt MS')
    MS = itaMeasurementSetupTransferFunction(Kundt_Measurement_Setup);
    MS.saveRAW = 1;
else
    outAmp = -55;
    fftDegree = 18;
    freqRange = [100 10000];
    fprintf('Teste %ier Sweep mit outputamplification %i dB\n', fftDegree, outAmp);
    MS = itaMSTF('inputChannels',1,'outputChannels',4,...
                'samplingRate',ita_preferences('samplingRate'),...
                'fftDegree',fftDegree,'freqRange',freqRange,...
                'excitation','exp','stopmargin',0.1,...
                'outputamplification',outAmp,'comment','Test','pause',0.1,...
                'averages',1,'lineardeconvolution',false,...
                'exportvariable','ans','saveRAW',true,'useMeasurementChain',false);
end        
      
MS.excitation = ita_filter(MS.excitation, 'shelf',   'high',[10 1000],'order', 6);
MS.compensation = ita_invert_spk_regularization(MS.excitation , freqRange);
% ita_plot_freq(merge(MS.excitation, shelf1))

sweep = MS.run;

background = MS.run_backgroundNoise;

sweep(2).channelNames = {'Sweep Rec Raw'};
background(2).channelNames = {'Backgroundnoise Rec Raw'};
snrCheck = merge(background(2), sweep(2));
snrCheck.comment = 'SNR Check';
ita_plot_freq(snrCheck)

ita_spectrogram_mgu(sweep(2),  'blockSize', 14, 'overlap', 0.75 )