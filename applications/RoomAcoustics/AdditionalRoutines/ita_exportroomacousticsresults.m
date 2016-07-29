function ita_exportroomacousticsresults(acparams, textfile)
%ita_exportroomacousticsresults(acparams, textfile)
%
%   Stores the results of ita_roomacoustics into a text file.
%   All paramters will be exported.
%

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

    fid = fopen(textfile, 'w+');
    for i = 1 : numel(acparams)
        fprintf(fid, '\r\n%s', acparams(i).comment);     % name of the parameter 
        fprintf(fid, '\t%i', acparams(i).freqVector);
        fprintf(fid, '\r\n');
        for j = 1 : size(acparams(i).freq, 2)
            fprintf(fid, '%i', j);
            fprintf(fid, '\t%.2f', acparams(i).freq(:, j));
            fprintf(fid, '\r\n');
        end
    end
    fclose(fid);
end
