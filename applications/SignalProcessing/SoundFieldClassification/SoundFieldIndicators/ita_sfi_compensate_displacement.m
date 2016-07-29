function this = ita_sfi_compensate_displacement(this)

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


this.channelCoordinates = ita_sfi_calculate_acoustic_center(this);

%for idx = 1:this.directions.nPoints
for idch = 1:this.nChannels
    d = this.directions - this.channelCoordinates.n(idch);
    d = d.r.';
    c = ita_constants('c');
    delta_t = d / c.value;
    delta_t = delta_t - mean(delta_t); % No shift of average time
    f = this.freqVector;
    omega = 2*pi*f;
    delta_t = repmat(delta_t,size(omega,1),1);
    omega = repmat(omega,1,size(delta_t,2));
    
    this.freq(:,:,idch) = this.freq(:,:,idch).* exp(-1i*omega.*delta_t);
end    
    
    
end



