function [ data ] = ita_HRTFarc_pp_moveFullDataSet(data,fullCoords,options,offsetShift,mode)

    freqVector = data.freqVector;
    shiftedData = zeros(size(data.freqData));
    axis = 'y';
    for index = 1:length(freqVector)
        shiftedData(index,:) = moveHRTF(fullCoords,data.freqData(index,:),freqVector(index),axis,offsetShift,mode);
    end


    data.freqData = shiftedData;
end

function [data,newAxis] = moveHRTF(s, data, frequency, axis, offset,mode)
    % the offset is given in m
    
    origAxis = s.r;
    
    if (size(data,2) > size(data,1))
       data = data.'; 
    end
    offset = real(offset); % ??
    switch axis
        case 'x' 
            s.x = s.x + offset;
        case 'y'
            s.y = s.y + offset;
        case 'z'
            s.z = s.z + offset;
    end
    
    newAxis = s.r;
    k = 2*pi*frequency/340;
    % the phase is moved by the difference of the axis points
    switch mode
        case 1
            data = data .* exp(1i*k*(newAxis - origAxis));
        case 2
            data = data .* exp(1i*k*(origAxis - newAxis));     
    end
    % amplitude manipulation did not yield better results
    % data = data .* newAxis ./ origAxis;

end