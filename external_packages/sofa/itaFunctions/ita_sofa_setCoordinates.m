    function sofaObj = ita_sofa_setCoordinates(varargin)
%ITA_SOFA_SETCOORDINATES - +++ set itaCoordinates to SOFA object +++
%  This function sets itaCoordinates to SOFA object
%
%  Syntax:
%   sofaObj = ita_sofa_setCoordinates(sofaObj,audioObjIn, options)
%
%   Options (default):
%           'channelCoordinateType' (ReceiverPosition) : which coordinates
%                                                        should be read
%
%                           channelCoordinateType = 'ReceiverPosition';
%                           channelCoordinateType = 'SourcePosition';
%
%  Example:
%   sofaObj = ita_sofa_setCoordinates(sofaObj,data,'channelCoordinateType','SourcePosition')
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sofa_setCoordinates">doc ita_sofa_setCoordinates</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Jan Gerrit Richter -- Email: jan.richter@rwth-aachen.de
% Created:  04-Dec-2014 



sArgs = struct('pos1_data','struct','pos2_coordinates','itaAudio','channelCoordinateType','ReceiverPosition');
[sofaObj,data,sArgs] = ita_parse_arguments(sArgs,varargin); 

% channelCoordinates
coordinateType = sArgs.channelCoordinateType;
if isa(data,'itaHRTF')
    coordinates = data.dirCoord;
else
    coordinates = data.channelCoordinates;
end
cartData = coordinates.cart;

sofaObj.(coordinateType) = cartData;
sofaObj.(sprintf('%s_Type',coordinateType)) = 'cartesian';
sofaObj.(sprintf('%s_Units',coordinateType)) = 'meter';

warning('ITA_WRITE_SOFA: Only the main coordinates are saved. Orientation etc is discarded');
% % object coordinates
% 
% % switch the coordinate destination
% if strcmp(coordinateType,'SourcePosition')
%     coordinateType = 'ReceiverPosition';
% else
%     coordinateType = 'SourcePosition';
% end
% 
% coordinates = data.chanelCoordinaes;
% cartData = coordinates.cart;
% 
% sofaObj.(coordinateType) = cartData;
% sofaObj.(sprintf('%s_Type',coordinateType)) = 'cartesian';
% sofaObj.(sprintf('%s_Units',coordinateType)) = 'meter';

end

