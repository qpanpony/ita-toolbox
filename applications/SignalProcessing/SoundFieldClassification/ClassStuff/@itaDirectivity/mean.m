function result = mean(this,varargin)

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    %calculate mean over all directions for each channel of an itaDirectivity
    % Options: equiang
    
    sArgs = struct('equiang',false);
    sArgs = ita_parse_arguments(sArgs,varargin);
    
    if sArgs.equiang
        weights = (sin(this.directions.theta).').^2;
        weights = weights ./ sum(weights);        
    else
        weights = repmat(1,1,this.directions.nPoints);
    end
    this.freq = bsxfun(@times,this.freq,weights);
    
    
    result = itaAudio; %Result will be an itaAudio, no directivity
    
    result.freq = squeeze(sum((this.freq),2));
    
    result.channelNames = this.channelNames;
    result.channelUnits = this.channelUnits;
    result.samplingRate = this.samplingRate;
    result.comment = this.comment;
    
    
    
    

end