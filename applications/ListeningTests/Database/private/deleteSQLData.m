function [command] = deleteSQLData(ID, tableName)


% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

command = ['delete from ' tableName ' where ID in (', char(39), num2str(ID), char(39), ') limit 1'];