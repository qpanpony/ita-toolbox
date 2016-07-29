function ita_pcolor(varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


if nargin > 2 && isnumeric(varargin{3})
    % we do have the (X,Y,C) syntax
    varargin{3} = absolute(varargin{3});
elseif isnumeric(varargin{1})
    % we do have the (C) syntax
    varargin{1} = absolute(varargin{1});
end
pcolor(abs(varargin{1}))
shading interp
colormap jet
colorbar

    function value = absolute(value)
        if any(~isreal(value))
            value = abs(value)
        end
    end

end