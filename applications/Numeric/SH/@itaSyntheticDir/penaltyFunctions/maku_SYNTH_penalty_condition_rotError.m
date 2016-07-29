function [diagSE] = maku_SYNTH_penalty_condition_rotError(this)

maxCond = 100;
rot_error = [0 0.5 1 2 4 8 16]*pi/180;

% freq = ita_ANSI_center_frequencies(this.freqRange,3);
freq = [250 500 1000 2000 4000 6000];

diagSE  = zeros((this.nmax+1)^2, length(rot_error), length(freq));

for idxF = 1:length(freq)
    speaker = this.freq2coefSH_synthesisedSpeaker(freq(idxF),'nmax',this.speaker_nmax);
  
    for idxE = 1:length(rot_error)
        WD_error = ita_sph_wignerD(this.speaker_nmax, -repmat(rot_error(idxE),1,3));
        disp([int2str(idxF) ', ' int2str(idxE)]);
        
        sE = abs(maku_SYNTH_make_SynthMatrix(speaker(:,1:(this.nmax+1)^2), maxCond, 0)...
            *(speaker * WD_error)).^2;
        
        
        divisor =  sum(sE,2);
        idxKill = (1:length(divisor)).' .* (divisor < 1e-5);
        idxKill = idxKill(idxKill~=0);
        divisor(idxKill) = 1e5;
        diagSE(:,idxE,idxF) = diag(sE) ./ divisor;
    end
end
%%

for idxF = 1:length(freq)
    % ggf Diagonaleinträge von sE über der Anzahl der Lautsprecherpositionen graphisch darstellen
   val = zeros(this.nmax+1,size(diagSE,2));
   for idxO = 0:this.nmax
        val(idxO+1,:) = min(diagSE(idxO^2+1:(idxO+1)^2,:,idxF),[],1);
   end
   
    %%
    val_cut = 0.8;
    idxKill = (1:size(val,1)).' .* (val(:,1) < val_cut);
    idxKill = idxKill(idxKill~=0);
    val(idxKill,1) = 1e6;
    val = val ./ repmat(val(:,1),1,size(val,2));
    val(idxKill,1) = 0;
    
    subplot(3,ceil(length(freq)/3),idxF),
    h = pcolor(rot_error*180/pi, 0:this.nmax, max(val,val_cut));
    set(h,'linestyle','none');
%      set(gca,'xscale','log', 'xtick',rot_error*180/pi);%,'xTickLabel',rot_error);
    xlabel('rotation error')
    title(int2str(freq(idxF))); colorbar;
end

%%
for idxE = 1:length(rot_error)
subplot(2,ceil(length(rot_error)/2),idxE)
pcolor(squeeze(diagSE(:,idxE,:)));


end

