function result = rms(this)
% get rms of data

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>



if strcmpi(this.signalType, 'energy') % RMS will not change if zeros are added to impluse response
    ita_verbose_info('Warning! RMS values for energy signals are not defined!',0)
    
    if strcmpi(this.domain, 'time')
        operation = @sum;
    else
        operation = @mean;
    end
elseif strcmpi(this.signalType, 'power')
    
    if strcmpi(this.domain, 'time')  % normal root MEAN square
        operation = @mean;
    else
        operation = @sum;            % here sum (because of normalized fft)
    end
else
    error('Unknown signal type. Don''t know how to calculate RMS')
end

% calculate without changing domain
result = sqrt(operation(abs(this.(this.domain)).^2,1));
