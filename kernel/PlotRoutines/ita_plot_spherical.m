function fgh = ita_plot_spherical(varargin)
%ITA_PLOT_SPHERICAL - plots a spherical function
%  This function plots a spherical function, split in northern and southern
%  part, on the given frequencies.
%
%  Syntax: ita_plot_spherical(dataNorth)
%  Call: ita_plot_spherical(dataNorth, frequencies)
%  Call: ita_plot_spherical(dataNorth, plotType)
%  Call: ita_plot_spherical(dataNorth, frequencies, plotType)
%  Call: ita_plot_spherical(dataNorth, dataSouth)
%  Call: ita_plot_spherical(dataNorth, dataSouth, plotType)
%  Call: ita_plot_spherical(dataNorth, dataSouth, frequencies)
%  Call: ita_plot_spherical(dataNorth, dataSouth, frequencies, plotType)
%
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_plot_spherical">doc ita_plot_spherical</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Pollow -- Email: mpo@akustik.rwth-aachen.de
% Created: 16-Sep-2008 

%% Get ITA Toolbox preferences
% mpo: batch commenting of: "Mode % global variable is loaded very fast" 
verboseMode = ita_preferences('verboseMode'); % mpo, batch replacement, 15-04-2009

% this is the default:
plotType = 'magnitude';
frequencyVector = [];

%% initializing
narginchk(1,4);

nUndefinedArguments = nargin;

if nUndefinedArguments > 1
    if ischar(varargin{nUndefinedArguments}) % last argument is plotType
        plotType = varargin{nUndefinedArguments};
        nUndefinedArguments = nUndefinedArguments - 1;
    end
    
    if isnumeric(varargin{nUndefinedArguments}) % new last argument is freqencies
        frequencyVector = varargin{nUndefinedArguments};
        nUndefinedArguments = nUndefinedArguments - 1;
    end
end
    
northCell = varargin{1};
[folderInfoNorth, northSPK] = ita_make_spheredata(northCell, frequencyVector);

if nUndefinedArguments == 2 

    southCell = varargin{2};

    [folderInfoSouth, southSPK] = ita_make_spheredata(southCell, frequencyVector);
    % now flip germany to sunny brasil...
    [folderInfoSouth, southSPK] = germany2brasil(folderInfoSouth, southSPK);

    % use all given data from struct
    folderInfo = folderInfoNorth;

    % and replace the hemisphere with full sphere
    folderInfo.theta = [folderInfoNorth.theta; folderInfoSouth.theta];
    folderInfo.phi = [folderInfoNorth.phi; folderInfoSouth.phi];
    % folderInfo.VxxxHxxx = [folderInfoNorth.VxxxHxxx; folderInfoSouth.VxxxHxxx];

    disp('TO DO: get rid of one equator')

    completeSPK = cat(1, northSPK, southSPK);
else
    folderInfo = folderInfoNorth;
    completeSPK = northSPK;
end

cartesian = ita_plottools_sph2cart(folderInfo, completeSPK, plotType);
fgh = ita_plottools_sphplot(cartesian);

% 
% if nargout > 1
%     folderInfo.SPK = completeSPK;
%     varargout{1} = folderInfo;
% else
%     ita_plot
%     ita_plot_spherical(folderInfo, completeSPK, 'magnitude');
% end

 function [folderInfoBrasil, polarSPKBrasil] = germany2brasil(folderInfoGermany, polarSPKGermany)
folderInfoBrasil.theta = pi - flipdim(folderInfoGermany.theta,1);
folderInfoBrasil.phi = flipdim(folderInfoGermany.phi(:,[2:end 1]),2);
polarSPKBrasil = flipdim(flipdim(polarSPKGermany(:,[2:end 1],:),2),1);
