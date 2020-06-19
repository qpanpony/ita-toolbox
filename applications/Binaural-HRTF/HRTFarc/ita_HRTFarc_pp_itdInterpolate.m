function [centerPoint,returnData] = ita_HRTFarc_pp_itdInterpolate(results_split,fullCoords,options)

    if ~isa(results_split,'itaHRTF')
        % get the ITD from the HRTF
        
        channel1 = 1;
        channel2 = ceil(length(options.dataChannel)/2+1);
        
        results_split(channel1).channelCoordinates = fullCoords;
        results_split(channel2).channelCoordinates = fullCoords;
        tmp(1) = results_split(channel1);
        tmp(2) = results_split(channel2);
        hrtf = itaHRTF(tmp.merge);
    else
        hrtf = results_split;
    end
    if ~isfield(options,'exactSearchSlice')
        options.exactSearchSlice = 1;                                   % only allow one exact elevation in slice
    end
    slice = hrtf.sphericalSlice('theta_deg',90,options.exactSearchSlice);
    % make sure coords are identical for L and R 
    % (sdo: should be unnecessary but for some reason, sometimes not --> TODO: check!)
    slice.channelCoordinates.phi_deg(2:2:slice.nChannels) = slice.channelCoordinates.phi_deg(1:2:slice.nChannels);
    % set elevation to a single height - necessary when applying elevation correction
    slice.channelCoordinates.theta_deg = slice.channelCoordinates.theta_deg(1);
    
    if strcmp(options.itdMethod,'xcorr')
        data = slice.ITD('method','xcorr');
    else
        data = slice.ITD('method','phase_delay','filter',[1100 2000]);
    end
    xData = slice.getEar('L').channelCoordinates.phi_deg;
    xData = xData.';
    returnData.xData = xData;
    returnData.data = data;
    
    % flip the data if the positions are reversed
    if sum(diff(xData) < 0) > length(xData) / 4
        xData = fliplr(xData);
        data = fliplr(data);
    end

    % repeat 3 times to have a 360 to 0 jump even if the data is correctly
    % aligned 
    xData = repmat(xData,1,3);
    xData = unwrap(xData/180*pi)*180/pi;
    data = repmat(data,1,3);
    
    %% zero point
    % get the zero crossing from negativ to positive
    [value,index] = max(diff(sign(data(3:end))));
    
    index = index+2;
    % interpolate between near values
    tmp = data(index-2:index+2);
    xDataSlice = xData(index-2:index+2);

    
    [polynomials] = polyfit(xDataSlice,tmp,1);
    
    maxXValues = min(xDataSlice):0.1:max(xDataSlice);
    interpData = polyval(polynomials,maxXValues);
    % get the zero crossing 
    [value,maxIndex] = max(abs(diff(sign(interpData))));
      
    centerPoint = mod(maxXValues(maxIndex),360);
    

    %% check if the found itd represents a sine
    % taken from https://de.mathworks.com/matlabcentral/answers/121579-curve-fitting-to-a-sinusoidal-function
    y = returnData.data;
    x = returnData.xData;
    yu = max(y);
    yl = min(y);
    yr = (yu-yl);                               % Range of ‘y’
    yz = y-yu+(yr/2);
    zx = x(yz .* circshift(yz,[0 1]) <= 0);     % Find zero-crossings
    per = 2*mean(diff(zx));                     % Estimate period
    ym = mean(y);                               % Estimate offset

    fit = @(b,x)  b(1).*(sin(2*pi*x./b(2) + 2*pi/b(3))) + b(4);    % Function to fit
    fcn = @(b) sum((fit(b,x) - y).^2);                              % Least-Squares cost function
    s = fminsearch(fcn, [yr;  per;  -1;  ym]);
    
%     xp = linspace(min(x),max(x));

%     figure(1)
%     plot(x,y,'b',  xp,fit(s,x), 'r')
    
    coeffs = corrcoef(y,fit(s,x));
    returnData.error = 1-coeffs(2,1);
end