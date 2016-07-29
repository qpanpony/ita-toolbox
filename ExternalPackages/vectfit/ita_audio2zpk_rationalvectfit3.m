function varargout = ita_audio2zpk_rationalvectfit3(varargin)
%ita_audio2zpk_rationalvectfit3 - pole-zero-analysis
%  this function returns the poles and zeros of a transfer-function (TF) and if
%  a vector of TF's is given the fit will be done with the same poles for all
%  TF's.
%
%  syntax:
%   [fitted_curve                  vectfit] = ita_audio2zpk_rationalvectfit3(audioobjin, options)
%   [itaAudioAnalyticRational      itaPZ  ]
%
%   options (default):
%           'degree' (50)                                : number of resonance frequencies
% 
%           'starting_poles' ('Complex poles quadratic') : 'Complex poles quadratic',
%                                                          'Complex poles lin', 'Complex poles log',
%                                                          'Real poles lin' or 'Real poles log' distribution of the starting poles
%                                                          over frequency
% 
%           'freqrange' ([])                             : range used for analysis e.g. [500 10000] hz
% 
%           'weight_typ'('1')                            : '1' no weight,
%                                                          '2' give strong importance to low frequency
%                                                          '3' use with noise, more importance to low frequency
%                                                          '4' importance to higher frequency
% 
%           'iterations' (20)                            : number maximum of interactions.
% 
%           'plot' (false)                               : plot the original, the fitted IR and the difference in each iteration.
% 
%           'relax' (false)                              : relax == 1 --> Use relaxed nontriviality constraint
%                                                          relax == 0 --> Use nontriviality constraint of "standard" vector fitting.
% 
%           'tol'(30)                                    : accuracy of the result. The interation process stop when the energy from
%                                                          the original curve devided by the energy of the difference is higher then
%                                                          the value of tol.
%
% see also:
% ita_audio2zpk, ita_zpk2audio
%
% <ita-toolbox>
% this file is part of the application polezeroprony for the ita-toolbox. all rights reserved.
% you can find the license for this m-file in the application folder.
% </ita-toolbox>
% 
% TODO: Revise description of the function !!!
% 
% author: Andrey Hense -- email: andreyhense@gmail.com
% created:  14-jun-2012


sArgs        = struct('pos1_data','itaSuper','degree',50,'freqRange',[],'starting_poles','Complex poles quadratic',...
    'weight_typ', '1', 'tol', 30,'iterations',20,'plot',false,'relax',false);
[data,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Vector fitting
Nc = data.nChannels; % number of channels
if ~isempty(sArgs.freqRange)
    % get only some frequency data points
    fIdx1 = data(1).freq2index(sArgs.freqRange(1));
    fIdx2 = data(1).freq2index(sArgs.freqRange(2));
    freqVect = data(1).freqVector(fIdx1:fIdx2)';
    omegaVect = 2 * pi * freqVect';
    s = 1i * 2 * pi * freqVect';          % [rad/sec]
    f = data(1).freq(fIdx1:fIdx2,:).';    % get frequency data from itaAudio
else
    % get all frequency data points
    s  = 1i * 2 * pi * data(1).freqVector';   % [rad/sec]
    
    omegaVect = 2 * pi * data(1).freqVector'; % tinha esquecido de multiplicar por ****2pi****
    f = data(1).freq(:,:).';                  % get frequency data from itaAudio
end
% Weighting vector
Ns = length(omegaVect);   % number of bins

% Starting poles
switch sArgs.starting_poles
    case 'Complex poles cubic'
        % Complex poles quadratic spaced
        bet = linspace(omegaVect(1)^2, (omegaVect(Ns))^3, sArgs.degree/2).^(1/3);
        poles = reshape(([bet; bet] / -100 + 1i* [-bet; bet]), 1, sArgs.degree);
    
    case 'Complex poles quadratic'
        % Complex poles quadratic spaced
        bet = linspace(omegaVect(1)^2, (omegaVect(Ns))^2, sArgs.degree/2).^(1/2);
        poles = [];
        for n = 1:length(bet)
            alf = -bet(n) * 1e-2;
            poles = [poles (alf - 1i * bet(n)) (alf + 1i * bet(n)) ]; %#ok<AGROW>
        end
    case 'Complex poles lin'
        % Complex starting poles, complex conjugate pairs, linearly spaced:
        bet   = linspace(omegaVect(1),omegaVect(Ns),sArgs.degree/2);
        poles = [];
        for n = 1:length(bet)
            alf = -bet(n) * 1e-2;
            poles = [poles (alf - 1i * bet(n)) (alf + 1i * bet(n)) ]; %#ok<AGROW>
        end
    case 'Complex poles log'
        % Complex conjugate pairs, logarithmically spaced :
        if omegaVect(1) == 0
            bet   = logspace(       0         , log10(omegaVect(end)),sArgs.degree/2);
        else
            bet   = logspace(log10(omegaVect(1)), log10(omegaVect(end)),sArgs.degree/2);
        end
        poles = [];
        for n = 1:length(bet)
            alf   = -bet(n) * 1e-2;
            poles = [poles (alf - 1i*bet(n)) (alf + 1i*bet(n)) ]; %#ok<AGROW>
        end
    case 'Real poles lin'
        % Real starting poles (when fitting very smooth functions):
        poles = -2 * pi * linspace(omegaVect(1),omegaVect(Ns),sArgs.degree);
    case 'Real poles log'
        % Real starting poles, logarithmically spaced :
        if omegaVect(1) == 0
            poles = -2 * pi * logspace( 0, log10(omegaVect(Ns)),sArgs.degree);
        else
            poles = -2 * pi * logspace(log10(omegaVect(1)), log10(omegaVect(Ns)),sArgs.degree);
        end
end
% Weight types
switch sArgs.weight_typ
    case '1'
        weight = ones(Nc,Ns);   % no weight
    case '2'
        wt  = 1 ./ abs(s);      % give strong importance to low frequency
        wt(wt == inf) = 0;
        weight = repmat(wt,Nc,1);
    case '3'
        wt = 1 ./ sqrt(abs(s)); % use with noise, importance to low frequency
        wt(wt == inf) = 0;
        weight = repmat(wt,Nc,1);
    case '4'
        wt = sqrt(abs(s));      % importance to higher frequency
        weight = repmat(wt,Nc,1);
        
end

% Fitting options
opts.relax     = sArgs.relax;  % Use vector fitting with relaxed non-triviality constraint
opts.stable    = 1;            % Enforce stable poles
opts.asymp     = 1;            % Include no D in fitting ( and no E) (1-->d,e = 0; 2-->d~=0 and e=0; 3 --> d~=0 and e~=0)
opts.spy1      = 0;            % No plotting for first stage of vector fitting
opts.spy2      = sArgs.plot;   % Create magnitude plot for fitting of f(s)
opts.logx      = 0;            % Use logarithmic abscissa axis
opts.logy      = 1;            % Use logarithmic ordinate axis
opts.errplot   = 1;            % Include deviation in magnitude plot
opts.phaseplot = 1;            % exclude plot of phase angle (in addition to magnitiude)

opts.skip_pole = 0;      % Do NOT skip pole identification
opts.skip_res  = 0;      % Do NOT skip identification of residues (C,D,E)
opts.cmplx_ss  = 1;% = 1 % Create complex state space model, LET IT COMPLEX TO HAVE COMPLEX RESIDUES
opts.legend    = 0;      % Do include legends in plots

% Forming (weighted) column sum:
g = 0;
for n = 1:Nc
    g = g + f(n,:); % unweighted sum; or % g = g + f(n,:) / norm(f(n,:)); or % g = g + f(n,:) / sqrt(norm(f(n,:)));
end
weight_g =  1 ./ abs(g);

% Fitting of the sum of the IR's, to difine better the initial poles
disp('****Calculating improved initial poles by fitting column sum ...')
conv = 0;
for iter = 1:sArgs.iterations
    disp(['   Iter ' num2str(iter)])
    
    [SER,poles,signalerrorratio,fit] = vectfit3(g,s,poles,weight_g,opts); %#ok<NASGU>
        signalerrorratio1(iter) = signalerrorratio; %#ok<AGROW>
    
    if signalerrorratio > sArgs.tol %|| iter == sArgs.iterations
        break
    end
    % Test convergence
    if iter > 1
        error = signalerrorratio - signalerrorratio1(iter-1);
        if error < 0.3
            conv = conv + 1;
            if conv == 5
                break
            end
        else
            conv = 0;
        end
    end
    
end

% Fitting separately each IR
disp('*****Fitting column...')
conv = 0;
for iter = 1:sArgs.iterations
    disp(['   Iter ' num2str(iter)])
    [SER,poles,signalerrorratio,fit] = vectfit3(f,s,poles,weight,opts); %#ok<NASGU>
    signalerrorratio2(iter) = signalerrorratio; %#ok<AGROW>
    
    if signalerrorratio > sArgs.tol %|| iter == sArgs.iterations
        break
    end    
    % Test convergence
    if iter > 1
        error = signalerrorratio - signalerrorratio2(iter-1);
        if error < 0.3
            conv = conv + 1;
            if conv == 5
                ita_disp('Converged')
                break
            end
        else
            conv = 0;
        end
    end
end

% OBS. residues are not needed in the interaction, can be calculated just  in
% the end.

%% Extracts the parameters of the results. Convert SER.C to good coefficient vector!
po = full(diag(SER.A));

% % Take all poles
p     = imag(po)/2/pi; % resonances
sigma = real(po);      % damping
c     = SER.C;         % residue

%% Generate multichannel itaAudioRAtionalAnalytic
vectfit = itaPZ;

for idx = 1:Nc
    vectfit(idx).f      = p;
    vectfit(idx).sigma  = sigma;
    vectfit(idx).C      = c(idx,:).';
end
% Result
vectfit1                    = itaAudioAnalyticRational(vectfit); % Have problem to do when taking just positive poles.
if isa(data,'itaAudio')
    vectfit1.samplingRate       = data.samplingRate;
    vectfit1.fftDegree          = data.fftDegree;
end
vectfit1.channelCoordinates = data.channelCoordinates;
vectfit1.channelNames       = data.channelNames;
vectfit1.channelUnits       = data.channelUnits;
% fitted_curve                = vectfit1.';

% if ~isa(data,'itaResult')
%     res.samplingRate = data.samplingRate;
%     res.fftDegree = data.fftDegree;
% end
ita_disp('Finished')

%% Set Output
varargout{1} = vectfit1;
% if nargout == 2
varargout{2} = vectfit;
% end
if nargout == 3
    varargout{3} =  signalerrorratio2;
end


end

