function varargout = ita_speech_transmission_index(varargin)
%ITA_SPEECH_TRANSMISSION_INDEX - calculate STI (indirect method with IRs)
%  This function calculates the STI according to ISO 60268-16.
%
%  Syntax:
%   double = ita_speech_transmission_index(audioObjIn, options)
%
%   Options (default):
%           'levels' ([])       : signal levels
%           'SNR' ([])          : signal to noise ration
%           'plot' (false)      : plot the MTI over frequency
%           'analytic' (false)  : calculate the analytic result (from RT)
%           'gender' ('male')   :
%
%  Example:
%   STI = ita_speech_transmission_index(IR)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_speech_transmission_index">doc ita_speech_transmission_index</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  23-Nov-2012 


%% Initialization and Input Parsing
sArgs        = struct('pos1_ir','itaAudio', 'levels', [], 'SNR', [],'plot',false,'analytic', false, 'gender', 'male');
[ir,sArgs] = ita_parse_arguments(sArgs,varargin); 

if ~strcmpi(ir.signalType,'energy')
    ita_verbose_info('Your IR does not have the correct signalType, I will fix this, but be careful!',0);
    ir.signalType = 'energy';
end

if ir.trackLength < 1.6
    ita_verbose_info('IR is shorter than ISO 60268-16 recommends, I hope you know what you are doing! I will extend the data',0);
    ir = ita_extend_dat(ir,round(ir.samplingRate*1.6));
end

if strcmpi(sArgs.gender,'male')
    genderIndex = 1;
elseif strcmpi(sArgs.gender,'female')
    genderIndex = 2;
else
    error('Gender can be either male or female');
end

%% constants
fk      = ita_ANSI_center_frequencies([125 8000],1);
fm      = [0.63 0.8 1 1.25 1.6 2 2.5 3.15 4 5 6.3 8 10 12.5];
I_k_rt  = 10.^([46 27 12 6.5 7.5 8 12].'./10);

alpha   = [0.085, 0.127, 0.23, 0.233, 0.309, 0.224, 0.173; ...
           0, 0.117, 0.223, 0.216, 0.328, 0.25, 0.194].';

beta    = [0.085, 0.078, 0.065, 0.011, 0.047, 0.095, 0; ...
           0, 0.099, 0.066, 0.062, 0.025, 0.076, 0].';

%% input check
% level is used for masking effects
if isempty(sArgs.levels)
    L   = -Inf.*ones(numel(fk),1); % no masking
else
    L   = 20.*log10(sArgs.levels.freq2value(fk))+94;
end

if isempty(sArgs.SNR)
    SNR = Inf.*ones(1,numel(fk));
else
    SNR = 20.*log10(sArgs.SNR.freq2value(fk).');
end

% include background noise for masking, as pointed out by Jan Verhave
I_k     = 10.^(L(:)./10) + 10.^((L(:)-SNR(:))./10);

%% processing
% bandfiltered IR and IR.^2
h_k     = ita_filter_fractional_octavebands(ir,'bandsperoctave',1,'freqRange',[125 8000]);
h_k_sq  = h_k.^2;
% modulation transfer function values
m_k_fm = zeros(numel(fk),numel(fm));
for iM = 1:numel(fm)
    % to get an FFT bin exactly at fm
    newLength = floor(floor(h_k.trackLength*fm(iM))/fm(iM)*h_k.samplingRate/2)*2;
    h_k_sq_tmp = ita_time_crop(h_k_sq,[1 newLength],'samples');
    m_k_fm(:,iM) = (abs(h_k_sq_tmp.freq2value(fm(iM)))./(abs(h_k_sq_tmp.freq2value(0)).*(1+10.^(-SNR./10)))).';
end
% old version:
% m_k_fm  = bsxfun(@rdivide,abs(h_k_sq.freq2value(fm)),abs(h_k_sq.freq2value(0)).*(1+10.^(-SNR./10))).';

% correction terms for masking and reception threshold
I_k_am = zeros(numel(fk),1);
for iBand = 1:numel(fk)
    if iBand > 1
        L_k = L(iBand-1);
        if L_k < 63
            I_k_am(iBand) = 0.5*L_k - 65;
        elseif L_k < 67
            I_k_am(iBand) = 1.8*L_k - 146.9;
        elseif L_k < 100
            I_k_am(iBand) = 0.5*L_k - 59.8;
        else
            I_k_am(iBand) = -10;
        end
        I_k_am(iBand) = I_k(iBand-1).*10.^(I_k_am(iBand)./10);
    else
        I_k_am(iBand) = 0;
    end
end
% apply correction
correctionTerm = I_k./(I_k+I_k_am+I_k_rt);
if all(I_k == 0)
    correctionTerm = 1;
end
m_k_fm_eff = min(bsxfun(@times,m_k_fm,correctionTerm),1);

% calculate effective SNR
SNR_eff = min(max(real(10.*log10(m_k_fm_eff./(1-m_k_fm_eff))),-15),15);

% calculate Transmission Index
TI = (SNR_eff + 15)./30;
% avg over modulation frequencies
MTI = itaResult(mean(TI,2),fk,'freq');
MTI.channelNames = {'Measurement Result'};
% calculate actual STI
STI = min(max(sum(alpha(:,genderIndex).*MTI.freq) - sum(beta(1:6,genderIndex).*sqrt(MTI.freq(1:6).*MTI.freq(2:7))),0),1);

if sArgs.analytic
    % RT for analytic result
    RT      = ita_roomacoustics(ir,'T30','freqRange',[125 8000],'bandsperoctave',1);
    RT      = RT.T30.freq;
    m_analytic = 1./(bsxfun(@times,sqrt(1 + (2*pi.*bsxfun(@times,fm,RT)./13.8).^2),(1+10.^(-SNR.'./10))));
    m_analytic = min(bsxfun(@times,m_analytic,correctionTerm),1);
    SNR_eff_analytic = min(max(real(10.*log10(m_analytic./(1-m_analytic))),-15),15);
    TI_analytic = (SNR_eff_analytic + 15)./30;
    MTI_analytic = itaResult(mean(TI_analytic,2),fk,'freq');
    STI_analytic = min(max(sum(alpha(:,genderIndex).*MTI_analytic.freq) - sum(beta(1:6,genderIndex).*sqrt(MTI_analytic.freq(1:6).*MTI_analytic.freq(2:7))),0),1);
    
    MTI = merge(MTI_analytic,MTI);
    MTI.channelNames = {'Analytic Result','Measurement Result'};
end

MTI.comment = 'Modulation Transmission Index';
MTI.allowDBPlot = 0;

% show
if sArgs.plot
    ita_plot_freq(MTI,'nodb','xlim',[125 8000],'ylim',[0 1.05]);
end

%% Set Output
varargout(1) = {STI}; 
if nargout > 1
    varargout(2) = {MTI};
    if nargout > 2 && sArgs.analytic
        varargout(3) = {STI_analytic};
    end
end

%end function
end