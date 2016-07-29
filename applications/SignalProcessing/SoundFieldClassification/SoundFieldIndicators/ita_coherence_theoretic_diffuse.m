function varargout = ita_coherence_theoretic_diffuse(varargin)
%ITA_COHERENCE_THEORETIC 
%   Calculate theoretic coherence in a diffuse sound filed for a given sensor spacing.
%
%   Options:
%       fft_deg
%       spacing
%       sr
%       kind (pp / pu)
%       audio
%
%
%  Call: itaAudio = ita_coherence_theoretic(itaAudio)
%
%   See also ita_roomacoustics, ita_sqrt, ita_roomacoustics_reverberation_time, ita_roomacoustics_reverberation_time_hirata, ita_roomacoustics_energy_parameters, test, ita_sum, ita_audio2struct, test, ita_channelnames_to_numbers, ita_test_all, ita_test_rsc, ita_arguments_to_cell, ita_test_isincellstr, ita_empty_header, ita_change_header, ita_metainfo_to_filename, ita_filename_to_header, ita_metainfo_coordinates, ita_metainfo_coordinates, ita_metainfo_coordinates, ita_roomacoustics_EDC, test_ita_class, ita_metainfo_find_frequencystring, clear_struct, ita_italian, ita_italian_init, ita_metainfo_check, ita_UPcontrol, ita_cepstrum.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_coherence_theoretic">doc ita_coherence_theoretic</a>

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  26-Feb-2009 

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
%narginchk(1,1);
sArgs        = struct('fft_deg',10,'spacing',1,'sr',44100,'kind',{{'pp'}},'audio','');
sArgs = ita_parse_arguments(sArgs,varargin);

%% +++Body - Your Code here+++ 'result' is an audioStruct and is given back
if isempty(sArgs.audio)
    F = linspace(0,sArgs.sr/2,(2^sArgs.fft_deg)/2+1);
else
    F = sArgs.audio.freqVector;
    sArgs.sr = sArgs.audio.samplingRate;
end

i_ges = 0;
for idx = 1:numel(sArgs.kind)
    if ~isempty(sArgs.spacing)
        for i = 1:length(sArgs.spacing)
            i_ges = i_ges+1;
            switch lower(sArgs.kind{idx})
                case 'pp'
                    Cxy(:,i_ges) = theo_cohere(sArgs.spacing(i),F); %#ok<*AGROW>
                    ChannelNames{i_ges} = ['Theorectic coherence in a diffuse sound field with sensor spacing of ' num2str(sArgs.spacing(i)) ' m '];
                case 'pu'
                    ChannelNames{i_ges} = ['Theorectic pu coherence in a diffuse sound field with sensor spacing of ' num2str(sArgs.spacing(i)) ' m '];
                    Cxy(:,i_ges) = theo_pu_cohere(sArgs.spacing(i),F);
            end
            ChannelUnits{i_ges} = '';
        end
    else
        error('I need a sensor distance!')
    end
end

result = itaAudio;
result.samplingRate = sArgs.sr;
result.freqData = Cxy;
result.channelNames = ChannelNames;
result.channelUnits = ChannelUnits;


%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    ita_plot_spk(result,'nodb','ylim',[0 1]);
else
    % Write Data
    varargout(1) = {result}; 
end

%end function
end

function [c] = theo_cohere(d,f)
k = 1./(340./(2*pi*f));
c = (sin(k*d)./(k*d)).^2;
c(isnan(c))=1;
end

function [c] = theo_pu_cohere(d,f)
k = 1./(344./(2*pi*f));
c = (((sin(k.*d) - k.*d.*cos(k.*d))./(k.*d)).^2);
c(c>1) = 1;
c(isnan(c))=0;
%c = c/max(c);
end
