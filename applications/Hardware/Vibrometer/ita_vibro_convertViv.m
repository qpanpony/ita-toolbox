function varargout = ita_vibro_convertViv(varargin)
%ITA_VIBRO_CONVERTVIV - convert a vivo-file to cell array of vibometer commands 
%  This function takes a .viv-file (the output of ITA_VIBRO_VIVO) and a vector 
%  of node IDs as input arguments and returns a cell array, with the node ID and
%  the corresponding angles that can be used as input for ita_vibro_moveTo.
%
%  Call: result = ita_vibro_convertViv(vivFilename,nodes)
%
%   See also ita_fft, ita_ifft, ita_ita_read, ita_ita_write, ita_metainfo_rm_channelsettings, ita_metainfo_add_picture, ita_impedance_parallel, ita_unv2unv, ita_readunv58, ita_readunv2414, ita_writeunv58, ita_writeunv2414, ita_fft, ita_ifft, ita_ita_read, ita_ita_write, ita_metainfo_rm_channelsettings, ita_metainfo_add_picture, ita_impedance_parallel, ita_plot_surface, ita_deal_units, ita_impedance2apparementmass, ita_measurement_setup, ita_measurement_run, ita_RS232_ITAlian_init, ita_measurement_polar, ita_vibro_sendInterfaceCommand, ita_vibro_getSignalLevel, ita_vibro_getVeloRange, ita_vibro_setVeloRange, ita_vibro_getTracking, ita_vibro_setTracking, ita_vibro_getOverrange, ita_vibro_getRemoteMode, ita_vibro_setRemoteMode, ita_vibro_lasergui, ita_measurement_laser.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_vibro_convertViv">doc ita_vibro_convertViv</a>

% <ITA-Toolbox>
% This file is part of the application Vibrometer for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created: 25-Nov-2008 

%% Initialization and Input Parsing
sArgs = struct('pos1_vivFilename','string','pos2_nodes','vector');
[vivFilename,nodes] = ita_parse_arguments(sArgs,varargin);

%% Body
conv = cell(numel(nodes),2);
fid  = fopen(vivFilename);

if fid ~= -1 % file could be opened
    l = fgetl(fid); % get the nodeID
    i = 1;
    while l ~= -1
        str   = fgetl(fid); % get the command(s)
        parts = regexp(str,',','split'); % split commands
        if any(isempty(parts)) || numel(parts) > 2
            error('Empty / incorrect values for angles found');
        end
        conv{i,1} = str2double(l); % nodeID
        conv{i,2} = [str2double(parts{1}),str2double(parts{2})]; % angles
        i = i+1;
        l = fgetl(fid); % get the next nodeID
    end
    fclose(fid);
end
varargout(1) = {conv}; 

%end function
end