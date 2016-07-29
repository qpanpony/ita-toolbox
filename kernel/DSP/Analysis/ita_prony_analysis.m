function varargout = ita_prony_analysis(varargin)
%ITA_PRONY_ANALYSIS - Perform Prony Analysis
%  This function does a prony analysis of the given signal.
%
%  Syntax: result = ita_prony_analysis(itaAudio,order,options)
%  Options (default): 'domain' ('frequency'):    frequency or time domain
%                     'freq_weighted' (0):       makes only sense in frequency domain
%                     'warp' (0):                frequency warping with ita_audio_warp and ita_zpk_warp
%                     'simplify' (0):            TODO HUHU
%                     'smooth' (0):              TODO HUHU
%
%   See also ita_preferences_aspectratio, ita_plottools_aspectratio, ita_check_compatibility, ita_reversephase.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_prony_analysis">doc ita_prony_analysis</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  10-Mar-2009

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudioTime','pos2_order','integer','domain','frequency','freq_weighted',0,'warp',0,'simplify',0,'smooth',0);
[data,N,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Perform Prony Analysis
fs = data.samplingRate;
input_time = data.timeVector;
input_freq = data.freqVector;
input_omega = input_freq/fs*2*pi;

% H = [];
% w = [];
% for chidx = 1:data.nChannels
%     H = [H; data.ch(chidx).freqData];
%     w = [w; data.ch(chidx).freqVector];
% end
% w = w/data.samplingRate*2*pi;
% [inumz,idenz] = invfreqz_sparse(H, w, N, N,[],50);

for chidx = 1:data.nChannels
    
    input_data = data.ch(chidx);
    
    %% Frequency Warping
    flag_dewarp = false;
    if sArgs.warp
        flag_dewarp = true;
        lambda = barkwarp(input_data.samplingRate);
        input_data = ita_audio_warp(input_data,lambda);
    end
    
    %% Polynomial interpolation
    switch lower(sArgs.domain)
        case 'frequency'
            
            if sArgs.freq_weighted
                wt = 1./input_freq;
                wt(wt == Inf) = 0;
                wt = wt ./ max(wt);
            else
                wt = ones(size(input_freq));
            end
            
            A = input_data.freqData;
            A(input_data.freqVector > 20000) = [];
            A(input_data.freqVector < 20) = [];
            w = input_freq;
            w(input_data.freqVector > 20000) = [];
            w(input_data.freqVector < 20) = [];
            
            [inumz,idenz] = invfreqz(input_data.freqData, input_omega, N, N, wt);  % TODO HUHU Documentation
            %             [inumz,idenz] = invfreqz(A, w, N, N);
            %             [inumz,idenz] = invfreqz_sparse(A, w, N, N);
            %             MODELOBJ = RATIONALFIT(w,A,-30,[],[],1,[4 100],20,1);
            
        case 'time'
            % time vector
            [inumz,idenz] = pdi_prony(input_data.timeData,N,N);
            
    end
    
    %% Pole/Zero calculation
    [z,p,k] = tf2zp(inumz,idenz);
    
    Zs{chidx} = z;
    Ps{chidx} = p;
    Ks{chidx} = k;
    
    %% Dewarp
    if flag_dewarp
        [z,p,k] = ita_zpk_warp(z,p,k,-lambda); % TODO HUHU Documentation
    end
    
    %% Cancel Pole/Zeros too close to each other
    if sArgs.simplify
        threshold = 1e-2;
%         subset = 30;
        [z,p,k] = ita_zpk_reduce(z,p,k,'dist',threshold);
        %         [z,p,k] = ita_zpk_reduce(z,p,k,'subset',subset);
    end
    
    Zw{chidx} = z;
    Pw{chidx} = p;
    Kw{chidx} = k;
    
    
    
    %% Smooth pronounced peaks/notchs
    if sArgs.smooth
        % avoid sharp peaks, by moving poles/zeros away from unity circle
        threshold = 1e-2;
        [z,p,k] = ita_zpk_smooth(z,p,k,'threshold',threshold);
    end
    
    
    %     [zz,pp,k] = ita_zpk_decompose3(z,p,k); 
    % %     zz = [z(1:2:end) z(2:2:end)];
    % %     pp = [p(1:2:end) p(2:2:end)];
    %     for idx = 1:size(zz,1);
    %         [a(idx,:) b(idx,:)]= zp2tf(zz(idx,:).',pp(idx,:).',1);
    %     end
    
    
    [sos,g] = zp2sos(z,p,k,'up'); % TODO HUHU Documentation
    % sos = [a b];
    h = g*ones(size(input_omega));
    for idx = 1:size(sos,1)
        hn = freqz(sos(idx,1:3),sos(idx,4:6),input_omega);
        h = h.*hn;
        subplot(3,3,1:6)
        semilogx(input_freq,20*log10([data.ch(chidx).freqData h hn]));
        hold all
        semilogx(input_freq,angle([data.ch(chidx).freqData h hn]));
        hold off
        subplot(3,3,7)
        zplane(sos(idx,1:3),sos(idx,4:6))
        subplot(3,3,8:9)
        impz(sos(idx,1:3),sos(idx,4:6),input_time*fs,fs);
        drawnow
    end
%     H{chidx} = h;
    Z{chidx} = z;
    P{chidx} = p;
    K{chidx} = k;
end
save('zpk_full_l1','Z','P','K','Zs','Ps','Ks','Zw','Pw','Kw','H')
for idx = 1:length(Z)
    ita_plot_zplanepz(Z{idx},P{idx},K{idx}); hold all
end
for idx = 1:size(result,1)
    %% omitting
    %     try
    %        if abs(result(idx-1,3)) == abs(result(idx,3)) %equal frequencies
    %            result_struct(count-1).a = 2 * result_struct(count-1).a;
    %            result_struct(count-1).f_ex = [result_struct(count-1).f_ex result(idx,3)];
    %            disp('omitting')
    %            continue;
    %        end
    %     end
    
    count = idx;
    
    %% nice structs
    result_struct(count).a    = result(idx,1); %#ok<*AGROW>
    result_struct(count).phi  = result(idx,2);
    result_struct(count).f    = abs(round(result(idx,3)./2/pi));
    result_struct(count).f_ex = (result(idx,3)./2/pi);
    result_struct(count).tau  = result(idx,4);
end


%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    
else
    % Write Data
    varargout(1) = {result_struct};
    if nargout == 2
        varargout{2} = rdata;
    end
end

%end function
end