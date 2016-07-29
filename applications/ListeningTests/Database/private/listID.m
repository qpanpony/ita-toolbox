function [command] = listID(order, tableName)


% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

command = ['select ID from ', tableName, ' order by ', order];