function [sSFI, result] = ita_sfi_coherence(sSFI)

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

if isa(sSFI,'itaAudio')
    sSFI = sfi_prep(sSFI);
end
if ~isstruct(sSFI) 
    error('I need a struct from sfi_prep')
end


sSFI.Cpu_l = ita_abs(sSFI.CS_pl_ul')^2 / (sSFI.AS_pl' * sSFI.AS_ul' );
sSFI.Cpu_l.channelNames{1} = 'pu-Coherence-left';
sSFI.Cpu_l.channelUnits{1} = '';

sSFI.Cpp_lr = ita_abs(sSFI.CS_pl_pr')^2 / (sSFI.AS_pl' * sSFI.AS_pr' );
sSFI.Cpp_lr.channelNames{1} = 'pp-Coherence-left-right';
sSFI.Cpp_lr.channelUnits{1} = '';

sSFI.Cpp_l = ita_abs(sSFI.CS_plf_plb')^2 / (sSFI.AS_plf' * sSFI.AS_plb' );
sSFI.Cpp_l.channelNames{1} = 'pp-Coherence-left';
sSFI.Cpp_l.channelUnits{1} = '';

result = ita_merge([sSFI.Cpu_l sSFI.Cpp_lr sSFI.Cpp_l]);

if nargout == 0
   ita_plot_spk(result,'nodb','ylim',[-0.1 1.1])
   %ita_plot_dat(result);
   legend('Location','SouthWest');
end


end

