function [ output_args ] = jri_testNLMS( input_args )
%JRI_TESTNLMS Summary of this function goes here
%   Detailed explanation goes here

ms = itaMSTFinterleaved;
ms.inputChannels = 1:2;
ms.outputChannels = 1:2;
ms.twait = 0.04;
ms.run_latency


MS=itaMSTF_NLMS;
% ------------------ measurement Parameter --------------------------------
MS.fftDegree            = 16;          % Length of IRs in samples. Sweep length will be fftDegree * num. of channels (According to NLMS algorithm)
MS.stopMargin           = 0.2;          % Time in sec to wait until the system decays (will be added to the overall measurment time)
MS.freqRange            = [0 22050];    % Frequency range for the measurement
MS.outputamplification  = -40;          % level below maximum amplitude in dBFS (full scale)
MS.samplingRate         = 44100; 
MS.outputChannels       = [1:2];  %[[1:32] [37:41]]-> use all 37 channels
MS.inputRef             = 1;           % inputchannel for the reference measurement (only one channel)
MS.inputMeasure         = 1:2;        % inputchannels for the measurment (should be 2 channels for HRTF measurement)
MS.mType                = 'perfect';    % must be a 'perfect' sweep in NLMS
MS.averages             = 1;            % No averages in NLMS

% ----------------------NLMS parameter ------------------------------------
MS.Tadapt               = 45*44100;       % Preset time in samples for the filter to adapt (will be added to the overall measurment time)
MS.T360                 = 5;%60;            % Revolution time in sec
MS.mu                   = 0.5;           % Stepsize Mu
% --------------------postprocessing parameter ------------------------------------
MS.el                   = 0:5:5;      % vector containing all elevations in degree (row- or column-vector) for the grid
MS.max_ang              = 2;             % maximum great circle distance between to neighboring points of the same elevation in the grid
MS.fit                  = 90;           % great circle distance is choosen to include a point each 'fit' degrees. If fit = 90, median and frontal plane are included in the grid (default = 90)
MS.ch2elMap             = [0:5:5]'; % a vector with elevations corresponding to the channelnumber


coords = ita_generateSampling_equiangular(5,5)
coords_cut = coords.n(coords.theta_deg == 90);


res = MS.runNLMS_measurment2

MS.doNLMS('measurementResult',res,'hrtf_grid',coords_cut,'ch2elMap', MS.ch2elMap,'HT_Data',1)
[NLMSresult_1 NLMSresult_2]= doNLMS_fast(MS,'measurementResult', resultMeasure,'hrtf_grid',greatcircleGrid,'HT_Data',HTData_azimuth,'shiftValue',-770,'mu',MS.mu,'usedExcitation',NLMSexcitation);



end

