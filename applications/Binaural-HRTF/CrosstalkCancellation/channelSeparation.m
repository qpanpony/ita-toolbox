function  varargout = channelSeparation(HRTF,CTC,domain,frange)
%channelSeparation - Calculate the theoretically achivable channel
%  separation for a CTC filter network.
%  This function receives a set of HRTF and a CTC filter. The input must be
%  two itaAudio objects, each containing two channels with the transfer
%  function from a loudspeaker to the left and right ears of an artificial
%  head and a CTC filter, generated with the function "generateCTC.m".
%  The transfer functions of the left loudspeaker should be given first,
%  followed by the transfer function of the right loudspeaker.
%
%  The output is a set of four plots showing the achivable channel
%  separation.
%
%  Call:  channelSeparation(HRTF,CTCfilter)
%
% Author: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  29-Sep-2009 
%$ENDHELP$

% <ITA-Toolbox>
% This file is part of the application Binaural for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% Initialization
if nargin < 2
    error('CTC:InputArguments','This function requires at least two input arguments.')
end

if nargin < 3
    domain = 'freq';
end

if nargin < 4
    frange = [400 16000];
end

if ~isa(HRTF,'itaAudio') || ~isa(CTC,'itaAudio')
    error('CTC:InputArguments','The input variable must be itaAudio objects.')
end


% if HRTF(1,1).nSamples > CTC(1,1).nSamples
%     CTCfilter = ita_extend_dat(CTC,HRTF(1,1).nSamples,'forcesamples');
% elseif HRTF.nSamples < CTC.nSamples
%     HRTF = ita_extend_dat(HRTF,CTC(1,1).nSamples,'forcesamples');
% end

[ha,hb] = size(HRTF);
[ca,cb] = size(CTC);
if ha~=cb || hb~=ca
    error('CTC:InputArguments','The number of filters and speakers do not match!')
end 
   
%% Channel Separation
if CTC(1,1).nBins == 1
    for idx = 1:ca
        for jdx = 1:cb
            ctc(idx,jdx) = CTC(idx,jdx).freq;
        end
    end
    CTC = ctc;
end

%% frequency multiplication
for adx = 1:ha
    for bdx = 1:ca
        if HRTF(adx,bdx).nSamples < CTC(bdx,adx).nSamples;
            HRTF(adx,bdx) = ita_extend_dat(HRTF(adx,bdx),CTC(bdx,adx).fftDegree);
        else
            CTC(bdx,adx) = ita_extend_dat(CTC(bdx,adx),HRTF(adx,bdx).fftDegree);
        end
    end
end

for adx = 1:ha
    for bdx = 1:cb
        aux = 0;
        for idx = 1:hb
            aux = aux + HRTF(adx,idx)*CTC(idx,bdx);
        end
        KT(adx,bdx) = aux;
     end
end

%% convolution
% for adx = 1:ha
%     for bdx = 1:cb
%         aux = 0;
%         for idx = 1:hb
%             aux = aux + ita_convolve(HRTF(adx,idx),CTC(idx,bdx));
%         end
%         KT(adx,bdx) = aux;
%      end
% end


        
%% Output
switch domain
    
    case 'no_plot'
        %% Channel Separation
        L = KT(1,2)/KT(1,1);
        R = KT(2,1)/KT(2,2);

    case 'index'
        L = KT(1,2)/KT(1,1);
        R = KT(2,1)/KT(2,2);
        % Calculate the Channel Separation index according to Bae & Lee
        % Weighting was not used at their paper.
%         w = ones(size(KT(1,1).freqVector));
        W = KT(1,1).freqVector;
        w = zeros(size(W));
        idL = KT(1,1).freq2index(frange(1));
        idH = KT(1,1).freq2index(frange(2));
        w(idL:idH) = 1;%./(W(idL:idH));
        W = w/sum(w);        
        varargout{1} = [W'*L.freqData_dB W'*R.freqData_dB];
        
    case 'phase'
        freq = KT(1,1).freqVector;
        
        for idx = 1:ha
            for jdx = 1:cb
                st(idx,jdx) = ita_start_IR(KT(idx,jdx));
            end
        end
        st=min(min(st));
         for idx = 1:ha
            for jdx = 1:cb
                KT(idx,jdx) = ita_time_shift(KT(idx,jdx),-st,'samples');
            end
        end
        for idx = 1:ha
            for jdx = 1:cb
                kdx = idx + (jdx-1)*ha;
                eval(['subplot(22' num2str(kdx) ');']);
                semilogx(freq,angle(KT(idx,jdx).freqData));
                xlim([freq(2) freq(end)]);
                grid on
            end
        end
        
        
    case 'freq'
        freq = KT(1,1).freqVector;
        M = -inf;
        m = inf;
        
        idL = KT(1,1).freq2index(frange(1));
        idH = KT(1,1).freq2index(frange(2)); 
        
        for idx = 1:ha
            for jdx = 1:cb
                kdx = idx + (jdx-1)*ha;
                eval(['subplot(22' num2str(kdx) ');']);
                semilogx(freq,KT(idx,jdx).freqData_dB);
                fig_h(idx,jdx) = gca;
                
                xlim([freq(2) freq(end)]);
                set(gca,'XMinorGrid','on')
                grid on
                hold all
                
                data_dB = KT(idx,jdx).freqData_dB;
                meanff = mean(data_dB(idL:idH));
%                 h=line(xlim, [meanff meanff]); set(h,'Color','r');
                
                stdff=std(data_dB(idL:idH));
%                 h=line(xlim, [meanff-stdff meanff-stdff]); set(h,'Color','r','LineStyle',':');
%                 h=line(xlim, [meanff+stdff meanff+stdff]); set(h,'Color','r','LineStyle',':');
                
                title([num2str(meanff) ' \pm ' num2str(stdff)]);
                
                if M < max(KT(idx,jdx).freqData_dB)
                    M = max(KT(idx,jdx).freqData_dB);
                end
                
                if m > min(KT(idx,jdx).freqData_dB)
                    m = min(KT(idx,jdx).freqData_dB);
                end
            end
        end
        
        if m < -100
            m = -100;
        end
        
        for idx = 1:numel(fig_h)
%             ylim(fig_h(idx),[m M]);
              ylim(fig_h(idx),[-70 10]);
        end
        
    case 'time'
        time = KT(1,1).timeVector;
        M = -inf;
        m = inf;
        for idx = 1:ha
            for jdx = 1:cb
                M = max(max(abs(KT(idx,jdx).timeData)),M);
        %         m = min(min(abs(KT(idx,jdx).freqData)),m);
            end
        end
        
        for idx = 1:ha
            for jdx = 1:cb
                kdx = idx + (jdx-1)*ha;
                eval(['subplot(22' num2str(kdx) ');']);
                plot(time,KT(idx,jdx).timeData);hold all;
                ylim([-M M]);
                xlim([time(1) time(end)]);
                grid on
                hold all
            end
        end
        
        case 'time_dB'
        time = KT(1,1).timeVector;
        M = -inf;
        m = inf;
        for idx = 1:ha
            for jdx = 1:cb
                M = max(max(abs(KT(idx,jdx).timeData)),M);
        %         m = min(min(abs(KT(idx,jdx).freqData)),m);
            end
        end
        M = 20*log10(M);
        M = ceil(M/10)*10;
        for idx = 1:ha
            for jdx = 1:cb
                kdx = idx + (jdx-1)*ha;
                eval(['subplot(22' num2str(kdx) ');']);
                plot(time,20*log10(abs(KT(idx,jdx).timeData+eps)));
                ylim([M-100 M]);
                xlim([time(1) time(end)]);
                grid on
                hold all
                
                maxff = 20*log10(max(max(abs(KT(idx,jdx).timeData)),M));
                h=line(xlim, [maxff maxff]); set(h,'Color','r');
                
                title(num2str(maxff));
                
            end
        end
end

if nargout == 1
    if strcmpi(domain,'index')
        return
    else
        varargout{1} = KT;
    end
elseif nargout == 2
    if strcmpi(domain,'index')
        ch = L;
        ch(1) = L; ch(2) = R;
        varargout{2} = ch;
    else
        varargout{1} = L;
        varargout{2} = R;
    end
elseif nargout > 2
    error('Too many output parameters');
end
%EOF channelSeparation