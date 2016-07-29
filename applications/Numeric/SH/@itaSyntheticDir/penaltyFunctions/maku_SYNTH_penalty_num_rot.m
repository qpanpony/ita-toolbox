function result = maku_SYNTH_penalty_num_rot(this, indexPositions)

freq = ita_ANSI_center_frequencies(this.freqRange,1);
nRot = length(this.angle_rot_I) + length(this.angle_rot_II);

nCh_s = length(this.speaker_channels);
diagSE = zeros((this.nmax+1)^2,nRot/16,length(freq));


idxWB = 0;
maxWB = length(freq)*nRot-1;
WB = waitbar(idxWB/maxWB,['maku\_SYNTH\_penalty\_num\_rot  (progress : ' int2str(0) ' %)']);
for idxF = 1:length(freq)
    speaker = this.freq2coefSH_synthesisedSpeaker(freq(idxF),'nmax',this.nmax);
    for idxD = 1:nRot
        waitbar(idxWB/maxWB, WB, ['maku\_SYNTH\_penalty\_num\_rot  (progress : ' num2str(idxWB/maxWB*100,2) ' %)']);
        idxWB = idxWB+1;
        
        sE = abs(...
            maku_SYNTH_make_SynthMatrix(speaker(1:idxD*nCh_s, :), this.condmax, 0) ...
            * speaker(1:idxD*nCh_s, :)).^2;
        
        %avoid division by zero
        divisor =  sum(sE,2);
        idxKill = (1:length(divisor)).' .* (divisor < 1e-5);
        idxKill = idxKill(idxKill~=0);
        divisor(idxKill) = 1e5; 
        diagSE(:,idxD,idxF) = diag(sE) ./ divisor;
    end
end

result = itaResult;
result.timeVector = (1:nRot);
result.timeData   = zeros(nRot,length(freq));

waitbar(idxWB/maxWB, WB, ['maku\_SYNTH\_penalty\_num\_rot  (concluding ... )']);
for idxF = 1:length(freq)
    val = zeros(this.nmax+1,size(diagSE,2));
    
    %Basis soll mit maximal 1.5 dB Fehler synthetisiert werden,
    %schlechter interresiert nicht, da sie eh rausfliegt...
    val_cut = 10^(-1.5/10);
    
    % val(idxO,:) : die am schlechtesten synthetisierte Basisfunktion
    for idxO = 0:this.nmax
        val(idxO+1,:) = min(diagSE(idxO^2+1:(idxO+1)^2,:,idxF),[],1);
    end
    
    %optimum: alle Lautsprecherpositionenverwenden: val(:,end)
    optimum = val(:,end);
    idxKillNot = (1:this.nmax+1).' .* (optimum > val_cut);
    idxKillNot = idxKillNot(idxKillNot~=0);
    val(idxKillNot,:) = val(idxKillNot,:) ./ repmat(optimum(idxKillNot),1,size(val,2));
    
    result.timeData(:,idxF) = sqrt(mean(val(idxKillNot,:),1)) .';
    
    %% ggf Diagonaleinträge von sE über der ANzahl der Lautsprecherpositionen graphisch darstellen
    %     idxKill = (1:size(val,1)).';
    %     for idx = 1:length(idxKillNot)
    %         idxKill = idxKill(idxKill ~= idxKillNot(idx));
    %     end
    %     subplot(3,ceil(length(freq)/3),idxF),
    %     h = pcolor(max(val,val_cut));
    %     set(h,'linestyle','none');
    %     xlabel('number of rotations')
    %     title(int2str(freq(idxF))); colorbar;
    
    
end
close(WB)
%     result.plot_dat_dB('ylim',[-5 0.1]); xlabel('number of rotations')
end