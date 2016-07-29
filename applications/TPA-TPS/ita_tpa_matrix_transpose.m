function varargout = ita_tpa_matrix_transpose(A)
%ITA_TPA_MATRIX_TRANSPOSE - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_tpa_matrix_transpose(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_tpa_matrix_transpose(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_tpa_matrix_transpose">doc ita_tpa_matrix_transpose</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  08-Aug-2011 



%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
Atrans = 0*A;
for idx = 1:size(A,1)
    for jdx = 1:size(A,2)
        Atrans(jdx,idx) = A(idx,jdx);
    end
end

%% Set Output
varargout(1) = {Atrans}; 

%end function
end