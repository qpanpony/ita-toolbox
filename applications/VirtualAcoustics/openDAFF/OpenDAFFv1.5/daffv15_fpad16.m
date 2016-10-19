function [ ] = daffv15_fpad16( fid )
%DAFF_FILE_PAD16 Zero-pads a file to a length that is a multiple of 16 Bytes

% <ITA-Toolbox>
% This file is part of the application openDAFF for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


    nfill = mod(ftell(fid), 16);
    if (nfill > 0)
        for i=1:(16-nfill), fwrite(fid, 0, 'uint8'); end;
    end
end
