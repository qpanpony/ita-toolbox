function varargout = ita_matrixfun(funHandle, data, varargin)
%ITA_MATRIXFUN - Similar to bsxfun but for itaSuper Matrices
%  This function applies a function to a multi-instance itaSuper
%
%  Syntax:
%   data = ita_matrixfun(funHandle, data)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_matrixfun">doc ita_matrixfun</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  05-Aug-2011 



if iscell(data) %maybe several multi-intances, use recursion
    for idx = 1:size(data,1)
        for jdx = 1:size(data,2)
            data_out{idx,jdx} = ita_matrixfun(funHandle, data{idx,jdx}, varargin{:});
        end
    end
else %normal mode, multi Instance
    for idx = 1:size(data,1)
        for jdx = 1:size(data,2)
            if isempty(varargin)
                data_out(idx,jdx) = funHandle(data(idx,jdx));
                
            else
                data_out(idx,jdx) = funHandle(data(idx,jdx),varargin{:});
            end
        end
    end
end


%% Set Output
varargout(1) = {data_out}; 

%end function
end