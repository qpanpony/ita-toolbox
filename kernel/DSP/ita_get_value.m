function varargout = ita_get_value(varargin)
%ITA_GET_VALUE - Get characteristic values of a signal
%  This function returns often used characteristic values of a signal, i.e.
%  rms, mean, max, min ...
%
%  Syntax: valueVector = ita_get_value(audioObj,valueString)
%  Syntax: ita_get_value(audioObj,valueString) - displays information
%
%   See also ita_plot_dat.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_get_value">doc ita_get_value</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created: 23-Sep-2008 

%% Initialization
% Number of Input Arguments
narginchk(1,2);
thisFuncStr  = [upper(mfilename) ':'];   %  %#ok<NASGU> Use to show warnings or infos in this functions

% Find Audio Data
data = varargin{1}.';

ita_verbose_info([thisFuncStr 'Please be careful with this implementation!'],0)

valueString = varargin{2};

%% Choose what to do
result = [];
switch lower(valueString)
    case {'mean','all'}
        result = [result mean(data.dat,2)];
    case {'rms','all'}
        result = [result sqrt(mean(data.dat.^2,2))];
    case {'min','all'}
        result = [result min(data.dat,[],2)];
    case {'max','all'}
        result = [result max(data.dat,[],2)];
    case {'signedmax'}
        [value,valueidx] = max(data.dat.^2);
        for idx = 1:length(valueidx)
            result(idx,1) = data.dat(idx,valueidx(idx));
        end
    otherwise
        error('ITA_GET_VALUE:Oh Lord. I don''t know what to do')
end

%% Find output parameters

% Write Data
disp(['The ' lower(valueString) ' is ' num2str(result.')])
varargout(1) = {result};

%end function
end