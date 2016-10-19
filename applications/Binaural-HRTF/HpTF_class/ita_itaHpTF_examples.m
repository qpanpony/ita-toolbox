%% measure HpTF with GUI
HpTF_ms             = itaHpTF_MS;   % uses output and input channels 1,2 
HpTF_subj           = HpTF_ms.run   %#ok<NOPTS> run measurement
HpTF_subj.TF.pf                     % show measured transfer functions

%% measure HpTF with a measurement setup
in          = 1:2;                  % input channels
out         = 1:2;                  % output channels
amp         = -40;                  % output amplification
fftDeg      = 16;                   % define fftDegree

MSTF                = itaMSTF;      % create measurement setup
MSTF.fftDegree      = fftDeg;       
MSTF.inputChannels  = in;
MSTF.outputChannels = out;
MSTF.outputamplification = amp;

HpTF_ms             = itaHpTF_MS(MSTF); % init HpTF measurement object
HpTF_ms.nameHP      = 'HD 650';         % name of the headphones
HpTF_ms.nameMic     = 'KE 3';           % name of the headphones
%HpTF_ms.mic                            % [transfer functions of the microphones] 
HpTF_ms.nameSubj    = name;             % name of the subject
HpTF_ms.repeat      = 4;                % repeatitions [8]

HpTF_subj           = HpTF_ms.run;      % run measurement (press any button to continue
HpTF_subj.TF.pf                         % show measured transfer functions

%% calculate equalization curve (prepare HpTF)
HpTF_subj.method    = 'mSTD';           % choose method [mSTD, mean, max]
HpTF_subj.smoothing = 1/6;              % smoothing [1/6 octave bands]

HpTF_subj.fLower    = 200;              % [100 Hz] lowest frequency for the headphones (smooth spectrum below)
HpTF_subj.fUpper    = 18000;            % [18 kHz] highest freq for the headphones (regularization)

HpTF_eq = HpTF_subj.HP_equalization;    % calculate equalization curve
HpTF_eq.pf
