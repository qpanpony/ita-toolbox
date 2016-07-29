function varargout = ita_otpa(varargin)
%ITA_OTPA - Operational Path Analysis (OTPA/OPA)
%  This function realizes an OTPA measurement, by using only accelerations
%  or velocities (measured in-situ, in operating condition) and sound
%  pressure. The result is the estimated transfer path between the source
%  quantities acc or velocity and the sound pressure in the receiving
%  point.
%
%  Syntax:
%   audioObjOut = ita_otpa(p,a)
%
%   Options (default):
%           'blocksize' (4096) : divide into blocks of this size
%           'tol' (1e-15)      : tol for regularization with SVD
%           'prewhite' (false) : make the excitation signals smoothly white
%
%  See also:
%   ita_tps, test_pdi_otpa_tps
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_otpa">doc ita_otpa</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  11-Nov-2010


%% Initialization and Input Parsing
sArgs = struct('pos1_p','itaAudio','pos2_a','itaAudio', 'tol', 1e-15,'blocksize',4096,...
    'window',@hann,'overlap',0.5,'prewhite',false);
[p,a,sArgs] = ita_parse_arguments(sArgs,varargin);

%%
if sArgs.prewhite %pdi's intellectual property :-)
    prewhite = ita_mean(ita_smooth_frequency(ita_zerophase(a),'bandwidth',1/12));
    a = a / prewhite;
    p = p / prewhite;
end

%% OPA
blocksize = sArgs.blocksize;
p_m = ita_multiple_time_windows(p,'blocksize',blocksize,'window',sArgs.window,'overlap',sArgs.overlap);
a_m = ita_multiple_time_windows(a,'blocksize',blocksize,'window',sArgs.window,'overlap',sArgs.overlap);

M = numel(p_m);       % number of segments
N = a_m(1).nChannels; % number of sources
K = p_m(1).nChannels; % number of observation points (receiver)

nBins  = p_m(1).nBins;
p_data = zeros(M,1,nBins);
a_data = zeros(M,N,nBins);

% get data from itaAudios
for m = 1:M
    p_data(m,1:K,:) = p_m(m).freqData.';
    a_data(m,1:N,:) = a_m(m).freqData.';
end

%% invertation loops
for idx = 1:K
    TP2(idx) = p_m(1).ch(idx)/a_m(1) * 0;
end
tic
for idx = 1:K %go thru all receiver points
    TP2freqData = zeros(N,nBins);
    
    for f_idx = 1:nBins %go thru all frequency bins
        Ainv = pinv( a_data(:,:,f_idx) ,sArgs.tol );
        TP2freqData(1:N,f_idx) = Ainv * p_data(:,idx,f_idx); %pseudo-inverse with regularization
        
    end
    TP2(idx).comment = ['svd tol:' num2str(sArgs.tol) ' - ' p.channelNames{idx}];
    TP2(idx).freqData = TP2freqData.';
    
    for idx=1:K
        for jdx=1:N
            TP3(idx,jdx) =  TP2(idx).ch(jdx);
        end
    end
    
end
toc

%% Set Output
varargout(1) = {TP3};

%end function
end