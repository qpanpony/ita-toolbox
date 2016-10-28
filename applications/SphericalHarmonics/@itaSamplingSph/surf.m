function varargout = surf(this, varargin)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% sArgs        = struct('pos1_data','double', 'parent', 0);
% [input,sArgs] = ita_parse_arguments(sArgs,varargin); 


titleString = [];

% check if SH coefs are given
if numel(varargin{1}) > 0 &&...
    this.nPoints ~= numel(varargin{1})     &&...
    numel(this.Y) > 0       &&...
    size(this.Y,1) == this.nPoints

    ita_verbose_info('This must be SH vector, transforming to spatial domain')
%         ita_verbose_info('TODO: all results are currenty mirrowed at the x-z axis, I think. Take care!!!',0)

    nSHGrid = size(this.Y,2);
    nSHData = size(varargin{1}(:),1);
    if nSHGrid ~= nSHData
        % TODO make autofit
        if nSHGrid > nSHData
            varargin{1} = [varargin{1}(:); zeros(nSHGrid - nSHData,1)];
        else
            ita_verbose_info('Insufficient grid, I cannot plot the full SH spectrum',0);
        end
    end
    % apply IDSHT:      
    varargin{1} = this.Y * varargin{1}(:);
    if size(this.Y,2)>1 && ~all(isreal(this.Y(:,2))) && all(isreal(varargin{1}))
        % change to complex drawing mode, if complex base is used
        varargin{1}(1) = varargin{1}(1) + 1i * eps;
    end
    ita_verbose_info(['plotting SH-coefficients up to order ' num2str(this.nmax)],2);
    nmaxVec = ceil(sqrt(nSHData)-1);
    titleString = ['Spherical Harmonics coefficients, nmax = ' num2str(nmaxVec) '/' num2str(this.nmax) ' (data/grid)'];
end



hFig = {surf@itaCoordinates(this, varargin{:})};

% set title
if ~isempty(titleString)
    title(titleString);
end

if nargout
    varargout = {hFig};
else
    varargout = {};
end

