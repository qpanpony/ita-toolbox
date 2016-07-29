function out = maku_SYNTH_penalty_num_IRII(filemask,refPos,nRef,oct)
%% angefangen: Auswertung in mehreren Frequenzbändern....
% filemask: [path filesep nameextension]

nIr = numel(dir([filemask '*']));
freq_range = [400 6000];

%% init reference and time constances
idInitFiles = refPos + (0:nRef-1);
if max(idInitFiles) > nIr
    idInitFiles = idInitFiles - max(idInitFiles) + nIr;
end

[mean_data, crop] = initialize_filtering(filemask, idInitFiles ,freq_range, oct);
norm_factor = sum(mean_data.timeData.^2);

%% proceed all data
out = itaResult;
out.timeVector = 1:nIr;

for idxIR = 1:nIr
    if ~mod(idxIR,5)
        disp([int2str(idxIR) ' / ' int2str(nIr) ' done']);
    end
    data = ita_read([filemask int2str(idxIR) '.ita']);
    data = ita_mpb_filter(data,freq_range);
    data = ita_time_crop(data,[0 crop],'time');
    out.timeData(idxIR) = sum(data.timeData.*mean_data.timeData) / norm_factor;
end
%%
plotOut = out; plotOut.timeData = sqrt(out.timeData);
plotOut.plot_dat_dB('ylim',[-3 0.1]); xlabel('Idx Impulsantwort'); 
end


function [mean_data, crop] = initialize_filtering(filemask, idInitFiles ,freq_range, oct)

% mean_data : Referenzimpulsantwort, berechnet aus den
%       'idInitFiles'-Impulsantworten
%crop       : ungefähr der Anteil ('time') der frühen Reflexionen
%       crop = I_time/2 (I_time: Übergang Signal -> Rauschen, über
%       ita_roomacoustics_detectionSNR_room;
all_data = itaAudio(length(idInitFiles),1);
for idx = 1:length(idInitFiles)
    all_data(idx) = ita_read([filemask int2str(idInitFiles(idx)) '.ita']);
end

idxF = ita_ANSI_center_frequencies([25 22000],oct);
[dum idMin] = min(abs(idxF - min(freq_range)));
[dum idMax] = min(abs(idxF - max(freq_range))); clear dum;
crop  = zeros(length(idInitFiles),1);
for idxA = 1:length(all_data) 
%      all_data(idxA) = ita_mpb_filter(all_data(idxA),freq_range);
     test = ita_mpb_filter(all_data(idxA),'oct',oct);
     res = ita_roomacoustics_detectionSNR(all_data(idxA));
     crop(idxA,:) = res(2).freqData;
end

crop = mean(crop)/2; % Frühe Reflexionen sind hauptsächlich relevant
mean_data = mean(all_data);
mean_data = ita_time_crop(mean_data,[0 crop],'time');

end
