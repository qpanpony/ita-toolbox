function result = filterCTC(binauralInput,CTCfilter,domain)
%filterCTC - Filter binaural signal with CTC filter network
%  This function receives a binaural singal as a two channel itaAudio
%  object and a CTC filter as a four channel itaAudio object (possibly
%  generated with the function generateCTC). It is possible to choose in
%  which domain calculation will be done, being time domain the standard.
%
%  The output is another binaural signal, saved as a two channel itaAudio
%  object.
%
%  Call: result = filterCTC(binauralInput,CTCfilter)
%
% Author: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  29-Sep-2009 
%$ENDHELP$
%% Get ITA Toolbox preferences

% <ITA-Toolbox>
% This file is part of the application Binaural for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU>
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU>

warning('This function will move to ita_ctc_loudspeaker_signals in future releases.'); %MKO

%% Initialization
if nargin < 2
    error('CTC:InputArguments','This function requires two input arguments.')
end

if ~isa(binauralInput,'itaAudio') || ~isa(CTCfilter,'itaAudio')
    error('CTC:InputArguments','The input variable must be itaAudio objects.')
end

if nargin < 3
    domain = 'time';
end

% Frequency vectors for the binaural input
if binauralInput.nChannels ~= 2
    error('CTC:InputArguments','The binaural signal must contain two channels.')
else
    inL = binauralInput.ch(1);
    inR = binauralInput.ch(2);
end

% Frequency vectors for the CTC filters.
% e.g.: CTC_LR -> transfer function for the filter from the left signal to
% the right loudspeaker.
if size(CTCfilter,2) ~= 2
    error('CTC:InputArguments','The CTC filter must contain two rows.')
end

%% CTC filtering

[ca,cb] = size(CTCfilter);
  

if CTCfilter(1,1).nBins == 1
    for idx = 1:ca
        for jdx = 1:cb
            ctc(idx,jdx) = CTCfilter(idx,jdx).freq;
        end
    end
    CTC = ctc;
end

result = binauralInput;

if strcmp(domain,'time')
    for adx = 1:ca
        aux = 0;
        for bdx = 1:cb
            aux = aux + ita_convolve(CTCfilter(adx,bdx),binauralInput.ch(bdx));
        end
        result(adx) = aux;
    end
else
    % Do calculation in freq domain. First signals must be extended to be
    % the same size.
    for adx = 1:ca
        for bdx = 1:cb
            if CTCfilter(adx,bdx).nSamples < binauralInput.nSamples;
                CTCfilter(adx,bdx) = ita_extend_dat(CTCfilter(adx,bdx),binauralInput.nSamples,'forcesamples');
            end
        end
    end
        
    for adx = 1:ca
        aux = 0;
        for bdx = 1:cb
            aux = aux + CTCfilter(adx,bdx)*binauralInput.ch(bdx);
        end
        result(adx) = aux;
    end
end

result = merge(result);

%% Output
result = ita_metainfo_add_historyline(result,'filterCTC','ARGUMENTS');
result = result.';
end
%EOF generateCTC