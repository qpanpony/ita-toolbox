
function filter = test_synthesize_yourself(this, aperture)

freq = this.speaker.freqVector;
coef = this.freq2coefSH_synthSpeaker(freq, 'channels', 4, 'nmax',this.nmax);

disp(['try to synthesise aperture ' int2str(aperture)]);
TRC = this.aperture2idxTiltRotCh(aperture,:);
FF  = this.idxTiltRot2idxFolderFile{TRC(1), TRC(2)};

disp(['  id tilt / rotation angle \channel   : ' int2str(TRC)]);
disp(['  id folder / file : ' int2str(FF)]);

if isempty(this.speaker.sensitivity)
    filter = this.freqData2synthFilter(squeeze(coef).', freq, 'muteChannels', aperture);
 
else
    filter = this.freqData2synthFilter(squeeze(coef).', freq, 'sensitivity',this.speaker.sensitivity(TRC(3)), 'muteChannels', aperture);
end 