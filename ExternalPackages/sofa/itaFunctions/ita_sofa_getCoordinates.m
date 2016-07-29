function coordinates = ita_sofa_getCoordinates(varargin)
%ITA_SOFA_GETCOORDINATES - +++ converts SOFA coordinates to itaCoordinates +++
%  This function converts SOFA coordinates to itaCoordinates
%
%  Syntax:
%   audioObjOut = ita_sofa_getCoordinates(audioObjIn, options)
%
%   Options (default):
%           'channelCoordinateType' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   coordinates = ita_sofa_getCoordinates(handleSofa,'channelCoordinateType','SourcePosition');
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sofa_getCoordinates">doc ita_sofa_getCoordinates</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Jan Gerrit Richter -- Email: jan.richter@rwth-aachen.de
% Created:  30-Sep-2014 

sArgs = struct('pos1_data','struct','channelCoordinateType','ReceiverPosition');
[sofaObj,sArgs] = ita_parse_arguments(sArgs,varargin); 

coordinateType = sArgs.channelCoordinateType;

data = sofaObj.(coordinateType);
dataType = sofaObj.(sprintf('%s_Type',coordinateType));
dataUnit = sofaObj.(sprintf('%s_Units',coordinateType));

coordinates = itaCoordinates(size(data,1));
switch dataType
    case 'cartesian'
        if strcmpi(dataUnit,'meter')
            coordinates.x = data(:,1);
            coordinates.y = data(:,2);
            coordinates.z = data(:,3);    
        else
           warning('ITA_READ_SOFA: unit is not meter. doing nothing'); 
        end
    case 'spherical'
%         if strcmpi(dataUnit,'degree')
            coordinates.phi_deg = data(:,1);
            coordinates.theta_deg = data(:,2)+90;
            coordinates.r = data(:,3);
%         else
%             warning('ITA_READ_SOFA: unit is not checked in spherical type'); 
%         end
        
    otherwise
        warning('ITA_READ_SOFA: unknown data type. doing nothing');
    
end


end