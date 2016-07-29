function [data] = ita_read_mat(varargin)
%ita_read_mat - Import BK Pulse Data
%  Import files that look like MATLAB but there is more inside :-)
%    used for BK Pulse and Artemis or itaAudio in mat
%
%  Call: spk/dat = ita_read_mat([filename])
%
%   See also ita_read, ita_write.
%
%   Reference page in Help browser
%       <a href="matlab:doc ita_read_mat">doc ita_read_mat</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  29-May-2008
% Modified: 08-Sep-2008 - pdi - Cleaning, memory efficiency, new preferences

%% Init
thisFuncStr  = [upper(mfilename) ':'];

%% Get Filename if missing
if nargin == 0 % No filename specified
    result{1}.extension = '.mat';
    result{1}.comment = 'Matlab Export (BK PULSE,ArtemiS) (*.mat)';
    data = result;
    return
else
    filename  = varargin{1};
end

token        = whos('-file',filename);

for idx = 1:length(token)
    if strcmpi(token(idx).name,'Channel_1_Data')
        data = ita_read_BK_pulse(filename);
        return;
    elseif strcmpi(token(1).name,'shdf')
        data = ita_read_artemis(filename);
        return;
    elseif strcmpi(token(1).class,'itaAudio') && length(token) == 1
        data = ita_read_ita(filename);
        return;
    end
end

%% still here?
ita_verbose_info([thisFuncStr 'Cannot determine file type, importing anyways'],0)
data = load(filename);


