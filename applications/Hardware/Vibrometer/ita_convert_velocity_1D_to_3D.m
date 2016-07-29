function varargout = ita_convert_velocity_1D_to_3D(varargin)
%ITA_CONVERT_VELOCITY_1D_TO_3D - turn 1D velocity data into 3D
%  This function turns the 1D velocity data into 3D
%
%  Syntax:
%   audioObjOut = ita_convert_velocity_1D_to_3D(audioObjIn, options)
%
%   Options (default):
%           'direction' ('z') : description
%
%  Example:
%   audioObjOut = ita_convert_velocity_1D_to_3D(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_convert_velocity_1D_to_3D">doc ita_convert_velocity_1D_to_3D</a>

% <ITA-Toolbox>
% This file is part of the application Vibrometer for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  30-Nov-2010 


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaSuper', 'direction', 'z');
[input,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% create some dummy data and paste it into the directions we do not need
% first save the old data
nodes = input.channelCoordinates;
data = input.freq;
channelUnits = input.channelUnits;
channelNames = input.channelNames;

% dummy nodes, copy coordinates and create IDs that start after the maximum
% of the old ones
tmpNodes = itaMeshNodes(2*nodes.nPoints);
tmpNodes.cart(1:nodes.nPoints,:) = nodes.cart;
tmpNodes.cart((1:nodes.nPoints)+nodes.nPoints,:) = nodes.cart;
tmpNodes.ID = tmpNodes.ID + max(nodes.ID);
newNodes = merge(nodes,tmpNodes);

% fill data with zeros except for the direction we want
tmpData = zeros(input.nBins,input.nChannels);
switch sArgs.direction
    case 'x'
        newData = cat(3,data,tmpData,tmpData);
    case 'y'
        newData = cat(3,tmpData,data,tmpData);
    otherwise
        newData = cat(3,tmpData,tmpData,data);
end

% put it all back in
input.freq = newData;
input.channelCoordinates = newNodes;
input.channelNames = repmat(channelNames,3,1);
input.channelUnits = repmat(channelUnits,3,1);

%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input}; 

%end function
end