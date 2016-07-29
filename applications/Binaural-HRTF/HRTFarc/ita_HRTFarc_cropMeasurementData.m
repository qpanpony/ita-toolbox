function [ output_args ] = ita_HRTFarc_cropMeasurementData( iMS,dataPath )
%ITA_HRTFARC_CROPMEASUREMENTDATA crop of raw measurement data
%   This function is intended to be used after a measurement with the HRTF
%   arc. During the measurement, the cropping is not done to save time.
%   The function assumes a data structure from itaEimar
%   It will read all files from dataPath/data, crop them
%   It will rename the folder to data_raw. Cropped data will be in
%   dataPath/data to maintain backwards compability. 

    savePath = sprintf('%s/cropped/',dataPath);
    dataPathInternal = sprintf('%s/data/',dataPath);

    mkdir(savePath)
    % load all data, crop and save again
    dataDir = dir(dataPathInternal);
    
    wb = itaWaitbar(length(dataDir)-2);
    for index = 3:length(dataDir)
       data = ita_read(sprintf('%s/%s',dataPathInternal,dataDir(index).name));
       data_cropped = iMS.crop(data);
       ita_write(data_cropped,sprintf('%s/%s',savePath,dataDir(index).name));
       wb.inc;
    end
    wb.close;
    rawPath = sprintf('%s/data_raw/',dataPath);
    
    movefile(dataPathInternal,rawPath);
    movefile(savePath,dataPathInternal);
    
end

